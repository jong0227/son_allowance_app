import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/app_database.dart';
import 'export_import_service.dart';

enum SyncStatus { idle, syncing, error }

/// 가족 코드로 묶인 Firestore 문서 하나를 통해 실시간으로 데이터를 주고받는다.
/// 기존 파일 Export/Import의 id+updatedAt 스마트 병합 로직을 그대로 재사용하고,
/// 전송 수단만 "카톡으로 보낸 파일"에서 "Firestore 문서"로 바꾼 것.
///
/// - 로컬 변경: drift의 tableUpdates() 스트림을 구독해 자동으로 업로드(디바운스).
/// - 원격 변경: Firestore 문서 snapshots()를 구독해 자동으로 병합.
/// - 내용이 바뀌지 않았으면 업로드/병합을 생략해 자기 자신이 올린 변경을 다시
///   받아 무한 반복하는 것을 막는다(신호값 비교).
class FamilySyncService {
  final AppDatabase db;
  final ExportImportService _io = const ExportImportService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _localSub;
  StreamSubscription? _remoteSub;
  Timer? _pushDebounce;
  String? _lastSignature;
  String? _familyCode;
  String _editedBy = '';

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  DateTime? lastSyncedAt;

  /// 부모 암호(해시)를 가족 문서에 실어 다른 기기에도 전파하기 위한 연결고리.
  /// - readPasscode: 이 기기가 아는 부모 암호를 (hash, salt)로 반환(없으면 null).
  /// - onRemotePasscode: 원격 문서에서 받은 부모 암호를 이 기기에 반영.
  (String hash, String salt)? Function()? readPasscode;
  Future<void> Function(String hash, String salt)? onRemotePasscode;

  FamilySyncService(this.db);

  String? get familyCode => _familyCode;
  bool get isActive => _familyCode != null;

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  String _generateCode() {
    // 0/O, 1/I/L처럼 헷갈리는 문자는 제외
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// 새 가족 코드를 발급하고 지금 데이터를 초기 업로드한다.
  Future<String> createFamily(String editedBy) async {
    await _ensureSignedIn();
    _editedBy = editedBy;
    String code;
    while (true) {
      code = _generateCode();
      final snap = await _firestore.collection('families').doc(code).get();
      if (!snap.exists) break;
    }
    _familyCode = code;
    await db.reconcileToSingleChild(editedBy);
    await _pushNow(force: true);
    _startListening();
    return code;
  }

  /// 상대가 발급한 코드로 참여. 존재하지 않는 코드면 예외.
  Future<void> joinFamily(String code, String editedBy) async {
    await _ensureSignedIn();
    final upper = code.trim().toUpperCase();
    final snap = await _firestore.collection('families').doc(upper).get();
    if (!snap.exists) {
      throw Exception('존재하지 않는 코드예요. 상대방에게 코드를 다시 확인해주세요.');
    }
    _editedBy = editedBy;
    _familyCode = upper;
    await _applyRemote(snap.data());
    // 이 기기가 온보딩 때 만든 "내 아이" 프로필과, 방금 받아온 상대방의 프로필이
    // 서로 다른 id로 공존하게 된다. 데이터가 없는 쪽(보통 방금 참여한 이 기기)을
    // 정리해 하나로 합치지 않으면 화면이 빈 프로필을 계속 보여준다.
    await db.reconcileToSingleChild(editedBy);
    await _pushNow(force: true);
    _startListening();
  }

  /// 앱을 다시 켰을 때, 이미 저장된 코드로 조용히 재연결.
  Future<void> resume(String code, String editedBy) async {
    await _ensureSignedIn();
    _editedBy = editedBy;
    _familyCode = code;
    _startListening();
  }

  void _startListening() {
    _localSub?.cancel();
    _remoteSub?.cancel();
    _localSub = db.tableUpdates().listen((_) => _schedulePush());
    _remoteSub = _firestore
        .collection('families')
        .doc(_familyCode)
        .snapshots()
        .listen((snap) => _applyRemote(snap.data()));
  }

  void _schedulePush() {
    _pushDebounce?.cancel();
    _pushDebounce = Timer(const Duration(milliseconds: 1200), () => _pushNow());
  }

  /// 부모 암호를 방금 설정/변경했을 때 등, 데이터 외 변경을 즉시 전파하기 위한 공개 훅.
  Future<void> pushNow() => _pushNow(force: true);

  Future<void> _pushNow({bool force = false}) async {
    final code = _familyCode;
    if (code == null) return;
    try {
      _statusController.add(SyncStatus.syncing);
      final data = await _io.serializeAll(db, _editedBy);
      // 자녀 기기는 자녀 설정(기본 용돈/지급 요일/보너스·이자 규칙 등)을 올리지 않는다.
      // 아이 폰의 오래된 값이 부모가 방금 바꾼 설정을 덮어쓰던 문제 방지.
      // (지출 내역·요청 등 나머지는 그대로 올라간다)
      if (_editedBy == '아들') data.remove('children');
      final signature = _signatureOf(data);
      final pass = readPasscode?.call();
      if (!force && signature == _lastSignature) {
        _statusController.add(SyncStatus.idle);
        return;
      }
      await _firestore.collection('families').doc(code).set({
        'data': data,
        // 부모 암호(해시)를 아는 기기만 실어 보낸다. 모르면 필드를 건드리지 않아
        // (merge) 기존 암호를 지우지 않는다.
        if (pass != null) 'parentPasscode': {'hash': pass.$1, 'salt': pass.$2},
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _editedBy,
      }, SetOptions(merge: true));
      _lastSignature = signature;
      lastSyncedAt = DateTime.now();
      _statusController.add(SyncStatus.idle);
    } catch (_) {
      _statusController.add(SyncStatus.error);
    }
  }

  Future<void> _applyRemote(Map<String, dynamic>? doc) async {
    if (doc == null) return;
    // 부모 암호는 데이터 변경과 무관하게 항상 먼저 반영(데이터 신호가 같아도 놓치지 않도록).
    final pass = doc['parentPasscode'];
    if (pass is Map && pass['hash'] is String && pass['salt'] is String) {
      await onRemotePasscode?.call(pass['hash'] as String, pass['salt'] as String);
    }
    final raw = doc['data'];
    if (raw is! Map) return;
    final map = Map<String, dynamic>.from(raw);
    final signature = _signatureOf(map);
    if (signature == _lastSignature) return; // 내가 방금 올린 것의 반향이면 무시
    try {
      _statusController.add(SyncStatus.syncing);
      final preview = await _io.previewImportData(map, db);
      await _io.applyImport(preview, db);
      // 매 원격 병합마다 중복 프로필 정리를 재확인한다(온보딩을 다시 하거나
      // 여러 기기가 거의 동시에 참여하는 경우에도 계속 하나로 수렴하도록).
      await db.reconcileToSingleChild(_editedBy);
      _lastSignature = signature;
      lastSyncedAt = DateTime.now();
      _statusController.add(SyncStatus.idle);
    } catch (_) {
      _statusController.add(SyncStatus.error);
    }
  }

  /// Map 키 순서를 정렬해 같은 내용이면 항상 같은 문자열이 되도록 한다.
  /// (Firestore를 거치면 map 키 순서가 보존된다는 보장이 없어, 방금 올린 데이터를
  /// 그대로 되받았을 때도 다른 신호값이 나와 불필요한 재처리를 하는 걸 막기 위함)
  dynamic _canonicalize(dynamic v) {
    if (v is Map) {
      final keys = v.keys.map((k) => k.toString()).toList()..sort();
      return {for (final k in keys) k: _canonicalize(v[k])};
    }
    if (v is List) return v.map(_canonicalize).toList();
    return v;
  }

  String _signatureOf(Map<String, dynamic> data) => jsonEncode(_canonicalize(data));

  /// 동기화 중단 (Firestore의 가족 데이터 자체는 지우지 않음. 로컬 연결만 끊음).
  Future<void> leaveFamily() async {
    await _localSub?.cancel();
    await _remoteSub?.cancel();
    _pushDebounce?.cancel();
    _localSub = null;
    _remoteSub = null;
    _familyCode = null;
    _lastSignature = null;
  }

  void dispose() {
    _localSub?.cancel();
    _remoteSub?.cancel();
    _pushDebounce?.cancel();
    _statusController.close();
  }
}

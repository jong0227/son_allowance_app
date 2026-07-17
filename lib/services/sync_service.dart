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

  Future<void> _pushNow({bool force = false}) async {
    final code = _familyCode;
    if (code == null) return;
    try {
      _statusController.add(SyncStatus.syncing);
      final data = await _io.serializeAll(db, _editedBy);
      final signature = _signatureOf(data);
      if (!force && signature == _lastSignature) {
        _statusController.add(SyncStatus.idle);
        return;
      }
      await _firestore.collection('families').doc(code).set({
        'data': data,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _editedBy,
      });
      _lastSignature = signature;
      lastSyncedAt = DateTime.now();
      _statusController.add(SyncStatus.idle);
    } catch (_) {
      _statusController.add(SyncStatus.error);
    }
  }

  Future<void> _applyRemote(Map<String, dynamic>? doc) async {
    if (doc == null) return;
    final raw = doc['data'];
    if (raw is! Map) return;
    final map = Map<String, dynamic>.from(raw);
    final signature = _signatureOf(map);
    if (signature == _lastSignature) return; // 내가 방금 올린 것의 반향이면 무시
    try {
      _statusController.add(SyncStatus.syncing);
      final preview = await _io.previewImportData(map, db);
      await _io.applyImport(preview, db);
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

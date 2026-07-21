import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import '../data/app_database.dart';
import '../utils/formatters.dart';

class ImportPreview {
  final int newCount;
  final int updatedCount;
  final int unchangedCount;
  final Map<String, dynamic> rawJson;

  ImportPreview({
    required this.newCount,
    required this.updatedCount,
    required this.unchangedCount,
    required this.rawJson,
  });
}

/// 부부간 동기화: 전체 데이터를 JSON으로 Export 하고, 다른 기기에서 Import 시
/// id 기준으로 로컬에 없는 건 추가, 있는 건 updatedAt이 더 최신인 쪽을 채택하는
/// "스마트 병합" 방식으로 합친다.
class ExportImportService {
  const ExportImportService();

  /// Export 데이터 포맷 버전. 필드가 늘어나도 Import는 없는 필드를 기본값으로
  /// 처리하므로, 이 앱을 나중에 개선/재설치해도 예전 백업을 그대로 불러올 수 있다.
  static const dataFormatVersion = 3;

  Future<Map<String, dynamic>> serializeAll(
    AppDatabase db,
    String exportedBy, {
    Map<String, dynamic>? settings,
  }) async {
    final children = await db.allChildrenRaw();
    final schedules = await db.allSchedulesRaw();
    final txs = await db.allTransactionsRaw();
    final transfers = await db.allStockTransfersRaw();
    final goals = await db.allGoalsRaw();
    final rates = await db.allAllowanceRatesRaw();
    final reqs = await db.allRequestsRaw();
    final tierList = await db.allTiersRaw();
    final promiseList = await db.allPromisesRaw();

    return {
      'version': dataFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'exportedBy': exportedBy,
      'children': children.map(_childToJson).toList(),
      'allowanceSchedules': schedules.map(_scheduleToJson).toList(),
      'transactionEntries': txs.map(_txToJson).toList(),
      'stockTransfers': transfers.map(_transferToJson).toList(),
      'goals': goals.map(_goalToJson).toList(),
      'allowanceRates': rates.map(_rateToJson).toList(),
      'requests': reqs.map(_requestToJson).toList(),
      'tiers': tierList.map(_tierToJson).toList(),
      'promises': promiseList.map(_promiseToJson).toList(),
      if (settings != null) 'settings': settings,
    };
  }

  /// JSON 백업 파일 + 사람이 읽기 편한 요약 텍스트 파일을 함께 생성한다.
  Future<(File json, File summary)> buildExportFiles(
    AppDatabase db, {
    required String exportedBy,
    required List<Child> childrenForSummary,
    Map<String, dynamic>? settings,
  }) async {
    final data = await serializeAll(db, exportedBy, settings: settings);
    final dir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory('${dir.path}/exports');
    if (!await exportsDir.exists()) await exportsDir.create(recursive: true);

    final ts = DateTime.now();
    final stamp =
        '${ts.year}${_pad2(ts.month)}${_pad2(ts.day)}_${_pad2(ts.hour)}${_pad2(ts.minute)}';

    final jsonFile = File('${exportsDir.path}/allowance_backup_$stamp.json');
    await jsonFile.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    final summaryText = await _buildHumanSummary(db, exportedBy, childrenForSummary);
    final summaryFile = File('${exportsDir.path}/allowance_summary_$stamp.txt');
    await summaryFile.writeAsString(summaryText);

    return (jsonFile, summaryFile);
  }

  Future<String> _buildHumanSummary(
    AppDatabase db,
    String exportedBy,
    List<Child> childrenForSummary,
  ) async {
    final buf = StringBuffer();
    buf.writeln('아들 용돈 관리 - 백업 요약');
    buf.writeln('내보낸 사람: $exportedBy');
    buf.writeln('내보낸 시각: ${formatDate(DateTime.now())}');
    buf.writeln('---------------------------------');
    for (final child in childrenForSummary) {
      final summary = await db.computeSummary(child.id);
      buf.writeln('[${child.name}]');
      buf.writeln('현재 잔액: ${formatWon(summary['balance'] ?? 0)}');
      buf.writeln('누적 정기용돈: ${formatWon(summary['totalRegularIncome'] ?? 0)}');
      buf.writeln('누적 특별수입: ${formatWon(summary['totalSpecialIncome'] ?? 0)}');
      buf.writeln('누적 지출: ${formatWon(summary['totalExpense'] ?? 0)}');
      buf.writeln('누적 주식계좌 이체: ${formatWon(summary['totalTransfer'] ?? 0)}');
      final income = summary['totalIncome'] ?? 0;
      final savings = summary['totalSavings'] ?? 0;
      final rate = income == 0 ? 0 : (savings / income * 100);
      buf.writeln('저축비율: ${rate.toStringAsFixed(1)}%');

      final txs = await (db.select(db.transactionEntries)
            ..where((t) => t.childId.equals(child.id) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(5))
          .get();
      if (txs.isNotEmpty) {
        buf.writeln('최근 내역:');
        for (final t in txs) {
          final sign = t.flow == 'income' ? '+' : '-';
          buf.writeln('  ${formatDateShort(t.date)} $sign${formatWon(t.amount)} (${t.category})');
        }
      }
      buf.writeln('---------------------------------');
    }
    buf.writeln('이 파일은 참고용이며, 실제 동기화는 함께 첨부된 .json 파일을 앱에서');
    buf.writeln('Import 해야 반영됩니다.');
    return buf.toString();
  }

  Future<ImportPreview> previewImport(File jsonFile, AppDatabase db) async {
    final content = await jsonFile.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    return previewImportData(data, db);
  }

  /// 파일이 아니라 이미 메모리에 있는 JSON(Map)으로 미리보기를 만든다.
  /// Firestore 실시간 동기화처럼 파일을 거치지 않는 경로에서 재사용한다.
  Future<ImportPreview> previewImportData(Map<String, dynamic> data, AppDatabase db) async {
    int newCount = 0, updatedCount = 0, unchangedCount = 0;

    Future<void> diff<T>(
      String key,
      Future<List<T>> Function() localRows,
      String Function(T) idOf,
      DateTime Function(T) updatedAtOf,
    ) async {
      final locals = {for (final r in await localRows()) idOf(r): updatedAtOf(r)};
      final incoming = _rows(data[key]);
      for (final row in incoming) {
        final id = _idOf(row);
        if (id == null) continue; // id 없는 손상된 레코드는 건너뜀
        final updatedAt = _updatedOf(row);
        if (!locals.containsKey(id)) {
          newCount++;
        } else if (updatedAt.isAfter(locals[id]!)) {
          updatedCount++;
        } else {
          unchangedCount++;
        }
      }
    }

    await diff('children', db.allChildrenRaw, (Child c) => c.id, (Child c) => c.updatedAt);
    await diff('allowanceSchedules', db.allSchedulesRaw, (AllowanceSchedule s) => s.id,
        (AllowanceSchedule s) => s.updatedAt);
    await diff('transactionEntries', db.allTransactionsRaw, (TransactionEntry t) => t.id,
        (TransactionEntry t) => t.updatedAt);
    await diff('stockTransfers', db.allStockTransfersRaw, (StockTransfer s) => s.id,
        (StockTransfer s) => s.updatedAt);
    await diff('goals', db.allGoalsRaw, (Goal g) => g.id, (Goal g) => g.updatedAt);
    await diff('allowanceRates', db.allAllowanceRatesRaw, (AllowanceRate r) => r.id,
        (AllowanceRate r) => r.updatedAt);
    await diff('requests', db.allRequestsRaw, (Request r) => r.id,
        (Request r) => r.updatedAt);
    await diff('tiers', db.allTiersRaw, (Tier t) => t.id, (Tier t) => t.updatedAt);
    await diff('promises', db.allPromisesRaw, (Promise p) => p.id, (Promise p) => p.updatedAt);

    return ImportPreview(
      newCount: newCount,
      updatedCount: updatedCount,
      unchangedCount: unchangedCount,
      rawJson: data,
    );
  }

  Future<void> applyImport(ImportPreview preview, AppDatabase db) async {
    final data = preview.rawJson;

    // 손상되거나 포맷이 다른 개별 레코드가 있어도 전체 Import가 중단되지 않도록
    // 레코드 단위로 try/catch 하며 최신(updatedAt) 우선으로 병합한다.
    Future<void> merge<L>(
      String key,
      Future<List<L>> Function() localRows,
      String Function(L) idOf,
      DateTime Function(L) updatedAtOf,
      Future<void> Function(Map<String, dynamic>) upsert,
    ) async {
      final locals = {for (final r in await localRows()) idOf(r): updatedAtOf(r)};
      for (final row in _rows(data[key])) {
        try {
          final id = _idOf(row);
          if (id == null) continue;
          final updatedAt = _updatedOf(row);
          if (!locals.containsKey(id) || updatedAt.isAfter(locals[id]!)) {
            await upsert(row);
          }
        } catch (_) {
          // 개별 레코드 파싱 실패는 무시하고 계속 진행
        }
      }
    }

    await merge('children', db.allChildrenRaw, (Child c) => c.id, (c) => c.updatedAt,
        (row) => db.upsertChild(_childFromJson(row)));
    await merge('allowanceSchedules', db.allSchedulesRaw, (AllowanceSchedule s) => s.id,
        (s) => s.updatedAt, (row) => db.upsertSchedule(_scheduleFromJson(row)));
    await merge('transactionEntries', db.allTransactionsRaw, (TransactionEntry t) => t.id,
        (t) => t.updatedAt, (row) => db.upsertTransaction(_txFromJson(row)));
    await merge('stockTransfers', db.allStockTransfersRaw, (StockTransfer s) => s.id,
        (s) => s.updatedAt, (row) => db.upsertStockTransfer(_transferFromJson(row)));
    await merge('goals', db.allGoalsRaw, (Goal g) => g.id, (g) => g.updatedAt,
        (row) => db.upsertGoal(_goalFromJson(row)));
    await merge('allowanceRates', db.allAllowanceRatesRaw, (AllowanceRate r) => r.id,
        (r) => r.updatedAt, (row) => db.upsertAllowanceRate(_rateFromJson(row)));
    await merge('requests', db.allRequestsRaw, (Request r) => r.id, (r) => r.updatedAt,
        (row) => db.upsertRequest(_requestFromJson(row)));
    await merge('tiers', db.allTiersRaw, (Tier t) => t.id, (t) => t.updatedAt,
        (row) => db.upsertTier(_tierFromJson(row)));
    await merge('promises', db.allPromisesRaw, (Promise p) => p.id, (p) => p.updatedAt,
        (row) => db.upsertPromise(_promiseFromJson(row)));
  }

  // ---------------- 안전한 값 읽기 (하위/상위 버전 호환) ----------------
  List<Map<String, dynamic>> _rows(dynamic v) =>
      v is List ? v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList() : const [];
  String? _idOf(Map<String, dynamic> j) {
    final v = j['id'];
    return (v is String && v.isNotEmpty) ? v : null;
  }

  DateTime? _dt(dynamic v) => v is String ? DateTime.tryParse(v) : null;
  DateTime _updatedOf(Map<String, dynamic> j) =>
      _dt(j['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _dtOr(dynamic v, DateTime fallback) => _dt(v) ?? fallback;
  int _int(dynamic v, [int fallback = 0]) =>
      v is int ? v : (v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? fallback : fallback));
  String _str(dynamic v, [String fallback = '']) => v is String ? v : fallback;
  String? _strn(dynamic v) => v is String ? v : null;
  bool _bool(dynamic v, [bool fallback = false]) => v is bool ? v : fallback;
  double _double(dynamic v, double fallback) =>
      v is num ? v.toDouble() : (v is String ? double.tryParse(v) ?? fallback : fallback);

  String _pad2(int v) => v.toString().padLeft(2, '0');

  // ---------------- (역)직렬화 ----------------
  Map<String, dynamic> _childToJson(Child c) => {
        'id': c.id,
        'name': c.name,
        'stockAccountLabel': c.stockAccountLabel,
        'weeklyAllowanceDefault': c.weeklyAllowanceDefault,
        'payDayOfWeek': c.payDayOfWeek,
        'autoTransferThreshold': c.autoTransferThreshold,
        'bonusEnabled': c.bonusEnabled,
        'bonusDayOfWeek': c.bonusDayOfWeek,
        'bonusThreshold': c.bonusThreshold,
        'bonusAmount': c.bonusAmount,
        'interestEnabled': c.interestEnabled,
        'interestPercent': c.interestPercent,
        'interestPeriod': c.interestPeriod,
        'interestUseBankRate': c.interestUseBankRate,
        'interestMultiplier': c.interestMultiplier,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
        'deletedAt': c.deletedAt?.toIso8601String(),
      };

  ChildrenCompanion _childFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    // avatarPath는 기기 로컬 경로라 동기화하지 않는다(다른 기기에서 무효).
    return ChildrenCompanion.insert(
      id: _str(j['id']),
      name: _str(j['name'], '아이'),
      stockAccountLabel: Value(_strn(j['stockAccountLabel'])),
      weeklyAllowanceDefault: Value(_int(j['weeklyAllowanceDefault'], 0)),
      payDayOfWeek: Value(_int(j['payDayOfWeek'], 1)),
      autoTransferThreshold: Value(_int(j['autoTransferThreshold'], 100000)),
      bonusEnabled: Value(_bool(j['bonusEnabled'], true)),
      bonusDayOfWeek: Value(_int(j['bonusDayOfWeek'], 4)),
      bonusThreshold: Value(_int(j['bonusThreshold'], 1000)),
      bonusAmount: Value(_int(j['bonusAmount'], 500)),
      interestEnabled: Value(_bool(j['interestEnabled'], false)),
      interestPercent: Value(_double(j['interestPercent'], 1.0)),
      interestPeriod: Value(_int(j['interestPeriod'], 0)),
      interestUseBankRate: Value(_bool(j['interestUseBankRate'], true)),
      interestMultiplier: Value(_double(j['interestMultiplier'], 6.0)),
      createdAt: Value(_dtOr(j['createdAt'], now)),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _scheduleToJson(AllowanceSchedule s) => {
        'id': s.id,
        'childId': s.childId,
        'scheduledDate': s.scheduledDate.toIso8601String(),
        'amount': s.amount,
        'isPaid': s.isPaid,
        'paidDate': s.paidDate?.toIso8601String(),
        'editedBy': s.editedBy,
        'updatedAt': s.updatedAt.toIso8601String(),
        'deletedAt': s.deletedAt?.toIso8601String(),
      };

  AllowanceSchedulesCompanion _scheduleFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return AllowanceSchedulesCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      scheduledDate: _dtOr(j['scheduledDate'], now),
      amount: _int(j['amount']),
      isPaid: Value(_bool(j['isPaid'])),
      paidDate: Value(_dt(j['paidDate'])),
      editedBy: Value(_str(j['editedBy'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _txToJson(TransactionEntry t) => {
        'id': t.id,
        'childId': t.childId,
        'date': t.date.toIso8601String(),
        'flow': t.flow,
        'category': t.category,
        'amount': t.amount,
        'memo': t.memo,
        'linkedScheduleId': t.linkedScheduleId,
        'giver': t.giver,
        'editedBy': t.editedBy,
        'updatedAt': t.updatedAt.toIso8601String(),
        'deletedAt': t.deletedAt?.toIso8601String(),
      };

  TransactionEntriesCompanion _txFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return TransactionEntriesCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      date: _dtOr(j['date'], now),
      flow: _str(j['flow'], 'expense'),
      category: _str(j['category'], '기타'),
      amount: _int(j['amount']),
      memo: Value(_strn(j['memo'])),
      linkedScheduleId: Value(_strn(j['linkedScheduleId'])),
      giver: Value(_strn(j['giver'])),
      editedBy: Value(_str(j['editedBy'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _transferToJson(StockTransfer s) => {
        'id': s.id,
        'childId': s.childId,
        'date': s.date.toIso8601String(),
        'amount': s.amount,
        'memo': s.memo,
        'ticker': s.ticker,
        'companyName': s.companyName,
        'shares': s.shares,
        'editedBy': s.editedBy,
        'updatedAt': s.updatedAt.toIso8601String(),
        'deletedAt': s.deletedAt?.toIso8601String(),
      };

  StockTransfersCompanion _transferFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    final sharesRaw = j['shares'];
    return StockTransfersCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      date: _dtOr(j['date'], now),
      amount: _int(j['amount']),
      memo: Value(_strn(j['memo'])),
      ticker: Value(_strn(j['ticker'])),
      companyName: Value(_strn(j['companyName'])),
      shares: Value(sharesRaw is num ? sharesRaw.toDouble() : null),
      editedBy: Value(_str(j['editedBy'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _goalToJson(Goal g) => {
        'id': g.id,
        'childId': g.childId,
        'title': g.title,
        'targetAmount': g.targetAmount,
        'createdAt': g.createdAt.toIso8601String(),
        'achievedAt': g.achievedAt?.toIso8601String(),
        'editedBy': g.editedBy,
        'updatedAt': g.updatedAt.toIso8601String(),
        'deletedAt': g.deletedAt?.toIso8601String(),
      };

  GoalsCompanion _goalFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return GoalsCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      title: _str(j['title'], '목표'),
      targetAmount: _int(j['targetAmount']),
      createdAt: Value(_dtOr(j['createdAt'], now)),
      achievedAt: Value(_dt(j['achievedAt'])),
      editedBy: Value(_str(j['editedBy'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _rateToJson(AllowanceRate r) => {
        'id': r.id,
        'childId': r.childId,
        'amount': r.amount,
        'note': r.note,
        'changedAt': r.changedAt.toIso8601String(),
        'editedBy': r.editedBy,
        'updatedAt': r.updatedAt.toIso8601String(),
        'deletedAt': r.deletedAt?.toIso8601String(),
      };

  AllowanceRatesCompanion _rateFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return AllowanceRatesCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      amount: _int(j['amount']),
      note: Value(_strn(j['note'])),
      changedAt: Value(_dtOr(j['changedAt'], now)),
      editedBy: Value(_str(j['editedBy'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _requestToJson(Request r) => {
        'id': r.id,
        'childId': r.childId,
        'type': r.type,
        'title': r.title,
        'amount': r.amount,
        'memo': r.memo,
        'status': r.status,
        'createdBy': r.createdBy,
        'createdAt': r.createdAt.toIso8601String(),
        'resolvedBy': r.resolvedBy,
        'resolvedAt': r.resolvedAt?.toIso8601String(),
        'editedBy': r.editedBy,
        'updatedAt': r.updatedAt.toIso8601String(),
        'deletedAt': r.deletedAt?.toIso8601String(),
      };

  Map<String, dynamic> _tierToJson(Tier t) => {
        'id': t.id,
        'kind': t.kind,
        'sortOrder': t.sortOrder,
        'threshold': t.threshold,
        'title': t.title,
        'icon': t.icon,
        'reward': t.reward,
        'updatedAt': t.updatedAt.toIso8601String(),
        'deletedAt': t.deletedAt?.toIso8601String(),
      };

  TiersCompanion _tierFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return TiersCompanion.insert(
      id: _str(j['id']),
      kind: _str(j['kind'], 'savings'),
      sortOrder: _int(j['sortOrder']),
      threshold: _int(j['threshold']),
      title: _str(j['title'], '티어'),
      icon: _str(j['icon'], '⭐'),
      reward: Value(_strn(j['reward'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  Map<String, dynamic> _promiseToJson(Promise p) => {
        'id': p.id,
        'childId': p.childId,
        'title': p.title,
        'bonusPercent': p.bonusPercent,
        'enabled': p.enabled,
        'sortOrder': p.sortOrder,
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
        'deletedAt': p.deletedAt?.toIso8601String(),
      };

  PromisesCompanion _promiseFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return PromisesCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      title: _str(j['title'], '약속'),
      bonusPercent: Value(_double(j['bonusPercent'], 0.1)),
      enabled: Value(_bool(j['enabled'], true)),
      sortOrder: Value(_int(j['sortOrder'])),
      createdAt: Value(_dtOr(j['createdAt'], now)),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }

  RequestsCompanion _requestFromJson(Map<String, dynamic> j) {
    final now = DateTime.now();
    return RequestsCompanion.insert(
      id: _str(j['id']),
      childId: _str(j['childId']),
      type: _str(j['type'], 'bonus'),
      title: Value(_strn(j['title'])),
      amount: Value(_int(j['amount'])),
      memo: Value(_strn(j['memo'])),
      status: Value(_str(j['status'], 'pending')),
      createdBy: Value(_str(j['createdBy'])),
      createdAt: Value(_dtOr(j['createdAt'], now)),
      resolvedBy: Value(_strn(j['resolvedBy'])),
      resolvedAt: Value(_dt(j['resolvedAt'])),
      editedBy: Value(_str(j['editedBy'])),
      updatedAt: Value(_dtOr(j['updatedAt'], now)),
      deletedAt: Value(_dt(j['deletedAt'])),
    );
  }
}

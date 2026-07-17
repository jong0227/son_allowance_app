import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

/// 자녀 프로필. 지금은 아들 한 명만 쓰지만 다자녀 확장 가능하도록 별도 테이블로 분리.
/// drift의 자동 단수화는 "Children"(불규칙 복수형)을 "Child"로 바꾸지 못하므로 명시 지정.
@DataClassName('Child')
class Children extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get stockAccountLabel => text().nullable()();
  /// 프로필 사진 파일 경로 (기기 로컬. 동기화 시에는 전파하지 않음)
  TextColumn get avatarPath => text().nullable()();
  IntColumn get weeklyAllowanceDefault => integer().withDefault(const Constant(0))();
  IntColumn get payDayOfWeek => integer().withDefault(const Constant(1))(); // 1=Mon..7=Sun
  IntColumn get autoTransferThreshold => integer().withDefault(const Constant(100000))();
  // 조건부 절약 보너스 규칙 (예: 매주 목요일까지 1000원 이상 남아있으면 500원 추가)
  BoolColumn get bonusEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get bonusDayOfWeek => integer().withDefault(const Constant(4))(); // 4=목
  IntColumn get bonusThreshold => integer().withDefault(const Constant(1000))();
  IntColumn get bonusAmount => integer().withDefault(const Constant(500))();
  // 저축 이자 규칙 (잔액에 주기적으로 이자를 붙여 저축 장려)
  BoolColumn get interestEnabled => boolean().withDefault(const Constant(false))();
  RealColumn get interestPercent => real().withDefault(const Constant(1.0))(); // 회당 %
  IntColumn get interestPeriod => integer().withDefault(const Constant(1))(); // 0=주간,1=월간
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 정기 용돈 지급 일정 (매주 자동 생성, 지급 여부 체크)
class AllowanceSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get scheduledDate => dateTime()();
  IntColumn get amount => integer()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidDate => dateTime().nullable()();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 수입(정기용돈/명절/생일/기타보너스) + 지출 통합 내역
class TransactionEntries extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get flow => text()(); // 'income' | 'expense'
  TextColumn get category => text()();
  IntColumn get amount => integer()();
  TextColumn get memo => text().nullable()();
  TextColumn get linkedScheduleId => text().nullable()();
  /// 특별 수입일 때 "누가 줬는지" (엄마/아빠/할머니 등). 정기용돈·지출에는 사용 안 함.
  TextColumn get giver => text().nullable()();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 주식계좌 이체 이력 (수동 기록형)
class StockTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amount => integer()();
  TextColumn get memo => text().nullable()();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 변경 이력 최소 보관 (누가 언제 무엇을 바꿨는지)
class ChangeLogs extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get editedBy => text()();
  DateTimeColumn get changedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get summary => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 저축 목표(위시리스트). 현재 잔액 대비 진행률로 표시.
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  TextColumn get title => text()();
  IntColumn get targetAmount => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 용돈 인상/변경 이력.
class AllowanceRates extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get changedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Children,
    AllowanceSchedules,
    TransactionEntries,
    StockTransfers,
    ChangeLogs,
    Goals,
    AllowanceRates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(transactionEntries, transactionEntries.giver);
          }
          if (from < 3) {
            await m.addColumn(children, children.avatarPath);
          }
          if (from < 4) {
            await m.addColumn(children, children.bonusEnabled);
            await m.addColumn(children, children.bonusDayOfWeek);
            await m.addColumn(children, children.bonusThreshold);
            await m.addColumn(children, children.bonusAmount);
          }
          if (from < 5) {
            await m.createTable(goals);
            await m.createTable(allowanceRates);
          }
          if (from < 6) {
            await m.addColumn(children, children.interestEnabled);
            await m.addColumn(children, children.interestPercent);
            await m.addColumn(children, children.interestPeriod);
          }
        },
      );

  /// 시스템 예약 카테고리 (사용자 편집 목록과 분리)
  static const kRegularAllowance = '정기용돈';
  static const kSavingsBonus = '절약보너스';
  static const kInterest = '이자';

  // ---------------- Children ----------------
  Stream<List<Child>> watchChildren() =>
      (select(children)..where((t) => t.deletedAt.isNull())).watch();

  Future<void> upsertChild(ChildrenCompanion c) => into(children).insertOnConflictUpdate(c);

  Future<void> updateChildAvatar(String childId, String path) =>
      (update(children)..where((t) => t.id.equals(childId))).write(ChildrenCompanion(
        avatarPath: Value(path),
        updatedAt: Value(DateTime.now()),
      ));

  // ----- 동기화(Export/Import)용: 삭제된 것 포함 전체 조회 -----
  Future<List<Child>> allChildrenRaw() => select(children).get();
  Future<List<AllowanceSchedule>> allSchedulesRaw() => select(allowanceSchedules).get();
  Future<List<TransactionEntry>> allTransactionsRaw() => select(transactionEntries).get();
  Future<List<StockTransfer>> allStockTransfersRaw() => select(stockTransfers).get();

  /// 서로 다른 기기에서 각각 온보딩하면 아이 프로필이 2개(서로 다른 id) 생긴다.
  /// Import 후/앱 시작 시 이걸 호출해 "데이터가 가장 많은 프로필 하나"로 정리한다.
  /// - 데이터가 가장 많은 프로필을 대표(primary)로 선택해서 반환
  /// - 나머지 중 "완전히 빈(거래·이체 0)" 프로필은 소프트 삭제(온보딩 잔여물 정리)
  /// - 실제 데이터가 있는 다른 프로필은 지우지 않음(데이터 보존)
  Future<String?> reconcileToSingleChild(String editedBy) async {
    final kids = await (select(children)..where((t) => t.deletedAt.isNull())).get();
    if (kids.isEmpty) return null;
    if (kids.length == 1) return kids.first.id;

    Future<int> txCount(String cid) async => (await (select(transactionEntries)
              ..where((t) => t.childId.equals(cid) & t.deletedAt.isNull()))
            .get())
        .length;
    Future<int> trCount(String cid) async => (await (select(stockTransfers)
              ..where((t) => t.childId.equals(cid) & t.deletedAt.isNull()))
            .get())
        .length;

    String primary = kids.first.id;
    int bestScore = -1;
    final scores = <String, int>{};
    for (final k in kids) {
      final score = await txCount(k.id) + await trCount(k.id);
      scores[k.id] = score;
      if (score > bestScore) {
        bestScore = score;
        primary = k.id;
      }
    }
    // 대표가 아니면서 완전히 빈 프로필만 정리
    final now = DateTime.now();
    for (final k in kids) {
      if (k.id == primary) continue;
      if ((scores[k.id] ?? 0) == 0) {
        await (update(children)..where((t) => t.id.equals(k.id))).write(
          ChildrenCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      }
    }
    return primary;
  }

  // ---------------- Allowance schedules ----------------
  Stream<List<AllowanceSchedule>> watchSchedules(String childId) => (select(allowanceSchedules)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.scheduledDate)]))
      .watch();

  Future<void> upsertSchedule(AllowanceSchedulesCompanion s) =>
      into(allowanceSchedules).insertOnConflictUpdate(s);

  /// 용돈 "지급" 처리. 부분 컬럼만 갱신하므로 upsert가 아니라 update로 처리한다.
  /// (upsert에 일부 컬럼만 넘기면 NOT NULL 제약으로 실패 → 예전에 지급 버튼이 무반응이던 버그)
  /// 지급과 동시에 연결된 수입 내역을 자동 생성하고, 다음 주 예정 일정을 만든다.
  Future<void> markSchedulePaid(AllowanceSchedule s, String editedBy, Child child) async {
    final now = DateTime.now();
    await (update(allowanceSchedules)..where((t) => t.id.equals(s.id))).write(
      AllowanceSchedulesCompanion(
        isPaid: const Value(true),
        paidDate: Value(now),
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ),
    );
    // 이중 입력 방지: 연결된 거래가 없을 때만 생성
    final existing = await findTransactionByScheduleId(s.id);
    if (existing == null) {
      await upsertTransaction(TransactionEntriesCompanion.insert(
        id: const Uuid().v4(),
        childId: s.childId,
        date: now,
        flow: 'income',
        category: '정기용돈',
        amount: s.amount,
        linkedScheduleId: Value(s.id),
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ));
    }
    // 지급했으니 다음 예정 일정을 즉시 확보
    await ensureUpcomingSchedule(child, editedBy);
  }

  /// 항상 "미지급 예정 일정 1개"만 유지하는 규칙.
  /// - 미지급 예정 일정이 없으면 지급요일 기준 다음 지급일로 새로 만든다.
  /// - 이미 있으면, 지급요일이 바뀐 경우 그 일정의 날짜만 새 지급요일에 맞춰 갱신한다(중복 생성 안 함).
  /// - 실수로 미지급 예정이 여러 개면 가장 이른 것만 남기고 정리한다.
  /// 덕분에 "월요일 지급 → 지급요일을 화요일로 변경"해도 이중 지급 없이
  /// 다음 예정 용돈만 화요일로 옮겨진다.
  Future<void> ensureUpcomingSchedule(Child child, String editedBy) async {
    final all = await (select(allowanceSchedules)
          ..where((t) => t.childId.equals(child.id) & t.deletedAt.isNull()))
        .get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    // 마지막 지급 완료일 이후 다음 지급일을 계산 (없으면 오늘 기준).
    DateTime? lastPaid;
    for (final s in all.where((s) => s.isPaid)) {
      final d = dateOnly(s.scheduledDate);
      if (lastPaid == null || d.isAfter(lastPaid)) lastPaid = d;
    }
    var target = lastPaid == null
        ? _nextOccurrence(child.payDayOfWeek, today)
        : _nextOccurrence(child.payDayOfWeek, lastPaid.add(const Duration(days: 1)));
    if (target.isBefore(today)) target = _nextOccurrence(child.payDayOfWeek, today);

    final unpaid = all.where((s) => !s.isPaid).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (unpaid.isEmpty) {
      await upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: const Uuid().v4(),
        childId: child.id,
        scheduledDate: target,
        amount: child.weeklyAllowanceDefault,
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ));
    } else {
      final keep = unpaid.first;
      if (!sameDay(keep.scheduledDate, target)) {
        await (update(allowanceSchedules)..where((t) => t.id.equals(keep.id))).write(
          AllowanceSchedulesCompanion(
            scheduledDate: Value(target),
            editedBy: Value(editedBy),
            updatedAt: Value(now),
          ),
        );
      }
      // 미지급 예정이 2개 이상이면 나머지는 소프트 삭제
      for (final extra in unpaid.skip(1)) {
        await (update(allowanceSchedules)..where((t) => t.id.equals(extra.id))).write(
          AllowanceSchedulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      }
    }
  }

  /// 지급 예정 금액 수정 (부분 갱신)
  Future<void> updateScheduleAmount(String id, int amount, String editedBy) =>
      (update(allowanceSchedules)..where((t) => t.id.equals(id))).write(
        AllowanceSchedulesCompanion(
          amount: Value(amount),
          editedBy: Value(editedBy),
          updatedAt: Value(DateTime.now()),
        ),
      );

  DateTime _nextOccurrence(int isoWeekday, DateTime from) {
    var d = from;
    while (d.weekday != isoWeekday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  // ---------------- Transactions (income/expense) ----------------
  Stream<List<TransactionEntry>> watchTransactions(String childId) => (select(transactionEntries)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();

  Future<void> upsertTransaction(TransactionEntriesCompanion t) =>
      into(transactionEntries).insertOnConflictUpdate(t);

  Future<TransactionEntry?> findTransactionByScheduleId(String scheduleId) =>
      (select(transactionEntries)
            ..where((t) => t.linkedScheduleId.equals(scheduleId) & t.deletedAt.isNull()))
          .getSingleOrNull();

  Future<void> softDeleteTransaction(String id, String editedBy) => (update(transactionEntries)
        ..where((t) => t.id.equals(id)))
      .write(TransactionEntriesCompanion(
    deletedAt: Value(DateTime.now()),
    editedBy: Value(editedBy),
    updatedAt: Value(DateTime.now()),
  ));

  /// 내역 삭제. 만약 정기용돈 지급으로 자동 생성된 내역이면, 연결된 일정의 지급을
  /// 함께 취소한다("정기용돈 내역 삭제 = 지급 취소"). 그리고 예정 일정을 재정리한다.
  Future<void> deleteTransaction(TransactionEntry t, String editedBy, Child child) async {
    await softDeleteTransaction(t.id, editedBy);
    if (t.linkedScheduleId != null) {
      await _setSchedulePaid(t.linkedScheduleId!, false, editedBy);
      await ensureUpcomingSchedule(child, editedBy);
    }
  }

  /// 내역 항목 수정 (날짜/금액/카테고리/메모/받은사람 부분 갱신)
  Future<void> updateTransactionFields(
    String id, {
    required DateTime date,
    required int amount,
    required String category,
    String? memo,
    String? giver,
    required String editedBy,
  }) =>
      (update(transactionEntries)..where((t) => t.id.equals(id))).write(
        TransactionEntriesCompanion(
          date: Value(date),
          amount: Value(amount),
          category: Value(category),
          memo: Value(memo),
          giver: Value(giver),
          editedBy: Value(editedBy),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> _setSchedulePaid(String scheduleId, bool paid, String editedBy) =>
      (update(allowanceSchedules)..where((t) => t.id.equals(scheduleId))).write(
        AllowanceSchedulesCompanion(
          isPaid: Value(paid),
          paidDate: Value(paid ? DateTime.now() : null),
          editedBy: Value(editedBy),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// 지급 취소: 일정을 미지급으로 되돌리고 연결된 정기용돈 내역을 삭제한 뒤 예정 일정을 재정리.
  Future<void> markScheduleUnpaid(AllowanceSchedule s, String editedBy, Child child) async {
    await _setSchedulePaid(s.id, false, editedBy);
    final linked = await findTransactionByScheduleId(s.id);
    if (linked != null) {
      await softDeleteTransaction(linked.id, editedBy);
    }
    await ensureUpcomingSchedule(child, editedBy);
  }

  /// 조건부 절약 보너스 지급 (원버튼). 이번 주에 이미 받았으면 중복 지급하지 않는다.
  Future<bool> giveSavingsBonus(Child child, String editedBy) async {
    final now = DateTime.now();
    if (await bonusGivenThisWeek(child.id)) return false;
    await upsertTransaction(TransactionEntriesCompanion.insert(
      id: const Uuid().v4(),
      childId: child.id,
      date: now,
      flow: 'income',
      category: kSavingsBonus,
      amount: child.bonusAmount,
      memo: const Value('절약 목표 달성 보너스'),
      editedBy: Value(editedBy),
      updatedAt: Value(now),
    ));
    return true;
  }

  Future<bool> bonusGivenThisWeek(String childId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final rows = await (select(transactionEntries)
          ..where((t) =>
              t.childId.equals(childId) &
              t.deletedAt.isNull() &
              t.category.equals(kSavingsBonus) &
              t.date.isBiggerOrEqualValue(weekStart) &
              t.date.isSmallerThanValue(weekEnd)))
        .get();
    return rows.isNotEmpty;
  }

  // ---------------- 저축 이자 ----------------
  /// 현재 주기(주간/월간)의 시작 시각.
  DateTime _periodStart(int period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (period == 0) {
      return today.subtract(Duration(days: now.weekday - 1)); // 이번 주 월요일
    }
    return DateTime(now.year, now.month, 1); // 이번 달 1일
  }

  Future<bool> interestGivenThisPeriod(String childId, int period) async {
    final start = _periodStart(period, DateTime.now());
    final rows = await (select(transactionEntries)
          ..where((t) =>
              t.childId.equals(childId) &
              t.deletedAt.isNull() &
              t.category.equals(kInterest) &
              t.date.isBiggerOrEqualValue(start)))
        .get();
    return rows.isNotEmpty;
  }

  /// 이번 주기에 지급 가능한 이자 금액(현재 잔액 × 이율). 원 단위 반올림.
  Future<int> pendingInterestAmount(Child child) async {
    final summary = await computeSummary(child.id);
    final balance = summary['balance'] ?? 0;
    if (balance <= 0) return 0;
    return (balance * child.interestPercent / 100).round();
  }

  /// 이자 지급 (원버튼). 이번 주기에 이미 받았으면 false 반환.
  Future<bool> giveInterest(Child child, String editedBy) async {
    if (await interestGivenThisPeriod(child.id, child.interestPeriod)) return false;
    final amount = await pendingInterestAmount(child);
    if (amount <= 0) return false;
    final now = DateTime.now();
    await upsertTransaction(TransactionEntriesCompanion.insert(
      id: const Uuid().v4(),
      childId: child.id,
      date: now,
      flow: 'income',
      category: kInterest,
      amount: amount,
      memo: Value('저축 이자 ${child.interestPercent}%'),
      editedBy: Value(editedBy),
      updatedAt: Value(now),
    ));
    return true;
  }

  // ---------------- 연간 통계 ----------------
  /// 연도별 집계. key: 연도, value: {regular, special, bonus, interest, expense, transfer}
  Future<Map<int, Map<String, int>>> yearlyBreakdown(String childId) async {
    final txs = await (select(transactionEntries)
          ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull()))
        .get();
    final transfers = await (select(stockTransfers)
          ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull()))
        .get();
    final map = <int, Map<String, int>>{};
    Map<String, int> yearOf(int y) => map.putIfAbsent(
        y,
        () => {
              'regular': 0,
              'special': 0,
              'bonus': 0,
              'interest': 0,
              'expense': 0,
              'transfer': 0,
            });
    for (final t in txs) {
      final y = yearOf(t.date.year);
      if (t.flow == 'expense') {
        y['expense'] = y['expense']! + t.amount;
      } else {
        switch (t.category) {
          case kRegularAllowance:
            y['regular'] = y['regular']! + t.amount;
          case kSavingsBonus:
            y['bonus'] = y['bonus']! + t.amount;
          case kInterest:
            y['interest'] = y['interest']! + t.amount;
          default:
            y['special'] = y['special']! + t.amount;
        }
      }
    }
    for (final s in transfers) {
      final y = yearOf(s.date.year);
      y['transfer'] = y['transfer']! + s.amount;
    }
    return map;
  }

  // ---------------- Stock transfers ----------------
  Stream<List<StockTransfer>> watchStockTransfers(String childId) => (select(stockTransfers)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();

  Future<void> upsertStockTransfer(StockTransfersCompanion s) =>
      into(stockTransfers).insertOnConflictUpdate(s);

  // ---------------- Change log ----------------
  Future<void> addChangeLog(ChangeLogsCompanion c) => into(changeLogs).insertOnConflictUpdate(c);

  Stream<List<ChangeLog>> watchChangeLogs() =>
      (select(changeLogs)..orderBy([(t) => OrderingTerm.desc(t.changedAt)])).watch();

  // ---------------- 저축 목표 ----------------
  Stream<List<Goal>> watchGoals(String childId) => (select(goals)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  Future<void> upsertGoal(GoalsCompanion g) => into(goals).insertOnConflictUpdate(g);

  Future<void> softDeleteGoal(String id, String editedBy) =>
      (update(goals)..where((t) => t.id.equals(id))).write(GoalsCompanion(
        deletedAt: Value(DateTime.now()),
        editedBy: Value(editedBy),
        updatedAt: Value(DateTime.now()),
      ));

  Future<void> updateGoalFields(String id,
          {required String title, required int targetAmount, required String editedBy}) =>
      (update(goals)..where((t) => t.id.equals(id))).write(GoalsCompanion(
        title: Value(title),
        targetAmount: Value(targetAmount),
        editedBy: Value(editedBy),
        updatedAt: Value(DateTime.now()),
      ));

  Future<void> setGoalAchieved(String id, bool achieved, String editedBy) =>
      (update(goals)..where((t) => t.id.equals(id))).write(GoalsCompanion(
        achievedAt: Value(achieved ? DateTime.now() : null),
        editedBy: Value(editedBy),
        updatedAt: Value(DateTime.now()),
      ));

  Future<List<Goal>> allGoalsRaw() => select(goals).get();

  // ---------------- 용돈 변경 이력 ----------------
  Stream<List<AllowanceRate>> watchAllowanceRates(String childId) => (select(allowanceRates)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.changedAt)]))
      .watch();

  Future<void> addAllowanceRate(String childId, int amount, String editedBy) =>
      into(allowanceRates).insert(AllowanceRatesCompanion.insert(
        id: const Uuid().v4(),
        childId: childId,
        amount: amount,
        editedBy: Value(editedBy),
      ));

  Future<void> upsertAllowanceRate(AllowanceRatesCompanion r) =>
      into(allowanceRates).insertOnConflictUpdate(r);

  Future<List<AllowanceRate>> allAllowanceRatesRaw() => select(allowanceRates).get();

  // ---------------- Aggregates for dashboard ----------------
  Future<Map<String, int>> computeSummary(String childId) async {
    final txs = await (select(transactionEntries)
          ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull()))
        .get();
    final transfers = await (select(stockTransfers)
          ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull()))
        .get();

    int totalRegularIncome = 0;
    int totalSpecialIncome = 0;
    int totalExpense = 0;
    for (final t in txs) {
      if (t.flow == 'income') {
        if (t.category == '정기용돈') {
          totalRegularIncome += t.amount;
        } else {
          totalSpecialIncome += t.amount;
        }
      } else {
        totalExpense += t.amount;
      }
    }
    final totalTransfer = transfers.fold<int>(0, (sum, s) => sum + s.amount);
    final totalIncome = totalRegularIncome + totalSpecialIncome;
    final balance = totalIncome - totalExpense - totalTransfer;
    final totalSavings = totalTransfer + balance;

    return {
      'totalRegularIncome': totalRegularIncome,
      'totalSpecialIncome': totalSpecialIncome,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'totalTransfer': totalTransfer,
      'balance': balance,
      'totalSavings': totalSavings,
    };
  }

  /// 받은 사람별 특별 수입 합계 (정기용돈/보너스 등 준 사람 없는 수입은 제외)
  Future<Map<String, int>> incomeByGiver(String childId) async {
    final txs = await (select(transactionEntries)
          ..where((t) =>
              t.childId.equals(childId) & t.deletedAt.isNull() & t.flow.equals('income')))
        .get();
    final map = <String, int>{};
    for (final t in txs) {
      final g = t.giver;
      if (g == null || g.isEmpty) continue;
      map[g] = (map[g] ?? 0) + t.amount;
    }
    return map;
  }

  Future<Map<String, int>> expenseByCategory(String childId) async {
    final txs = await (select(transactionEntries)
          ..where((t) =>
              t.childId.equals(childId) & t.deletedAt.isNull() & t.flow.equals('expense')))
        .get();
    final map = <String, int>{};
    for (final t in txs) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// key: 'yyyy-MM' -> {income: x, expense: y}
  Future<Map<String, Map<String, int>>> monthlyIncomeExpense(String childId) async {
    final txs = await (select(transactionEntries)
          ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull()))
        .get();
    final map = <String, Map<String, int>>{};
    for (final t in txs) {
      final key =
          '${t.date.year.toString().padLeft(4, '0')}-${t.date.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => {'income': 0, 'expense': 0});
      if (t.flow == 'income') {
        map[key]!['income'] = map[key]!['income']! + t.amount;
      } else {
        map[key]!['expense'] = map[key]!['expense']! + t.amount;
      }
    }
    return map;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'son_allowance.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

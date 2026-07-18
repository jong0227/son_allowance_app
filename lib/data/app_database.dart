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

/// 주식계좌 이체 이력 (수동 기록형).
/// amount = 이 종목 매수에 들어간 금액(원). 종목 정보(ticker/회사명/수량)는 선택.
class StockTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amount => integer()();
  TextColumn get memo => text().nullable()();
  // 매수한 종목 정보(자녀 요청 기반 매수 시 채워짐)
  TextColumn get ticker => text().nullable()();
  TextColumn get companyName => text().nullable()();
  RealColumn get shares => real().nullable()();
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
  TextColumn get note => text().nullable()(); // 변경 사유 코멘트
  DateTimeColumn get changedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 자녀가 부모에게 보내는 요청. 자녀 모드에서 생성하고, 부모 모드에서 승인/거절한다.
/// - type='bonus': 절약 보너스 지급 요청 (amount = 보너스 금액)
/// - type='wishlist': 위시리스트(저축 목표) 등록 요청 (title=품목, amount=목표금액)
/// 승인 시 각각 보너스 수입 내역 / 저축 목표가 자동 생성된다.
class Requests extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  TextColumn get type => text()(); // 'bonus' | 'wishlist'
  TextColumn get title => text().nullable()();
  IntColumn get amount => integer().withDefault(const Constant(0))();
  TextColumn get memo => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending|approved|rejected
  TextColumn get createdBy => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get resolvedBy => text().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  TextColumn get editedBy => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 저축 티어(등급) 설정. kind='savings'(누적 저축액 기준, threshold=원) 또는
/// kind='weekly'(주간 저축률 기준, threshold=퍼센트 하한). 부모가 수정하고
/// 가족 동기화로 공유된다. 기본값은 앱 첫 실행 시 시드된다.
class Tiers extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()(); // 'savings' | 'weekly'
  IntColumn get sortOrder => integer()();
  IntColumn get threshold => integer()(); // savings: 원, weekly: %
  TextColumn get title => text()();
  TextColumn get icon => text()(); // 이모지
  TextColumn get reward => text().nullable()();
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
    Requests,
    Tiers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 10;

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
          if (from < 7) {
            await m.createTable(requests);
          }
          if (from < 8) {
            await m.addColumn(stockTransfers, stockTransfers.ticker);
            await m.addColumn(stockTransfers, stockTransfers.companyName);
            await m.addColumn(stockTransfers, stockTransfers.shares);
          }
          if (from < 9) {
            await m.addColumn(allowanceRates, allowanceRates.note);
          }
          if (from < 10) {
            await m.createTable(tiers);
          }
        },
      );

  /// 시스템 예약 카테고리 (사용자 편집 목록과 분리)
  static const kRegularAllowance = '정기용돈';
  static const kSavingsBonus = '절약보너스';
  static const kInterest = '이자';
  static const kInitialBalance = '이월잔액';

  // ---------------- 시작 잔액(앱 사용 전부터 모은 용돈) ----------------
  /// 자녀당 1건만 존재하는 특수 수입 항목. 설정 화면에서만 생성/수정하며,
  /// 있으면 편집, 없으면 새로 만드는 방식이라 upsert 대신 조회 후 분기한다.
  Future<TransactionEntry?> findInitialBalance(String childId) => (select(transactionEntries)
        ..where((t) =>
            t.childId.equals(childId) &
            t.category.equals(kInitialBalance) &
            t.deletedAt.isNull()))
      .getSingleOrNull();

  // ---------------- Children ----------------
  Stream<List<Child>> watchChildren() =>
      (select(children)..where((t) => t.deletedAt.isNull())).watch();

  Future<void> upsertChild(ChildrenCompanion c) => into(children).insertOnConflictUpdate(c);

  /// 기존 자녀의 일부 컬럼만 갱신. upsert는 INSERT 경로에서 name(NOT NULL) 등이
  /// 없으면 실패하므로, 부분 갱신은 반드시 update().write()로 처리한다.
  Future<void> updateChildPartial(String id, ChildrenCompanion changes) =>
      (update(children)..where((t) => t.id.equals(id))).write(changes);

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

  /// 과거 날짜의 정기용돈을 소급 지급한다.
  /// 자동 백필은 "마지막 지급일 이후"만 채우므로, 지급 기록이 전혀 없거나 앱을
  /// 늦게 시작한 경우 그 이전 주는 나타나지 않는다. 이 메서드로 부모가 특정 과거
  /// 지급일을 직접 지정해 지급 처리할 수 있다.
  /// - 해당 날짜(±0일)에 이미 일정이 있으면 그것을 지급 처리(중복 방지)
  /// - 없으면 지급 완료 상태의 일정 + 그 날짜로 기록된 정기용돈 수입 내역을 생성
  Future<void> addPastAllowance(
      Child child, DateTime date, int amount, String editedBy) async {
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);

    // 같은 날짜의 기존 일정이 있으면 재활용
    final existing = await (select(allowanceSchedules)
          ..where((t) => t.childId.equals(child.id) & t.deletedAt.isNull()))
        .get();
    AllowanceSchedule? sameDay;
    for (final s in existing) {
      final sd = DateTime(s.scheduledDate.year, s.scheduledDate.month, s.scheduledDate.day);
      if (sd == d) {
        sameDay = s;
        break;
      }
    }

    final scheduleId = sameDay?.id ?? const Uuid().v4();
    if (sameDay == null) {
      await upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: scheduleId,
        childId: child.id,
        scheduledDate: d,
        amount: amount,
        isPaid: const Value(true),
        paidDate: Value(now),
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ));
    } else {
      await (update(allowanceSchedules)..where((t) => t.id.equals(scheduleId))).write(
        AllowanceSchedulesCompanion(
          amount: Value(amount),
          isPaid: const Value(true),
          paidDate: Value(now),
          editedBy: Value(editedBy),
          updatedAt: Value(now),
        ),
      );
    }
    // 연결된 정기용돈 수입 내역이 없으면 과거 날짜로 생성
    final linked = await findTransactionByScheduleId(scheduleId);
    if (linked == null) {
      await upsertTransaction(TransactionEntriesCompanion.insert(
        id: const Uuid().v4(),
        childId: child.id,
        date: d,
        flow: 'income',
        category: kRegularAllowance,
        amount: amount,
        memo: Value('${d.month}/${d.day} 정기용돈 (소급 지급)'),
        linkedScheduleId: Value(scheduleId),
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ));
    }
  }

  /// 용돈 "지급" 처리. 부분 컬럼만 갱신하므로 upsert가 아니라 update로 처리한다.
  /// (upsert에 일부 컬럼만 넘기면 NOT NULL 제약으로 실패 → 예전에 지급 버튼이 무반응이던 버그)
  /// 지급과 동시에 연결된 수입 내역을 자동 생성하고, 다음 주 예정 일정을 만든다.
  /// 밀린 주(예정일이 오늘 이전)를 늦게 지급하면 내역 메모에 원래 예정일을 남긴다.
  Future<void> markSchedulePaid(AllowanceSchedule s, String editedBy, Child child) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sched = DateTime(s.scheduledDate.year, s.scheduledDate.month, s.scheduledDate.day);
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
      final late = sched.isBefore(today);
      await upsertTransaction(TransactionEntriesCompanion.insert(
        id: const Uuid().v4(),
        childId: s.childId,
        date: now,
        flow: 'income',
        category: '정기용돈',
        amount: s.amount,
        memo: late ? Value('${sched.month}/${sched.day} 밀린 용돈') : const Value.absent(),
        linkedScheduleId: Value(s.id),
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ));
    }
    // 지급했으니 다음 예정 일정을 즉시 확보
    await ensureUpcomingSchedule(child, editedBy);
  }

  /// 밀린 용돈 "건너뛰기": 그 주는 안 주기로 하고 목록에서 제거(소프트 삭제).
  /// 소프트 삭제된 일정은 백필 시 다시 생성되지 않으므로 영구히 건너뛴 것으로 남는다.
  Future<void> skipSchedule(AllowanceSchedule s, String editedBy) async {
    final now = DateTime.now();
    await (update(allowanceSchedules)..where((t) => t.id.equals(s.id))).write(
      AllowanceSchedulesCompanion(
        deletedAt: Value(now),
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ),
    );
  }

  /// 정기 용돈 일정 유지 규칙 (v1.4 개편: "밀린 용돈" 지원).
  /// 예전에는 미지급 일정을 1개만 유지하며 날짜가 지나면 다음 지급일로 밀어버려서
  /// 못 준 주가 기록 없이 사라졌다. 이제는:
  /// 1. 같은 날짜에 일정이 2개 이상이면 하나만 남긴다 (부부 동기화로 양쪽 기기가
  ///    각자 자동 생성한 중복 정리. 지급된 것 우선 보존, 이중 수입 내역도 정리).
  /// 2. 지급요일이 바뀌면 "오늘 이후" 미지급 일정만 새 요일로 옮긴다.
  ///    지난 미지급(밀린 용돈)은 역사적 사실이므로 그대로 둔다.
  /// 3. 마지막 지급 완료일 이후 ~ 다음 지급일까지 매주 지급일마다 일정을 백필한다.
  ///    → 못 준 주는 "밀린 용돈"으로 화면에 남고, 나중에 지급하거나 건너뛸 수 있다.
  ///    건너뛴(소프트 삭제) 날짜는 다시 만들지 않는다. 백필은 최근 12건까지만.
  Future<void> ensureUpcomingSchedule(Child child, String editedBy) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    // 소프트 삭제 포함 전체 (건너뛴 날짜에 재생성하지 않기 위해 필요)
    final allRows = await (select(allowanceSchedules)
          ..where((t) => t.childId.equals(child.id)))
        .get();
    var alive = allRows.where((s) => s.deletedAt == null).toList();

    // ---- 1) 같은 날짜 중복 정리 (동기화 산물) ----
    final byDay = <DateTime, List<AllowanceSchedule>>{};
    for (final s in alive) {
      byDay.putIfAbsent(dateOnly(s.scheduledDate), () => []).add(s);
    }
    final removedIds = <String>{};
    for (final entry in byDay.entries) {
      if (entry.value.length <= 1) continue;
      // 지급된 것 우선, 그다음 id 순으로 대표 1개만 남긴다
      final list = entry.value
        ..sort((a, b) {
          if (a.isPaid != b.isPaid) return a.isPaid ? -1 : 1;
          return a.id.compareTo(b.id);
        });
      final keep = list.first;
      for (final dup in list.skip(1)) {
        removedIds.add(dup.id);
        await (update(allowanceSchedules)..where((t) => t.id.equals(dup.id))).write(
          AllowanceSchedulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
        // 둘 다 지급됐던 중복이면 수입 내역도 이중 계상되므로 중복분 내역을 정리
        if (keep.isPaid && dup.isPaid) {
          final linked = await findTransactionByScheduleId(dup.id);
          if (linked != null) await softDeleteTransaction(linked.id, editedBy);
        }
      }
    }
    alive = alive.where((s) => !removedIds.contains(s.id)).toList();

    final nextUpcoming = _nextOccurrence(child.payDayOfWeek, today);

    // ---- 1.5) 너무 먼 미래(다음 지급일 이후)의 미지급 일정 정리 ----
    // 규칙상 미래 예정은 nextUpcoming 1개까지만 유지. 예전 로직이 만든
    // 다다음주 등 잉여 미래 일정을 제거해 표시 기준을 명확히 한다.
    for (final s in alive.where(
        (s) => !s.isPaid && dateOnly(s.scheduledDate).isAfter(nextUpcoming))) {
      removedIds.add(s.id);
      await (update(allowanceSchedules)..where((t) => t.id.equals(s.id))).write(
        AllowanceSchedulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
    }
    alive = alive.where((s) => !removedIds.contains(s.id)).toList();

    // ---- 2) 지급요일 변경: 오늘 이후 미지급 일정만 새 요일로 이동 ----
    final hasAtNext = alive.any((s) => dateOnly(s.scheduledDate) == nextUpcoming);
    for (final s in alive.where((s) =>
        !s.isPaid &&
        !dateOnly(s.scheduledDate).isBefore(today) &&
        s.scheduledDate.weekday != child.payDayOfWeek)) {
      if (hasAtNext) {
        // 새 지급일에 이미 일정이 있으면 중복 방지 위해 이 일정은 제거
        await (update(allowanceSchedules)..where((t) => t.id.equals(s.id))).write(
          AllowanceSchedulesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      } else {
        await (update(allowanceSchedules)..where((t) => t.id.equals(s.id))).write(
          AllowanceSchedulesCompanion(
            scheduledDate: Value(nextUpcoming),
            editedBy: Value(editedBy),
            updatedAt: Value(now),
          ),
        );
      }
    }
    // 이동 반영 후 최신 상태로 다시 조회
    final refreshed = await (select(allowanceSchedules)
          ..where((t) => t.childId.equals(child.id)))
        .get();

    // ---- 3) 백필: 마지막 지급 완료일 다음부터 다음 지급일까지 ----
    DateTime? lastPaid;
    for (final s in refreshed.where((s) => s.isPaid && s.deletedAt == null)) {
      final d = dateOnly(s.scheduledDate);
      if (lastPaid == null || d.isAfter(lastPaid)) lastPaid = d;
    }
    // 건너뛴(삭제된) 것 포함, 이미 일정이 있는 "주"에는 만들지 않는다.
    // 지급요일이 바뀌었어도 ±3일 안에 일정이 있으면 같은 주기의 용돈으로 간주
    // (지급일 간격이 7일이라 ±3일 창은 이웃 후보와 겹치지 않는다).
    final existingDates = refreshed.map((s) => dateOnly(s.scheduledDate)).toList();
    bool weekOccupied(DateTime d) =>
        existingDates.any((e) => (e.difference(d).inDays).abs() <= 3);

    // 규칙(명확화): 미래 예정 일정은 "오늘 이후 첫 지급일(nextUpcoming)" 딱 1개까지만
    // 만든다. 다다음주 등 그 이상 미래는 만들지 않는다(예: 이번 주를 미리 지급해도
    // 다음 주 예정을 미리 만들지 않음 — 지급일이 지나면 자연히 생성됨).
    // 과거(밀린) 지급일은 마지막 지급일 다음부터 오늘까지 전부 채운다.
    final horizon = nextUpcoming;
    var candidates = <DateTime>[];
    var d = lastPaid == null
        ? nextUpcoming
        : _nextOccurrence(child.payDayOfWeek, lastPaid.add(const Duration(days: 1)));
    while (!d.isAfter(horizon)) {
      candidates.add(d);
      d = _nextOccurrence(child.payDayOfWeek, d.add(const Duration(days: 1)));
    }
    // 오래 방치했을 때 수십 개가 쏟아지지 않게 최근 12건으로 제한
    if (candidates.length > 12) {
      candidates = candidates.sublist(candidates.length - 12);
    }
    for (final date in candidates) {
      if (weekOccupied(date)) continue;
      await upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: const Uuid().v4(),
        childId: child.id,
        scheduledDate: date,
        amount: child.weeklyAllowanceDefault,
        editedBy: Value(editedBy),
        updatedAt: Value(now),
      ));
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
      // 시작 잔액(이월잔액)은 연간 수입 통계에서 제외
      if (t.flow == 'income' && t.category == kInitialBalance) continue;
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

  // ---------------- 자녀 요청 (보너스/위시리스트) ----------------
  Stream<List<Request>> watchRequests(String childId) => (select(requests)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  /// 대기 중(pending) 요청만. 부모 홈 화면의 "요청함"에 표시.
  Stream<List<Request>> watchPendingRequests(String childId) => (select(requests)
        ..where((t) =>
            t.childId.equals(childId) &
            t.deletedAt.isNull() &
            t.status.equals('pending'))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  Future<void> upsertRequest(RequestsCompanion r) =>
      into(requests).insertOnConflictUpdate(r);

  Future<List<Request>> allRequestsRaw() => select(requests).get();

  /// 자녀가 보너스 지급을 요청. 이미 대기 중인 보너스 요청이 있으면 중복 생성하지 않는다.
  Future<bool> requestBonus(Child child, String createdBy) async {
    final pending = await (select(requests)
          ..where((t) =>
              t.childId.equals(child.id) &
              t.deletedAt.isNull() &
              t.type.equals('bonus') &
              t.status.equals('pending')))
        .get();
    if (pending.isNotEmpty) return false;
    final now = DateTime.now();
    await upsertRequest(RequestsCompanion.insert(
      id: const Uuid().v4(),
      childId: child.id,
      type: 'bonus',
      amount: Value(child.bonusAmount),
      memo: const Value('절약 보너스 지급 요청'),
      createdBy: Value(createdBy),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    return true;
  }

  /// 자녀가 위시리스트(저축 목표) 등록을 요청.
  Future<void> requestWishlist(
      Child child, String title, int targetAmount, String createdBy) async {
    final now = DateTime.now();
    await upsertRequest(RequestsCompanion.insert(
      id: const Uuid().v4(),
      childId: child.id,
      type: 'wishlist',
      title: Value(title),
      amount: Value(targetAmount),
      createdBy: Value(createdBy),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// 자녀가 "○○ 주식 얼마치 사주세요" 요청.
  /// title=회사명, memo=티커(symbol), amount=요청 금액(원).
  Future<void> requestStock(
      Child child, String companyName, String ticker, int amount, String createdBy) async {
    final now = DateTime.now();
    await upsertRequest(RequestsCompanion.insert(
      id: const Uuid().v4(),
      childId: child.id,
      type: 'stock',
      title: Value(companyName),
      memo: Value(ticker),
      amount: Value(amount),
      createdBy: Value(createdBy),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  /// 부모가 주식 요청을 실제 매수하고 결과를 입력해 승인.
  /// 주식계좌 이체(매수) 내역을 종목 정보와 함께 남기고 요청을 approved 처리한다.
  Future<void> fulfillStockRequest(
    Request r, {
    required int actualAmount,
    double? shares,
    String? memo,
    required String resolvedBy,
  }) async {
    final now = DateTime.now();
    await upsertStockTransfer(StockTransfersCompanion.insert(
      id: const Uuid().v4(),
      childId: r.childId,
      date: now,
      amount: actualAmount,
      memo: Value(memo),
      ticker: Value(r.memo),
      companyName: Value(r.title),
      shares: Value(shares),
      editedBy: Value(resolvedBy),
      updatedAt: Value(now),
    ));
    await (update(requests)..where((t) => t.id.equals(r.id))).write(RequestsCompanion(
      status: const Value('approved'),
      resolvedBy: Value(resolvedBy),
      resolvedAt: Value(now),
      editedBy: Value(resolvedBy),
      updatedAt: Value(now),
    ));
  }

  /// 부모가 요청을 승인. 승인하면 자동으로 반영된다:
  /// - bonus: 절약보너스 수입 내역 생성
  /// - wishlist: 저축 목표 생성
  Future<void> approveRequest(Request r, String resolvedBy) async {
    final now = DateTime.now();
    if (r.type == 'bonus') {
      await upsertTransaction(TransactionEntriesCompanion.insert(
        id: const Uuid().v4(),
        childId: r.childId,
        date: now,
        flow: 'income',
        category: kSavingsBonus,
        amount: r.amount,
        memo: const Value('자녀 요청 승인 보너스'),
        editedBy: Value(resolvedBy),
        updatedAt: Value(now),
      ));
    } else if (r.type == 'wishlist') {
      await upsertGoal(GoalsCompanion.insert(
        id: const Uuid().v4(),
        childId: r.childId,
        title: r.title ?? '위시리스트',
        targetAmount: r.amount,
        editedBy: Value(resolvedBy),
        updatedAt: Value(now),
      ));
    }
    await (update(requests)..where((t) => t.id.equals(r.id))).write(RequestsCompanion(
      status: const Value('approved'),
      resolvedBy: Value(resolvedBy),
      resolvedAt: Value(now),
      editedBy: Value(resolvedBy),
      updatedAt: Value(now),
    ));
  }

  Future<void> rejectRequest(Request r, String resolvedBy) =>
      (update(requests)..where((t) => t.id.equals(r.id))).write(RequestsCompanion(
        status: const Value('rejected'),
        resolvedBy: Value(resolvedBy),
        resolvedAt: Value(DateTime.now()),
        editedBy: Value(resolvedBy),
        updatedAt: Value(DateTime.now()),
      ));

  /// 자녀가 아직 처리되지 않은 자기 요청을 취소(소프트 삭제).
  Future<void> cancelRequest(String id, String editedBy) =>
      (update(requests)..where((t) => t.id.equals(id))).write(RequestsCompanion(
        deletedAt: Value(DateTime.now()),
        editedBy: Value(editedBy),
        updatedAt: Value(DateTime.now()),
      ));

  // ---------------- 저축 티어(등급) ----------------
  Stream<List<Tier>> watchTiers(String kind) => (select(tiers)
        ..where((t) => t.kind.equals(kind) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Future<List<Tier>> allTiersRaw() => select(tiers).get();

  Future<void> upsertTier(TiersCompanion t) => into(tiers).insertOnConflictUpdate(t);

  /// 티어 내용 수정(부모). 수정 시각을 now로 갱신해 동기화 시 우선 반영되게 한다.
  Future<void> updateTierFields(String id,
          {required int threshold, required String title, required String icon, String? reward}) =>
      (update(tiers)..where((t) => t.id.equals(id))).write(TiersCompanion(
        threshold: Value(threshold),
        title: Value(title),
        icon: Value(icon),
        reward: Value(reward),
        updatedAt: Value(DateTime.now()),
      ));

  /// 티어가 하나도 없으면 기본값을 시드한다(앱 첫 실행/신규 기기).
  /// 시드는 고정 과거 시각(updatedAt)을 써서, 부모가 나중에 수정하면(now) 그 값이
  /// 항상 동기화 우선권을 갖도록 한다. 고정 id라 여러 기기가 시드해도 충돌 없음.
  Future<void> seedTiersIfEmpty() async {
    final existing = await (select(tiers)..limit(1)).get();
    if (existing.isNotEmpty) return;
    final seedTime = DateTime(2020, 1, 1);
    for (final t in _defaultTiers) {
      await into(tiers).insertOnConflictUpdate(TiersCompanion.insert(
        id: t.$1,
        kind: t.$2,
        sortOrder: t.$3,
        threshold: t.$4,
        title: t.$5,
        icon: t.$6,
        reward: Value(t.$7),
        updatedAt: Value(seedTime),
      ));
    }
  }

  /// (id, kind, order, threshold, title, icon, reward)
  static const List<(String, String, int, int, String, String, String?)> _defaultTiers = [
    // 누적 저축액 티어 (마인크래프트 테마)
    ('sav_01', 'savings', 1, 0, '흙', '🟫', null),
    ('sav_02', 'savings', 2, 5000, '나무', '🪵', '좋아하는 간식 1개'),
    ('sav_03', 'savings', 3, 10000, '조약돌', '🪨', '마인크래프트 30분 추가'),
    ('sav_04', 'savings', 4, 20000, '석탄', '⬛', '문구점 3천원 쇼핑'),
    ('sav_05', 'savings', 5, 30000, '구리', '🟧', '아이스크림'),
    ('sav_06', 'savings', 6, 40000, '철', '⚙️', '만화책 1권'),
    ('sav_07', 'savings', 7, 50000, '금', '🟨', '치킨 or 피자'),
    ('sav_08', 'savings', 8, 70000, '레드스톤', '🔴', '마크 아이템/스킨'),
    ('sav_09', 'savings', 9, 100000, '청금석', '🔵', '키즈카페'),
    ('sav_10', 'savings', 10, 150000, '에메랄드', '💚', '장난감(2만원 내)'),
    ('sav_11', 'savings', 11, 200000, '다이아몬드', '💎', '레고 세트'),
    ('sav_12', 'savings', 12, 300000, '네더라이트', '🖤', '놀이공원 하루'),
    ('sav_13', 'savings', 13, 500000, '엔더 드래곤', '🐉', '게임 타이틀'),
    ('sav_14', 'savings', 14, 1000000, '비컨', '🔆', '가족여행 선택권'),
    ('sav_15', 'savings', 15, 3000000, '네더의 별', '🌟', '원하는 전자기기'),
    ('sav_16', 'savings', 16, 5000000, '엔드 크리스탈', '🔮', '부모님과 자유 협의'),
    // 주간 저축률 티어 (threshold=퍼센트 하한)
    ('wk_01', 'weekly', 1, 0, '일반 저축가', '🐜', null),
    ('wk_02', 'weekly', 2, 40, '새싹 저축가', '🌱', null),
    ('wk_03', 'weekly', 3, 60, '저축 요정', '⭐', null),
    ('wk_04', 'weekly', 4, 80, '부자 후보자', '💪', null),
    ('wk_05', 'weekly', 5, 100, '완벽 저축왕', '👑', null),
  ];

  // ---------------- 용돈 변경 이력 ----------------
  Stream<List<AllowanceRate>> watchAllowanceRates(String childId) => (select(allowanceRates)
        ..where((t) => t.childId.equals(childId) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.changedAt)]))
      .watch();

  Future<void> addAllowanceRate(String childId, int amount, String editedBy,
          {String? note}) =>
      into(allowanceRates).insert(AllowanceRatesCompanion.insert(
        id: const Uuid().v4(),
        childId: childId,
        amount: amount,
        note: Value(note),
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
    int initialBalance = 0; // 시작 잔액(이월잔액): 잔액엔 포함, "받은 수입" 통계엔 제외
    int totalExpense = 0;
    for (final t in txs) {
      if (t.flow == 'income') {
        if (t.category == kRegularAllowance) {
          totalRegularIncome += t.amount;
        } else if (t.category == kInitialBalance) {
          initialBalance += t.amount;
        } else {
          totalSpecialIncome += t.amount;
        }
      } else {
        totalExpense += t.amount;
      }
    }
    final totalTransfer = transfers.fold<int>(0, (sum, s) => sum + s.amount);
    // "총 수입"은 실제로 받은 것(정기+특별)만. 시작 잔액은 별도.
    final totalIncome = totalRegularIncome + totalSpecialIncome;
    // 잔액은 시작 잔액까지 포함해서 계산.
    final balance = totalIncome + initialBalance - totalExpense - totalTransfer;
    final totalSavings = totalTransfer + balance;

    return {
      'totalRegularIncome': totalRegularIncome,
      'totalSpecialIncome': totalSpecialIncome,
      'initialBalance': initialBalance,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'totalTransfer': totalTransfer,
      'balance': balance,
      'totalSavings': totalSavings,
    };
  }

  /// 시스템 예약 카테고리(정기용돈/절약보너스/이자/이월잔액)인지 여부.
  /// 이들은 "특별수입"이 아니므로 받은사람별 통계에서 제외한다.
  static bool isSystemCategory(String category) =>
      category == kRegularAllowance ||
      category == kSavingsBonus ||
      category == kInterest ||
      category == kInitialBalance;

  /// 받은 사람별 특별 수입 합계.
  /// 정기용돈/절약보너스/이자/이월잔액 같은 시스템 수입은 특별수입이 아니므로 제외한다.
  /// (예전엔 giver 값 유무로만 걸렀는데, 정기용돈 내역을 편집하면 giver가
  ///  실수로 붙어 통계에 잡히던 문제가 있어 카테고리로도 명시적으로 거른다.)
  Future<Map<String, int>> incomeByGiver(String childId) async {
    final txs = await (select(transactionEntries)
          ..where((t) =>
              t.childId.equals(childId) & t.deletedAt.isNull() & t.flow.equals('income')))
        .get();
    final map = <String, int>{};
    for (final t in txs) {
      if (isSystemCategory(t.category)) continue;
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
      // 시작 잔액(이월잔액)은 "받은 수입"이 아니므로 월별 수입 통계에서 제외
      if (t.flow == 'income' && t.category == kInitialBalance) continue;
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

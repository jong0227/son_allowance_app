import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';

/// 정기 용돈 일정 로직(밀린 용돈 백필/건너뛰기/중복 정리) 단위 테스트.
/// ensureUpcomingSchedule이 DateTime.now() 기준으로 동작하므로,
/// 테스트 데이터의 지급요일을 "오늘 요일"로 맞춰 날짜 계산을 단순화한다.
void main() {
  late AppDatabase db;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Future<Child> createChild({int? payDay}) async {
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1',
      name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      payDayOfWeek: Value(payDay ?? today.weekday),
    ));
    return (await db.allChildrenRaw()).first;
  }

  Future<List<AllowanceSchedule>> alive() async =>
      (await db.allSchedulesRaw()).where((s) => s.deletedAt == null).toList();

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  test('처음 실행하면 다음 지급일 일정 1개만 생긴다', () async {
    final child = await createChild();
    await db.ensureUpcomingSchedule(child, 'test');
    final rows = await alive();
    expect(rows.length, 1);
    expect(rows.first.isPaid, false);
    // 지급요일 = 오늘 요일이므로 다음 지급일은 오늘
    expect(DateTime(rows.first.scheduledDate.year, rows.first.scheduledDate.month,
            rows.first.scheduledDate.day), today);
  });

  test('마지막 지급 후 3주 지났으면 밀린 2주 + 이번 주가 백필된다', () async {
    final child = await createChild();
    // 3주 전에 지급 완료한 일정
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'old-paid',
      childId: child.id,
      scheduledDate: today.subtract(const Duration(days: 21)),
      amount: 3000,
      isPaid: const Value(true),
    ));
    await db.ensureUpcomingSchedule(child, 'test');
    final unpaid = (await alive()).where((s) => !s.isPaid).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    // -14일, -7일(밀린 용돈) + 오늘(이번 주) = 3개
    expect(unpaid.length, 3);
    expect(unpaid[0].scheduledDate, today.subtract(const Duration(days: 14)));
    expect(unpaid[1].scheduledDate, today.subtract(const Duration(days: 7)));
    expect(unpaid[2].scheduledDate, today);
  });

  test('건너뛴 주는 다시 생성되지 않는다', () async {
    final child = await createChild();
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'old-paid',
      childId: child.id,
      scheduledDate: today.subtract(const Duration(days: 14)),
      amount: 3000,
      isPaid: const Value(true),
    ));
    await db.ensureUpcomingSchedule(child, 'test');
    // 지난주 밀린 용돈을 건너뛴다
    final missed = (await alive())
        .firstWhere((s) => s.scheduledDate == today.subtract(const Duration(days: 7)));
    await db.skipSchedule(missed, 'test');
    // 다시 실행해도 그 날짜는 부활하지 않는다
    await db.ensureUpcomingSchedule(child, 'test');
    final dates = (await alive()).map((s) => s.scheduledDate).toList();
    expect(dates.contains(today.subtract(const Duration(days: 7))), false);
  });

  test('같은 날짜 중복 일정(동기화 산물)은 하나만 남는다', () async {
    final child = await createChild();
    for (final id in ['dup-a', 'dup-b']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: today,
        amount: 3000,
      ));
    }
    await db.ensureUpcomingSchedule(child, 'test');
    final atToday = (await alive()).where((s) => s.scheduledDate == today);
    expect(atToday.length, 1);
  });

  test('지급하면 정기용돈 내역이 생기고, 밀린 주는 메모에 원래 날짜가 남는다', () async {
    final child = await createChild();
    final missedDate = today.subtract(const Duration(days: 7));
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'missed',
      childId: child.id,
      scheduledDate: missedDate,
      amount: 3000,
    ));
    final missed = (await alive()).first;
    await db.markSchedulePaid(missed, 'test', child);

    final txs = await db.allTransactionsRaw();
    expect(txs.length, 1);
    expect(txs.first.category, '정기용돈');
    expect(txs.first.amount, 3000);
    expect(txs.first.memo, '${missedDate.month}/${missedDate.day} 밀린 용돈');
    // 지급 후 이번 주 예정 일정이 자동 생성된다
    final upcoming = (await alive()).where((s) => !s.isPaid);
    expect(upcoming.isNotEmpty, true);
  });

  test('지급 기록이 전혀 없어도 과거 날짜 정기용돈을 소급 지급할 수 있다', () async {
    final child = await createChild();
    final past = today.subtract(const Duration(days: 5));
    await db.addPastAllowance(child, past, 3000, 'test');

    // 과거 날짜로 지급 완료 일정 + 정기용돈 수입 내역 생성
    final paid = (await alive()).where((s) => s.isPaid).toList();
    expect(paid.length, 1);
    expect(DateTime(paid.first.scheduledDate.year, paid.first.scheduledDate.month,
            paid.first.scheduledDate.day),
        DateTime(past.year, past.month, past.day));

    final txs = (await db.allTransactionsRaw()).where((t) => t.deletedAt == null).toList();
    expect(txs.length, 1);
    expect(txs.first.category, '정기용돈');
    expect(txs.first.amount, 3000);
    // 수입 내역 날짜가 과거 지급일과 같아야 한다
    expect(DateTime(txs.first.date.year, txs.first.date.month, txs.first.date.day),
        DateTime(past.year, past.month, past.day));
    final summary = await db.computeSummary(child.id);
    expect(summary['balance'], 3000);
  });

  test('소급 지급을 두 번 해도 같은 날짜면 중복 지급되지 않는다', () async {
    final child = await createChild();
    final past = today.subtract(const Duration(days: 7));
    await db.addPastAllowance(child, past, 3000, 'test');
    await db.addPastAllowance(child, past, 3000, 'test');
    final txs = (await db.allTransactionsRaw()).where((t) => t.deletedAt == null).toList();
    expect(txs.length, 1);
    expect((await db.computeSummary(child.id))['balance'], 3000);
  });

  test('지급요일 변경 시 미래 예정만 이동하고 밀린 용돈은 그대로 둔다', () async {
    final child = await createChild();
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'old-paid',
      childId: child.id,
      scheduledDate: today.subtract(const Duration(days: 14)),
      amount: 3000,
      isPaid: const Value(true),
    ));
    await db.ensureUpcomingSchedule(child, 'test');
    // 지급요일을 내일 요일로 변경
    final newPayDay = today.add(const Duration(days: 1)).weekday;
    await db.upsertChild(ChildrenCompanion.insert(
      id: child.id,
      name: child.name,
      weeklyAllowanceDefault: Value(child.weeklyAllowanceDefault),
      payDayOfWeek: Value(newPayDay),
    ));
    final updated = (await db.allChildrenRaw()).first;
    await db.ensureUpcomingSchedule(updated, 'test');

    final rows = await alive();
    final overdue = rows
        .where((s) => !s.isPaid && s.scheduledDate.isBefore(today))
        .toList();
    // 밀린 용돈(지난주)은 원래 날짜 그대로
    expect(overdue.length, 1);
    expect(overdue.first.scheduledDate, today.subtract(const Duration(days: 7)));
    // 오늘 이후 예정은 새 요일(내일)로
    final future = rows
        .where((s) => !s.isPaid && !s.scheduledDate.isBefore(today))
        .toList();
    expect(future.length, 1);
    expect(future.first.scheduledDate.weekday, newPayDay);
  });
}

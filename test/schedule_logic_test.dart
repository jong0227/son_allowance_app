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

  test('미래 예정은 다음 지급일 1개만 유지하고, 그 이후 미래 일정은 정리된다', () async {
    final child = await createChild(); // payday = 오늘 요일 → nextUpcoming = 오늘
    // 다다음주(오늘+14)에 잉여 미래 미지급 일정을 심어둔다
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'too-far-future',
      childId: child.id,
      scheduledDate: today.add(const Duration(days: 14)),
      amount: 3000,
    ));
    await db.ensureUpcomingSchedule(child, 'test');

    final futureUnpaid = (await alive())
        .where((s) => !s.isPaid && !s.scheduledDate.isBefore(today))
        .toList();
    // 미래 예정은 오늘(nextUpcoming) 1개만
    expect(futureUnpaid.length, 1);
    expect(futureUnpaid.first.scheduledDate, today);
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

  test('동시에 두 번 호출해도(하단 탭들이 동시에 마운트되는 경우) 이번 주 일정이 중복 생성되지 않는다', () async {
    final child = await createChild();
    // 실제 앱에서는 IndexedStack 때문에 홈/내역 탭이 앱 시작과 동시에 각자
    // ensureUpcomingSchedule을 부른다. await 없이 동시에 쐈을 때도 안전해야 한다.
    await Future.wait([
      db.ensureUpcomingSchedule(child, 'test'),
      db.ensureUpcomingSchedule(child, 'test'),
    ]);
    final atToday = (await alive()).where((s) => s.scheduledDate == today);
    expect(atToday.length, 1);
  });

  test('경합으로 같은 날짜에 소프트 삭제 중복이 여러 개 남아있으면(진짜 건너뛰기는 1개뿐) 자동으로 되살린다', () async {
    final child = await createChild();
    final now = DateTime.now();
    // 진짜 사용자의 "건너뛰기"라면 절대 만들어지지 않는 상태: 같은 날짜에
    // 소프트 삭제된 중복이 2개 이상. 과거 동시 호출 경합이 남긴 쓰레기를 흉내낸다.
    for (final id in ['race-a', 'race-b']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: today,
        amount: 3000,
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
    }
    expect((await alive()).where((s) => s.scheduledDate == today).length, 0);
    await db.ensureUpcomingSchedule(child, 'test');
    final atToday = (await alive()).where((s) => s.scheduledDate == today).toList();
    expect(atToday.length, 1);
    expect(atToday.first.isPaid, false);
  });

  test('이번 주(오늘) 용돈을 지급해도 다음 주 일정이 미리 뜨지 않는다', () async {
    final child = await createChild(); // payday = 오늘 요일 → nextUpcoming = 오늘
    await db.ensureUpcomingSchedule(child, 'test'); // 앱 시작 시 오늘 일정 생성
    final todaySchedule = (await alive()).firstWhere((s) => s.scheduledDate == today);
    await db.markSchedulePaid(todaySchedule, 'test', child); // 실제 '지급' 버튼과 동일 경로

    final rows = await alive();
    expect(rows.where((s) => s.scheduledDate == today && s.isPaid).length, 1);
    final nextWeek = today.add(const Duration(days: 7));
    expect(rows.where((s) => s.scheduledDate == nextWeek).length, 0,
        reason: '다음 지급일(+7일)이 지나기 전엔 예정 일정을 만들지 않아야 한다');
  });

  test('앱을 여러 번 다시 켠 뒤 오늘 용돈을 지급해도 다음 주 일정이 미리 뜨지 않는다', () async {
    final child = await createChild();
    // 실제 기기처럼 여러 번 재실행(하단 탭 동시 마운트 포함)한 뒤 지급하는 상황을 흉내낸다
    await db.ensureUpcomingSchedule(child, 'test');
    await Future.wait(
        [db.ensureUpcomingSchedule(child, 'test'), db.ensureUpcomingSchedule(child, 'test')]);
    await db.ensureUpcomingSchedule(child, 'test');
    final todaySchedule = (await alive()).firstWhere((s) => s.scheduledDate == today);
    await db.markSchedulePaid(todaySchedule, 'test', child);
    // 지급 후에도 정비가 한 번 더 겹칠 수 있다(백그라운드 앱 재개 등)
    await db.ensureUpcomingSchedule(child, 'test');

    final rows = await alive();
    expect(rows.where((s) => s.scheduledDate == today).length, 1);
    final nextWeek = today.add(const Duration(days: 7));
    expect(rows.where((s) => s.scheduledDate == nextWeek).length, 0);
  });

  test('예전 버전이 만들어둔 다음 주 잉여 일정이 남아있어도 재실행하면 정리된다', () async {
    final child = await createChild();
    final nextWeek = today.add(const Duration(days: 7));
    // 오늘(이번 주) 정상 일정 + 예전 버그가 미리 만들어둔 다음 주(+7일) 잉여 일정
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'this-week',
      childId: child.id,
      scheduledDate: today,
      amount: 3000,
    ));
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'leftover-next-week',
      childId: child.id,
      scheduledDate: nextWeek,
      amount: 3000,
    ));
    await db.ensureUpcomingSchedule(child, 'test');
    expect((await alive()).where((s) => s.scheduledDate == nextWeek).length, 0,
        reason: '다음 지급일 이후 잉여 일정은 재실행 시 정리되어야 한다');
    expect((await alive()).where((s) => s.scheduledDate == today).length, 1);
  });

  test('다음 주 잉여 일정이 이미 있는 상태에서 오늘 용돈을 지급해도 그 잉여가 정리된다', () async {
    final child = await createChild();
    final nextWeek = today.add(const Duration(days: 7));
    // ensureUpcomingSchedule을 먼저 부르지 않고, 앱이 이미 이런 상태였다고 가정
    // (예전 버전이 만들어둔 다음 주 잉여 일정이 이미 살아있는 채로 남아있음)
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'this-week',
      childId: child.id,
      scheduledDate: today,
      amount: 3000,
    ));
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'leftover-next-week',
      childId: child.id,
      scheduledDate: nextWeek,
      amount: 3000,
    ));
    final todaySchedule = (await alive()).firstWhere((s) => s.scheduledDate == today);
    await db.markSchedulePaid(todaySchedule, 'test', child); // 실제 '지급' 버튼 경로
    final rows = await alive();
    expect(rows.where((s) => s.scheduledDate == nextWeek).length, 0,
        reason: '지급 버튼을 눌렀을 때도 기존 잉여 일정이 정리되어야 한다');
    expect(rows.where((s) => s.scheduledDate == today && s.isPaid).length, 1);
  });

  test('먼 미래 일정이 중복이라 정리된 것은 자가치유가 되살리지 않는다(무한 반복 방지)', () async {
    final child = await createChild(); // payday = 오늘 요일
    final farFuture = today.add(const Duration(days: 14)); // 요일은 같지만 먼 미래
    for (final id in ['far-a', 'far-b']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: farFuture,
        amount: 3000,
      ));
    }
    // 1) 중복 정리로 1개 삭제 → 2) 먼 미래 정리로 나머지도 삭제 = 같은 날 삭제 2개, 살아있는 것 0개
    await db.ensureUpcomingSchedule(child, 'test');
    expect((await alive()).where((s) => s.scheduledDate == farFuture).length, 0);
    // 다시 호출해도 되살아나면 안 된다(되살아나면 매번 지웠다 살렸다 반복)
    await db.ensureUpcomingSchedule(child, 'test');
    expect((await alive()).where((s) => s.scheduledDate == farFuture).length, 0);
  });

  test('지급요일이 안 맞아 정리된 일정은 자가치유가 되살리지 않는다(무한 반복 방지)', () async {
    // 지급요일을 "내일 요일"로 잡아, 오늘 날짜 일정이 요일 불일치로 정리되게 한다
    final tomorrow = today.add(const Duration(days: 1));
    final child = await createChild(payDay: tomorrow.weekday);
    for (final id in ['mismatch-a', 'mismatch-b']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: today,
        amount: 3000,
      ));
    }
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'at-next',
      childId: child.id,
      scheduledDate: tomorrow,
      amount: 3000,
    ));
    await db.ensureUpcomingSchedule(child, 'test');
    expect((await alive()).where((s) => s.scheduledDate == today).length, 0);
    await db.ensureUpcomingSchedule(child, 'test');
    expect((await alive()).where((s) => s.scheduledDate == today).length, 0);
    // 정상적인 다음 지급일 일정은 그대로 1개 유지
    expect((await alive()).where((s) => s.scheduledDate == tomorrow).length, 1);
  });

  test('지급 완료였던 일정은 자가치유가 되살리지 않는다(수입 내역 없이 지급완료로 보이는 것 방지)', () async {
    final child = await createChild();
    final now = DateTime.now();
    for (final id in ['paid-a', 'paid-b']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: today,
        amount: 3000,
        isPaid: const Value(true),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
    }
    await db.ensureUpcomingSchedule(child, 'test');
    final atToday = (await alive()).where((s) => s.scheduledDate == today).toList();
    // 지급완료였던 건 되살리지 않고, 백필도 그 주는 이미 일정이 있는 것으로 보므로 새로 만들지 않는다
    expect(atToday.where((s) => s.isPaid).length, 0);
  });

  test('백그라운드 정비가 도는 중에 지급 버튼을 눌러도 상태가 깨지지 않는다', () async {
    final child = await createChild();
    final missedDate = today.subtract(const Duration(days: 7));
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'missed',
      childId: child.id,
      scheduledDate: missedDate,
      amount: 3000,
    ));
    final missed = (await alive()).firstWhere((s) => s.scheduledDate == missedDate);
    // 앱 시작 정비가 도는 도중에 '지급'을 누른 상황(두 호출이 겹침)
    final background = db.ensureUpcomingSchedule(child, 'test');
    final pay = db.markSchedulePaid(missed, 'test', child);
    await Future.wait([background, pay]);

    final rows = await alive();
    // 밀린 주는 지급 완료로 정확히 1건, 수입 내역도 1건만(이중 계상 없음)
    expect(rows.where((s) => s.scheduledDate == missedDate && s.isPaid).length, 1);
    expect(
        (await db.allTransactionsRaw())
            .where((t) => t.deletedAt == null && t.category == '정기용돈')
            .length,
        1);
    // 이번 주 예정도 중복 없이 정확히 1건
    expect(rows.where((s) => s.scheduledDate == today && !s.isPaid).length, 1);
  });

  test('이미 지급이 끝난 주는 자가치유가 되살리지 않는다', () async {
    final child = await createChild();
    final now = DateTime.now();
    final oldWeek = today.subtract(const Duration(days: 7));
    // 지난주(oldWeek)에 삭제 중복이 2개 쌓여있지만, 그 뒤 이번 주가 이미 지급 완료됨
    for (final id in ['old-a', 'old-b']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: oldWeek,
        amount: 3000,
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
    }
    await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
      id: 'this-week-paid',
      childId: child.id,
      scheduledDate: today,
      amount: 3000,
      isPaid: const Value(true),
    ));
    await db.ensureUpcomingSchedule(child, 'test');
    // 정산이 끝난 뒤의 지난주가 되살아나 "밀린 용돈"으로 뜨면 안 된다
    expect((await alive()).where((s) => s.scheduledDate == oldWeek).length, 0);
  });

  test('자가치유 후 다시 호출해도(예: 앱을 다시 켜도) 또 하나를 되살려 중복이 생기지 않는다', () async {
    final child = await createChild();
    final now = DateTime.now();
    for (final id in ['race-a', 'race-b', 'race-c']) {
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: id,
        childId: child.id,
        scheduledDate: today,
        amount: 3000,
        deletedAt: Value(now),
        updatedAt: Value(now),
      ));
    }
    await db.ensureUpcomingSchedule(child, 'test'); // 1차: 하나를 되살림
    await db.ensureUpcomingSchedule(child, 'test'); // 2차: 이미 살아있으니 또 되살리면 안 됨
    final atToday = (await alive()).where((s) => s.scheduledDate == today).toList();
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

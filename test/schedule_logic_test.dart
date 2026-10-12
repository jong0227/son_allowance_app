import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';
import 'package:son_allowance_app/services/export_import_service.dart';

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

  test('같은 날 삭제된 일정이 여러 개여도 되살리지 않는다(중복 정리 뒤 건너뛴 주일 수 있다)', () async {
    final child = await createChild();
    final now = DateTime.now();
    // v1.32까지는 이걸 "동시 실행 경합의 잔재"로 보고 하나를 되살렸다. 그런데 두 폰이
    // 만든 중복을 정리(삭제 1)한 뒤 부모가 그 주를 건너뛰면(삭제 1) 똑같은 모양이 되어,
    // 건너뛴 주가 다시 "지급 예정"으로 떴다.
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
    await db.ensureUpcomingSchedule(child, 'test'); // 앱을 다시 켜도
    expect((await alive()).where((s) => s.scheduledDate == today), isEmpty);
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

  test('엄마·아빠가 각자 폰에서 같은 주 용돈을 지급해도 동기화 후 한 번만 들어간다', () async {
    const io = ExportImportService();
    final child = await createChild();
    await db.ensureUpcomingSchedule(child, 'test');
    final mom = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(mom.close);
    await io.applyImport(await io.previewImportData(await io.serializeAll(db, '아빠'), mom), mom);

    final momChild = (await mom.allChildrenRaw()).first;
    await db.markSchedulePaid((await alive()).first, '아빠', child);
    final momSched = (await mom.allSchedulesRaw()).firstWhere((s) => s.deletedAt == null);
    await mom.markSchedulePaid(momSched, '엄마', momChild);

    await io.applyImport(await io.previewImportData(await io.serializeAll(mom, '엄마'), db), db);
    final allowances = (await db.allTransactionsRaw())
        .where((t) => t.deletedAt == null && t.category == '정기용돈');
    expect(allowances.length, 1, reason: '같은 주 용돈이 두 번 들어가면 안 된다');
  });

  test('지급 취소 후 다시 지급하면 내역이 되살아난다(같은 id 재사용)', () async {
    final child = await createChild();
    await db.ensureUpcomingSchedule(child, 'test');
    final s = (await alive()).first;
    await db.markSchedulePaid(s, 'test', child);
    await db.markScheduleUnpaid(s, 'test', child);
    expect((await db.allTransactionsRaw()).where((t) => t.deletedAt == null).length, 0);
    await db.markSchedulePaid(s, 'test', child);
    final txs = (await db.allTransactionsRaw()).where((t) => t.deletedAt == null).toList();
    expect(txs.length, 1, reason: '삭제 표시가 남으면 다시 지급해도 내역에 안 보인다');
  });

  test('예전 버전이 남긴 중복 지급 내역이 있어도 지급 취소가 멈추지 않는다', () async {
    final child = await createChild();
    await db.ensureUpcomingSchedule(child, 'test');
    final s = (await alive()).first;
    await db.markSchedulePaid(s, 'test', child);
    // 옛 버전에서 다른 폰이 무작위 id로 만든 두 번째 내역(같은 일정에 연결)
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 'legacy-dup',
      childId: child.id,
      date: DateTime.now(),
      flow: 'income',
      category: '정기용돈',
      amount: 3000,
      linkedScheduleId: Value(s.id),
      updatedAt: Value(DateTime.now()),
    ));
    // 예전엔 getSingleOrNull이 "여러 개"라며 예외를 던졌다
    await db.markScheduleUnpaid(s, 'test', child);
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

  // 2026-10-12 실제 사례: 오늘 용돈 카드가 두 장 떴고, 한 장을 지급하자 나머지도 사라졌다.
  // 엄마·아빠 폰이 동기화 전에 각자 "오늘 일정"을 무작위 id로 만들어서, 합친 뒤
  // 같은 날 일정이 두 줄이 됐다. 중복 정리는 앱 시작·지급 때만 돌아서 그 사이엔 두 장이 보였다.
  group('두 폰이 각자 일정을 만든 경우', () {
    const io = ExportImportService();
    late AppDatabase mom;

    /// from 폰의 데이터를 to 폰에 합친다(가족 동기화와 같은 병합 규칙).
    Future<void> sync(AppDatabase from, AppDatabase to, String who) async =>
        io.applyImport(await io.previewImportData(await io.serializeAll(from, who), to), to);

    Future<List<AllowanceSchedule>> aliveOn(AppDatabase d) async =>
        (await d.allSchedulesRaw()).where((s) => s.deletedAt == null).toList();

    Future<List<TransactionEntry>> allowancesOn(AppDatabase d) async => (await d.allTransactionsRaw())
        .where((t) => t.deletedAt == null && t.category == AppDatabase.kRegularAllowance)
        .toList();

    bool isToday(AllowanceSchedule s) => s.scheduledDate == today;

    /// 아빠 폰에서 아이를 만들고, 일정이 생기기 전에 엄마 폰과 한 번 동기화한 상태.
    Future<(Child, Child)> twoPhones() async {
      final dadChild = await createChild();
      mom = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(mom.close);
      await sync(db, mom, '아빠');
      return (dadChild, (await mom.allChildrenRaw()).first);
    }

    /// 예전 버전(무작위 id)이 만든 것 같은 오늘 일정 두 줄.
    Future<void> legacyDuplicatesToday(Child child) async {
      for (final id in ['legacy-b', 'legacy-a']) {
        await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
          id: id,
          childId: child.id,
          scheduledDate: today,
          amount: 3000,
        ));
      }
    }

    test('동기화 전에 두 폰이 각자 오늘 일정을 만들어도 합치면 하나', () async {
      final (dadChild, momChild) = await twoPhones();
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      await mom.ensureUpcomingSchedule(momChild, '엄마');

      await sync(mom, db, '엄마');
      await sync(db, mom, '아빠');
      expect((await aliveOn(db)).where(isToday).length, 1);
      expect((await aliveOn(mom)).where(isToday).length, 1);
    });

    test('예전 버전이 만든 같은 날 중복이 있어도 화면 목록엔 하루에 한 장만 보인다', () async {
      final child = await createChild();
      await legacyDuplicatesToday(child);
      final shown = await db.watchSchedules(child.id).first;
      expect(shown.where(isToday).length, 1);
    });

    test('동기화로 중복이 들어오면 바로 정리된다(지급 버튼을 누르기 전에)', () async {
      final child = await createChild();
      await legacyDuplicatesToday(child);
      await db.tidySchedulesAfterSync('아빠');
      expect((await aliveOn(db)).where(isToday).length, 1);
    });

    test('중복 상태에서 보이는 카드를 지급하면 한 번만 들어가고 미지급 카드는 남지 않는다', () async {
      final child = await createChild();
      await legacyDuplicatesToday(child);
      final shown = (await db.watchSchedules(child.id).first).where(isToday).single;
      await db.markSchedulePaid(shown, '아빠', child);

      final todays = (await aliveOn(db)).where(isToday).toList();
      expect(todays.length, 1);
      expect(todays.single.isPaid, true);
      expect((await allowancesOn(db)).length, 1);
    });

    test('중복 상태에서 건너뛰면 그날 일정이 모두 사라지고 다시 생기지 않는다', () async {
      final child = await createChild();
      await legacyDuplicatesToday(child);
      final shown = (await db.watchSchedules(child.id).first).where(isToday).single;
      await db.skipSchedule(shown, '아빠');
      await db.ensureUpcomingSchedule(child, '아빠');

      expect((await aliveOn(db)).where(isToday), isEmpty, reason: '숨어 있던 다른 한 줄이 다시 뜨면 안 된다');
      expect((await db.watchSchedules(child.id).first).where(isToday), isEmpty);
    });

    test('두 폰이 동기화 전에 각자 오늘 용돈을 지급해도 한 번만 들어간다', () async {
      final (dadChild, momChild) = await twoPhones();
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      await mom.ensureUpcomingSchedule(momChild, '엄마');
      await db.markSchedulePaid((await aliveOn(db)).single, '아빠', dadChild);
      await mom.markSchedulePaid((await aliveOn(mom)).single, '엄마', momChild);

      await sync(mom, db, '엄마');
      await db.tidySchedulesAfterSync('아빠');
      expect((await allowancesOn(db)).length, 1);
      expect((await aliveOn(db)).where(isToday).length, 1);
    });

    test('예전 버전 폰과 새 버전 폰이 각자 지급해도 동기화 정리 후 한 번만 남는다', () async {
      final (dadChild, momChild) = await twoPhones();
      // 엄마 폰은 아직 예전 버전: 무작위 id 일정
      await mom.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: 'old-version-random',
        childId: momChild.id,
        scheduledDate: today,
        amount: 3000,
      ));
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      await db.markSchedulePaid((await aliveOn(db)).single, '아빠', dadChild);
      await mom.markSchedulePaid((await aliveOn(mom)).single, '엄마', momChild);

      await sync(mom, db, '엄마');
      await db.tidySchedulesAfterSync('아빠');
      expect((await allowancesOn(db)).length, 1);
      expect((await aliveOn(db)).where(isToday).length, 1);
    });

    test('지급 → 취소 → 다른 폰과 동기화 → 다시 지급해도 한 번만 들어간다', () async {
      final (dadChild, momChild) = await twoPhones();
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      final s = (await aliveOn(db)).single;
      await db.markSchedulePaid(s, '아빠', dadChild);
      await db.markScheduleUnpaid(s, '아빠', dadChild);
      await sync(db, mom, '아빠');
      await mom.tidySchedulesAfterSync('엄마');

      final onMom = (await aliveOn(mom)).where(isToday).single;
      expect(onMom.isPaid, false);
      // 시각은 초 단위로 저장되고 병합은 "더 최신"만 받는다. 실제로는 동기화를 거치며
      // 1초 넘게 지나므로, 같은 초에 취소·재지급이 겹치는 테스트만의 상황을 피한다.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await mom.markSchedulePaid(onMom, '엄마', momChild);
      await sync(mom, db, '엄마');
      expect((await allowancesOn(db)).length, 1);
    });

    test('두 폰에서 같은 날짜를 소급 지급해도 합치면 한 번', () async {
      final (dadChild, momChild) = await twoPhones();
      final past = today.subtract(const Duration(days: 7));
      await db.addPastAllowance(dadChild, past, 3000, '아빠');
      await mom.addPastAllowance(momChild, past, 3000, '엄마');

      await sync(mom, db, '엄마');
      await db.tidySchedulesAfterSync('아빠');
      expect((await allowancesOn(db)).length, 1);
      expect((await aliveOn(db)).where((s) => s.scheduledDate == past).length, 1);
    });

    test('아이 폰이 만든 일정과 부모 폰 일정도 같은 하나로 합쳐진다', () async {
      final (dadChild, kidChild) = await twoPhones(); // mom 자리를 아이 폰으로 사용
      await mom.ensureUpcomingSchedule(kidChild, '아들');
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      await sync(mom, db, '아들');
      final shown = (await db.watchSchedules(dadChild.id).first).where(isToday).toList();
      expect(shown.length, 1);
      // 시각은 초 단위 저장 — 실제처럼 아이 폰이 만든 뒤 시간이 지나 지급한 상황.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await db.markSchedulePaid(shown.single, '아빠', dadChild);
      await sync(db, mom, '아빠');
      final onKid = (await aliveOn(mom)).where(isToday).toList();
      expect(onKid.length, 1);
      expect(onKid.single.isPaid, true, reason: '아이 폰에도 "받음"으로 보여야 한다');
    });

    test('한 폰은 지급, 다른 폰은 나중에 건너뛰기 → 합쳐도 용돈이 두 번 들어가거나 카드가 남지 않는다', () async {
      final (dadChild, momChild) = await twoPhones();
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      await sync(db, mom, '아빠');
      await db.markSchedulePaid((await aliveOn(db)).single, '아빠', dadChild);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await mom.skipSchedule((await aliveOn(mom)).single, '엄마');

      await sync(mom, db, '엄마');
      await db.tidySchedulesAfterSync('아빠');
      expect((await allowancesOn(db)).length, lessThanOrEqualTo(1));
      expect((await db.watchSchedules(dadChild.id).first).where((s) => isToday(s) && !s.isPaid), isEmpty);
    });

    test('한 폰은 건너뛰기, 다른 폰은 나중에 지급 → 지급이 남고 한 번만 들어간다', () async {
      final (dadChild, momChild) = await twoPhones();
      await db.ensureUpcomingSchedule(dadChild, '아빠');
      await sync(db, mom, '아빠');
      await db.skipSchedule((await aliveOn(db)).single, '아빠');
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      await mom.markSchedulePaid((await aliveOn(mom)).single, '엄마', momChild);

      await sync(mom, db, '엄마');
      await db.tidySchedulesAfterSync('아빠');
      expect((await allowancesOn(db)).length, 1);
      final todays = (await aliveOn(db)).where(isToday).toList();
      expect(todays.length, 1);
      expect(todays.single.isPaid, true);
    });

    test('고정 id가 이미 다른 날짜로 옮겨진 일정에 쓰였으면 덮어쓰지 않는다', () async {
      final child = await createChild();
      final lastWeek = today.subtract(const Duration(days: 7));
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: 'paid-2w',
        childId: child.id,
        scheduledDate: today.subtract(const Duration(days: 14)),
        amount: 3000,
        isPaid: const Value(true),
      ));
      // 지난주 날짜로 만들어졌다가 지급요일 변경으로 오늘로 옮겨진 일정
      await db.upsertSchedule(AllowanceSchedulesCompanion.insert(
        id: AppDatabase.scheduleIdFor(child.id, lastWeek),
        childId: child.id,
        scheduledDate: today,
        amount: 3000,
      ));
      await db.ensureUpcomingSchedule(child, '아빠');

      final rows = await aliveOn(db);
      expect(rows.where(isToday).length, 1, reason: '오늘 일정이 지난주로 끌려가면 안 된다');
      expect(rows.where((s) => s.scheduledDate == lastWeek).length, 1, reason: '밀린 지난주도 생긴다');
    });
  });
}

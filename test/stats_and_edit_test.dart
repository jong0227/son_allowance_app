import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';

void main() {
  late AppDatabase db;

  Future<Child> makeChild() async {
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1',
      name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
    ));
    return (await db.allChildrenRaw()).first;
  }

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('이자율 정규화: 배수 1 + 약속 보너스 연 0.3%로 맞춘다', () async {
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1',
      name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      interestMultiplier: const Value(6.0),
      interestUseBankRate: const Value(false),
    ));
    await db.upsertPromise(PromisesCompanion.insert(
      id: 'p1', childId: 'kid1', title: '이 닦기',
      bonusPercent: const Value(0.1)));

    await db.normalizeInterestRates('아빠');

    final child = (await db.allChildrenRaw()).first;
    expect(child.interestMultiplier, 1.0);
    expect(child.interestUseBankRate, true);
    final promise = (await db.allPromisesRaw()).first;
    expect(promise.bonusPercent, 0.3);
  });

  test('시작 잔액은 잔액엔 포함되지만 총수입/월별수입 통계에선 제외된다', () async {
    final child = await makeChild();
    // 시작 잔액(이월잔액) 50000
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-init', childId: child.id, date: DateTime.now(),
      flow: 'income', category: AppDatabase.kInitialBalance, amount: 50000,
      updatedAt: Value(DateTime.now()),
    ));
    // 정기용돈 3000 수입
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-reg', childId: child.id, date: DateTime.now(),
      flow: 'income', category: AppDatabase.kRegularAllowance, amount: 3000,
      updatedAt: Value(DateTime.now()),
    ));

    final s = await db.computeSummary(child.id);
    expect(s['initialBalance'], 50000);
    expect(s['totalIncome'], 3000, reason: '총수입엔 시작 잔액 제외');
    expect(s['balance'], 53000, reason: '잔액엔 시작 잔액 포함');

    // 월별 수입 통계에도 시작 잔액은 안 잡힘
    final monthly = await db.monthlyIncomeExpense(child.id);
    final totalMonthlyIncome =
        monthly.values.fold<int>(0, (a, m) => a + (m['income'] ?? 0));
    expect(totalMonthlyIncome, 3000);
  });

  test('특별용돈(선물)은 저축 티어 점수에 10%만 반영된다', () async {
    final child = await makeChild();
    // 정기용돈 등 "일반" 수입 없이, 특별용돈 7만원만 받은 상태
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-gift', childId: child.id, date: DateTime.now(),
      flow: 'income', category: '설날(세뱃돈)', amount: 70000,
      updatedAt: Value(DateTime.now()),
    ));
    final s = await db.computeSummary(child.id);
    expect(s['totalSpecialIncome'], 70000);
    expect(s['balance'], 70000, reason: '실제로 쓸 수 있는 잔액은 받은 그대로 7만원');
    expect(s['tierScore'], 7000, reason: '티어 점수엔 10%(7000)만 반영되어야 한다');
  });

  test('특별용돈을 다 쓰면 티어 점수 기여분도 0이 된다(선물을 먼저 쓴 것으로 계산)', () async {
    final child = await makeChild();
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-gift', childId: child.id, date: DateTime.now(),
      flow: 'income', category: '설날(세뱃돈)', amount: 70000,
      updatedAt: Value(DateTime.now()),
    ));
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-spend', childId: child.id, date: DateTime.now(),
      flow: 'expense', category: '기타', amount: 70000,
      updatedAt: Value(DateTime.now()),
    ));
    final s = await db.computeSummary(child.id);
    expect(s['tierScore'], 0);
  });

  test('선물 받기 전에 이미 써버린 지출은, 나중에 받은 선물이 소급해서 메워주지 않는다', () async {
    final child = await makeChild();
    final now = DateTime.now();
    final longAgo = now.subtract(const Duration(days: 100));
    // 예전에 정기용돈 5만원 받고 2만2천원을 이미 써버림(선물은 아직 없음)
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-old-income', childId: child.id, date: longAgo,
      flow: 'income', category: AppDatabase.kRegularAllowance, amount: 50000,
      updatedAt: Value(longAgo),
    ));
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-old-expense', childId: child.id, date: longAgo,
      flow: 'expense', category: '기타', amount: 22000,
      updatedAt: Value(longAgo),
    ));
    // 오늘 특별용돈 7만원을 받음 — 이건 100일 전 지출과 무관해야 한다
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 't-gift-today', childId: child.id, date: now,
      flow: 'income', category: '사랑용돈', amount: 70000,
      updatedAt: Value(now),
    ));
    final s = await db.computeSummary(child.id);
    // 정기용돈 100% 반영분(50000-22000=28000) + 선물 10%(7000) = 35000
    // (선물이 옛날 지출을 소급 메워주면 50000 + 7000 = 57000이 되어 버그가 재현된다)
    expect(s['tierScore'], 35000,
        reason: '옛날 지출은 계속 정기용돈에서 차감된 채로 남아야 하고, 선물은 10%만 별도로 더해져야 한다');
  });

  test('updateChildPartial로 보너스 규칙만 부분 갱신해도 저장된다(NOT NULL 회피)', () async {
    final child = await makeChild();
    // name을 넘기지 않는 부분 갱신 — upsert였다면 NOT NULL로 실패할 케이스
    await db.updateChildPartial(child.id, const ChildrenCompanion(
      bonusThreshold: Value(2000),
      bonusAmount: Value(700),
      bonusDayOfWeek: Value(5),
    ));
    final updated = (await db.allChildrenRaw()).first;
    expect(updated.name, '테스트', reason: '이름은 보존');
    expect(updated.bonusThreshold, 2000);
    expect(updated.bonusAmount, 700);
    expect(updated.bonusDayOfWeek, 5);
  });

  test('용돈 변경 이력에 사유 코멘트가 저장된다', () async {
    final child = await makeChild();
    await db.addAllowanceRate(child.id, 5000, '아빠', note: '초등학교 입학');
    final rates = await db.allAllowanceRatesRaw();
    expect(rates.length, 1);
    expect(rates.first.amount, 5000);
    expect(rates.first.note, '초등학교 입학');
  });

  test('과거 용돈 추정: 지급요일 주 수 × 기본용돈, 변경이력 반영', () async {
    // payday = 오늘 요일 → 계산 단순화
    final today = DateTime.now();
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1', name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      payDayOfWeek: Value(today.weekday),
    ));
    final child = (await db.allChildrenRaw()).first;
    // 4주 전 시작 → 오늘 이전 지급일 4번(주-4,-3,-2,-1)
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 28));
    final total = await db.estimatePastAllowance(child, start);
    expect(total, 12000, reason: '3000 × 4주');

    // "지금까지 모은 돈" 10000 입력 → 소비 자동계산(12000-10000=2000), 잔액=10000
    await db.applyPastAllowance(child, start, 10000, '아빠');
    final txs = (await db.allTransactionsRaw()).where((t) => t.deletedAt == null).toList();
    final income = txs.firstWhere((t) => t.flow == 'income');
    final expense = txs.firstWhere((t) => t.flow == 'expense');
    expect(income.category, '정기용돈');
    expect(income.amount, 12000);
    expect(expense.amount, 2000, reason: '자동 계산된 소비');
    expect(expense.category, AppDatabase.kPastExpense,
        reason: '기타가 아니라 전용 카테고리로 들어가야 통계가 안 망가짐');
    expect((await db.computeSummary(child.id))['balance'], 10000);
  });

  test('과거 일괄 내역은 잔액엔 반영되지만 카테고리/월별 통계에선 빠진다', () async {
    final today = DateTime.now();
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1', name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      payDayOfWeek: Value(today.weekday),
    ));
    final child = (await db.allChildrenRaw()).first;
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 28));
    await db.applyPastAllowance(child, start, 10000, '아빠');

    // 실제로 기록한 지출 하나 추가
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 'e1',
      childId: child.id,
      date: DateTime.now(),
      flow: 'expense',
      category: '간식',
      amount: 1500,
    ));

    // 잔액엔 과거 일괄이 그대로 반영
    expect((await db.computeSummary(child.id))['balance'], 8500);

    // 카테고리 통계엔 과거 지출 일괄이 없어야 한다
    final byCat = await db.expenseByCategory(child.id);
    expect(byCat[AppDatabase.kPastExpense], null);
    expect(byCat['기타'], null, reason: '더 이상 기타로 뭉뚱그리지 않음');
    expect(byCat['간식'], 1500);

    // 월별 통계에서도 과거 일괄(수입/지출 모두) 제외
    final monthly = await db.monthlyIncomeExpense(child.id);
    final allExpense =
        monthly.values.fold<int>(0, (a, m) => a + (m['expense'] ?? 0));
    final allIncome =
        monthly.values.fold<int>(0, (a, m) => a + (m['income'] ?? 0));
    expect(allExpense, 1500, reason: '과거 지출 일괄 제외');
    expect(allIncome, 0, reason: '과거 정기용돈 일괄 제외');
  });

  test('모은 돈이 받은 용돈보다 많으면 차액이 이월잔액 수입으로 보충된다', () async {
    final today = DateTime.now();
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1', name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      payDayOfWeek: Value(today.weekday),
    ));
    final child = (await db.allChildrenRaw()).first;
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 14)); // 2주 → 6000
    await db.applyPastAllowance(child, start, 10000, '아빠'); // 모은 돈 10000 > 6000
    // 잔액이 정확히 10000 (6000 정기 + 4000 이월)
    expect((await db.computeSummary(child.id))['balance'], 10000);
  });

  group('저축 점수 내역(아이에게 보여주는 설명)', () {
    Future<void> tx(String id, DateTime date, String flow, String category,
        int amount) async {
      await db.upsertTransaction(TransactionEntriesCompanion.insert(
        id: id,
        childId: 'kid1',
        date: date,
        flow: flow,
        category: category,
        amount: amount,
        updatedAt: Value(date),
      ));
    }

    test('내역의 최종 점수가 실제 저축 점수와 정확히 같다', () async {
      final child = await makeChild();
      final d0 = DateTime(2026, 3, 1);
      // 실기기에서 확인한 실제 패턴을 축약: 용돈/보너스 + 큰 선물 + 그 뒤 지출
      await tx('a', d0, 'income', AppDatabase.kRegularAllowance, 54000);
      await tx('b', d0.add(const Duration(days: 1)), 'expense', '기타', 22147);
      await tx('c', d0.add(const Duration(days: 2)), 'income', '사랑용돈', 70000);
      await tx('d', d0.add(const Duration(days: 3)), 'income', AppDatabase.kSavingsBonus, 650);
      await tx('e', d0.add(const Duration(days: 4)), 'expense', '간식', 21000);

      final summary = await db.computeSummary(child.id);
      final bd = await db.tierScoreBreakdown(child.id);
      expect(bd.tierScore, summary['tierScore'],
          reason: '내역으로 계산한 점수와 실제 점수가 다르면 아이에게 보여주는 숫자가 어긋난다');
      expect(bd.steps.first.scoreAfter, bd.tierScore,
          reason: '가장 최근 거래 뒤 점수가 곧 지금 점수여야 한다');
    });

    test('두 주머니 남은 돈을 합치면 점수가 나온다(용돈 100% + 선물 10%)', () async {
      final child = await makeChild();
      final d0 = DateTime(2026, 3, 1);
      await tx('a', d0, 'income', AppDatabase.kRegularAllowance, 50000);
      await tx('b', d0.add(const Duration(days: 1)), 'income', '사랑용돈', 70000);

      final bd = await db.tierScoreBreakdown(child.id);
      expect(bd.regularPool, 50000);
      expect(bd.giftPool, 70000);
      expect(bd.giftScore, 7000);
      expect(bd.regularPool + bd.giftScore, bd.tierScore);
    });

    test('지출은 선물 주머니에서 먼저 빠지고, 점수는 10%만 떨어진다', () async {
      final child = await makeChild();
      final d0 = DateTime(2026, 3, 1);
      await tx('a', d0, 'income', AppDatabase.kRegularAllowance, 50000);
      await tx('b', d0.add(const Duration(days: 1)), 'income', '사랑용돈', 70000);
      await tx('c', d0.add(const Duration(days: 2)), 'expense', '간식', 21000);

      final bd = await db.tierScoreBreakdown(child.id);
      final spend = bd.steps.first; // 최신이 맨 앞
      expect(spend.isIncome, false);
      expect(spend.fromGift, 21000, reason: '선물 주머니에서 전액 빠져야 한다');
      expect(spend.fromRegular, 0);
      expect(spend.scoreDelta, -2100, reason: '21,000의 10%만 점수에서 빠진다');
      expect(bd.regularPool, 50000, reason: '용돈 주머니는 손대지 않았다');
    });

    test('선물 주머니가 모자라면 나머지는 용돈 주머니에서 100% 빠진다', () async {
      final child = await makeChild();
      final d0 = DateTime(2026, 3, 1);
      await tx('a', d0, 'income', AppDatabase.kRegularAllowance, 50000);
      await tx('b', d0.add(const Duration(days: 1)), 'income', '사랑용돈', 5000);
      await tx('c', d0.add(const Duration(days: 2)), 'expense', '간식', 9000);

      final bd = await db.tierScoreBreakdown(child.id);
      final spend = bd.steps.first;
      expect(spend.fromGift, 5000);
      expect(spend.fromRegular, 4000);
      expect(spend.isSplitSpend, true);
      // 선물 5000이 사라져 -500, 용돈 4000이 빠져 -4000
      expect(spend.scoreDelta, -4500);
      expect(bd.giftPool, 0);
      expect(bd.regularPool, 46000);
    });
  });
}

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
}

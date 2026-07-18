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

    // 적용하면 정기용돈 수입이 생기고 시작잔액은 없어야 함
    await db.applyPastAllowance(child, start, 2000, '아빠');
    final txs = (await db.allTransactionsRaw()).where((t) => t.deletedAt == null).toList();
    final income = txs.firstWhere((t) => t.flow == 'income');
    final expense = txs.firstWhere((t) => t.flow == 'expense');
    expect(income.category, '정기용돈');
    expect(income.amount, 12000);
    expect(expense.amount, 2000);
    // 저축률 관점: 받은 12000 중 2000 씀 → 잔액 10000
    expect((await db.computeSummary(child.id))['balance'], 10000);
  });
}

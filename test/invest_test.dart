import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';

/// 주 단위 모의 투자(v17~)가 DB·잔액과 맞물려 도는지 확인한다.
/// 순수 계산(1주 가격·수수료·평단가)은 test/invest_calc_test.dart가 맡는다.
///
/// 코스피 배수 0.1 → 지수 2000이면 1주 200원.
/// 나스닥 배수 0.02 → 지수 20000이면 1주 400원.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// 잔액 10만원짜리 자녀를 만든다(정기용돈 수입 1건).
  Future<Child> makeChild({double limit = 10}) async {
    await db.upsertChild(ChildrenCompanion.insert(
      id: 'kid1',
      name: '테스트',
      weeklyAllowanceDefault: const Value(3000),
      investLimitPercent: Value(limit),
    ));
    await db.upsertTransaction(TransactionEntriesCompanion.insert(
      id: 'in1',
      childId: 'kid1',
      date: DateTime.now(),
      flow: 'income',
      category: AppDatabase.kRegularAllowance,
      amount: 100000,
    ));
    return (await db.allChildrenRaw()).first;
  }

  Future<String?> buyKospi(Child child, int shares, {double index = 2000}) =>
      db.buySharesInvest(
        child: child,
        indexKey: 'kospi',
        label: '코스피',
        symbol: '^KS11',
        shares: shares,
        indexValue: index,
      );

  test('사면 (주식값 + 수수료)만큼 잔액에서 잠기고, 총 저축은 그대로다', () async {
    final child = await makeChild();
    expect((await db.computeSummary('kid1'))['balance'], 100000);

    // 40주 × 200원 = 8,000원 + 수수료 30원(최소 수수료)
    expect(await buyKospi(child, 40), isNull);

    final s = await db.computeSummary('kid1');
    expect(s['invested'], 8030, reason: '매수 수수료도 원금에 포함된다');
    expect(s['balance'], 91970);
    expect(s['totalSavings'], 100000, reason: '형태만 바뀌었을 뿐 총 저축은 그대로');
  });

  test('여러 번 나눠 사면 한 덩이로 합쳐지고 평단가가 나온다', () async {
    final child = await makeChild(limit: 30);
    await buyKospi(child, 10, index: 2000); // 1주 200 → 2,030원
    await buyKospi(child, 10, index: 3000); // 1주 300 → 3,030원

    final h = (await db.holdingsOf('kid1')).single;
    expect(h.shares, 20, reason: '덩이가 나뉘지 않고 합쳐진다');
    expect(h.costBasis, 5060);
    expect(h.avgPrice, 253, reason: '(2030+3030)/20');
  });

  test('한도(총 저축의 10%)를 넘으면 살 수 없다', () async {
    final child = await makeChild();
    // 50주 × 200원 = 10,000원 + 수수료 30원 → 한도 10,000원 초과
    expect(await buyKospi(child, 50), isNotNull);
    expect((await db.computeSummary('kid1'))['invested'], 0);
  });

  test('한도는 부모가 바꾼 비율을 따른다', () async {
    final child = await makeChild(limit: 30);
    final err = await db.buySharesInvest(
      child: child,
      indexKey: 'nasdaq',
      label: '나스닥',
      symbol: '^IXIC',
      shares: 50, // 50주 × 400원 = 20,000원 + 30원
      indexValue: 20000,
    );
    expect(err, isNull);
    expect((await db.computeSummary('kid1'))['invested'], 20030);
  });

  test('오른 뒤 전부 팔면 수수료를 뺀 돈이 저축으로 돌아온다', () async {
    final child = await makeChild();
    await buyKospi(child, 40, index: 2000); // 원가 8,030원
    final h = (await db.holdingsOf('kid1')).single;

    // 지수 2000 → 2200 (1주 220원). 40주 = 8,800원, 매도 수수료 30원.
    final returned = await db.sellSharesInvest(
        child: child, holding: h, shares: 40, indexValue: 2200, editedBy: '아들');
    expect(returned, 8770);

    final s = await db.computeSummary('kid1');
    expect(s['invested'], 0, reason: '다 팔면 잠긴 원금이 풀린다');
    expect(s['rewardIncome'], 740, reason: '8,770 − 8,030 (양쪽 수수료 반영)');
    expect(s['balance'], 100740);
  });

  test('내린 뒤 팔면 손실만큼 저축이 줄어든다', () async {
    final child = await makeChild();
    await buyKospi(child, 40, index: 2000);
    final h = (await db.holdingsOf('kid1')).single;

    // 지수 2000 → 1800 (1주 180원). 40주 = 7,200원, 매도 수수료 30원.
    final returned = await db.sellSharesInvest(
        child: child, holding: h, shares: 40, indexValue: 1800, editedBy: '아들');
    expect(returned, 7170);

    final s = await db.computeSummary('kid1');
    expect(s['invested'], 0);
    expect(s['balance'], 99140, reason: '7,170 − 8,030 = −860');
  });

  test('부분 매도하면 판 만큼만 원가가 풀리고 나머지는 그대로 남는다', () async {
    final child = await makeChild();
    await buyKospi(child, 40, index: 2000); // 40주, 원가 8,030원
    final h = (await db.holdingsOf('kid1')).single;

    // 10주만 220원에 판다. 판 값 2,200원 − 수수료 30원 = 2,170원.
    // 덜어낼 원가 = 8,030 × 10/40 = 2,008원 → 확정 손익 +162원.
    final returned = await db.sellSharesInvest(
        child: child, holding: h, shares: 10, indexValue: 2200, editedBy: '아들');
    expect(returned, 2170);

    final left = (await db.holdingsOf('kid1')).single;
    expect(left.shares, 30, reason: '나머지는 계속 보유');
    expect(left.costBasis, 6022);
    expect(left.realizedProfit, 162);

    final s = await db.computeSummary('kid1');
    expect(s['invested'], 6022);
    expect(s['rewardIncome'], 162);
  });

  test('다 팔면 원가가 정확히 0이 되어 찌꺼기가 남지 않는다', () async {
    final child = await makeChild();
    await buyKospi(child, 37, index: 2000); // 나누어떨어지지 않는 주수
    for (final n in [7, 11, 19]) {
      final h = (await db.holdingsOf('kid1')).single;
      await db.sellSharesInvest(
          child: child, holding: h, shares: n, indexValue: 2100, editedBy: '아들');
    }
    final h = (await db.holdingsOf('kid1')).single;
    expect(h.shares, 0);
    expect(h.costBasis, 0, reason: '반올림 찌꺼기가 원금에 남으면 안 된다');
    expect((await db.computeSummary('kid1'))['invested'], 0);
  });

  test('가진 것보다 많이 팔라고 해도 가진 만큼만 팔린다', () async {
    final child = await makeChild();
    await buyKospi(child, 20, index: 2000);
    final h = (await db.holdingsOf('kid1')).single;

    await db.sellSharesInvest(
        child: child, holding: h, shares: 999, indexValue: 2000, editedBy: '아들');
    expect((await db.holdingsOf('kid1')).single.shares, 0);
    // 마이너스 보유가 생기면 잔액이 부풀어 오른다.
    expect((await db.computeSummary('kid1'))['invested'], 0);
  });

  test('투자 손실은 카테고리별 지출 통계에 잡히지 않는다', () async {
    final child = await makeChild();
    await buyKospi(child, 40, index: 2000);
    final h = (await db.holdingsOf('kid1')).single;
    await db.sellSharesInvest(
        child: child, holding: h, shares: 40, indexValue: 1800, editedBy: '아들');

    final byCat = await db.expenseByCategory('kid1');
    expect(byCat[AppDatabase.kInvestLoss], isNull,
        reason: '투자 손실은 "무엇에 썼나"가 아니라 투자 결과');
  });

  test('평가액이 한도를 넘어도 강제로 팔지 않고, 추가 매수만 막는다', () async {
    final child = await makeChild(); // 한도 10% = 1만원
    await buyKospi(child, 49, index: 2000); // 9,800 + 30 = 9,830원 (거의 꽉)

    // 지수가 올라 평가액이 한도를 넘어도 보유는 그대로 남는다(강제청산 없음).
    expect((await db.holdingsOf('kid1')).single.shares, 49);

    // 다만 추가 매수는 막힌다.
    expect(await buyKospi(child, 1, index: 2000), isNotNull,
        reason: '한도를 채웠으면 더 못 산다');
    expect((await db.holdingsOf('kid1')).single.shares, 49, reason: '기존 보유는 그대로');
  });

  test('부모가 한도를 낮춰도 기존 투자는 유지되고 추가 매수만 막힌다', () async {
    final child = await makeChild(limit: 30);
    await buyKospi(child, 100, index: 2000); // 20,000 + 30원
    expect((await db.computeSummary('kid1'))['invested'], 20030);

    // 부모가 한도를 30% → 5%로 낮춤
    await db.updateChildPartial(
        'kid1', const ChildrenCompanion(investLimitPercent: Value(5)));
    final lowered = (await db.allChildrenRaw()).first;

    expect((await db.holdingsOf('kid1')).single.shares, 100);
    expect((await db.computeSummary('kid1'))['invested'], 20030);
    expect(await buyKospi(lowered, 1, index: 2000), isNotNull);
  });

  test('잔액보다 많이 살 수 없다', () async {
    // 한도는 100%지만 잔액이 10만원뿐
    final child = await makeChild(limit: 100);
    expect(await buyKospi(child, 1000, index: 2000), isNotNull);
  });

  test('지수를 못 받아오면 사고팔지 않는다', () async {
    final child = await makeChild();
    expect(await buyKospi(child, 10, index: 0), isNotNull);

    await buyKospi(child, 10, index: 2000);
    final h = (await db.holdingsOf('kid1')).single;
    expect(
        await db.sellSharesInvest(
            child: child, holding: h, shares: 10, indexValue: 0, editedBy: '아들'),
        isNull);
    expect((await db.holdingsOf('kid1')).single.shares, 10, reason: '보유는 그대로');
  });
}

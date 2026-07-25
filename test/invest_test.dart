import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/data/app_database.dart';

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

  test('투자하면 원금이 잔액에서 잠기고, 총 저축은 그대로다', () async {
    final child = await makeChild();
    expect((await db.computeSummary('kid1'))['balance'], 100000);

    final err = await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 10000,
      indexValue: 2500,
    );
    expect(err, isNull);

    final s = await db.computeSummary('kid1');
    expect(s['balance'], 90000, reason: '투자한 만큼 쓸 수 있는 돈이 줄어든다');
    expect(s['invested'], 10000);
    expect(s['totalSavings'], 100000, reason: '형태만 바뀌었을 뿐 총 저축은 그대로');
  });

  test('한도(총 저축의 10%)를 넘으면 투자할 수 없다', () async {
    final child = await makeChild();
    final err = await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 10001, // 10만원의 10% = 1만원 초과
      indexValue: 2500,
    );
    expect(err, isNotNull);
    expect((await db.computeSummary('kid1'))['invested'], 0);
  });

  test('한도는 부모가 바꾼 비율을 따른다', () async {
    final child = await makeChild(limit: 30);
    final err = await db.buyInvestment(
      child: child,
      indexKey: 'nasdaq',
      label: '나스닥',
      symbol: '^IXIC',
      amount: 30000,
      indexValue: 20000,
    );
    expect(err, isNull);
    expect((await db.computeSummary('kid1'))['invested'], 30000);
  });

  test('지수가 오르면 팔 때 원금+수익이 저축으로 돌아온다', () async {
    final child = await makeChild();
    await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 10000,
      indexValue: 2000,
    );
    final pos = (await db.openInvestments('kid1')).single;

    // 지수 2000 → 2200 (10% 상승)
    final returned =
        await db.sellInvestment(position: pos, indexValue: 2200, editedBy: '아들');
    expect(returned, 11000);

    final s = await db.computeSummary('kid1');
    expect(s['invested'], 0, reason: '팔면 잠긴 원금이 풀린다');
    expect(s['balance'], 101000, reason: '원금 복귀 + 수익 1,000원');
    // 투자 수익은 저축 보상이라 저축 점수에 100% 반영
    expect(s['rewardIncome'], 1000);
  });

  test('지수가 내리면 손실만큼 저축이 줄어든다', () async {
    final child = await makeChild();
    await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 10000,
      indexValue: 2000,
    );
    final pos = (await db.openInvestments('kid1')).single;

    // 지수 2000 → 1800 (10% 하락)
    final returned =
        await db.sellInvestment(position: pos, indexValue: 1800, editedBy: '아들');
    expect(returned, 9000);

    final s = await db.computeSummary('kid1');
    expect(s['invested'], 0);
    expect(s['balance'], 99000, reason: '원금 복귀 - 손실 1,000원');
  });

  test('투자 손실은 카테고리별 지출 통계에 잡히지 않는다', () async {
    final child = await makeChild();
    await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 10000,
      indexValue: 2000,
    );
    final pos = (await db.openInvestments('kid1')).single;
    await db.sellInvestment(position: pos, indexValue: 1800, editedBy: '아들');

    final byCat = await db.expenseByCategory('kid1');
    expect(byCat[AppDatabase.kInvestLoss], isNull,
        reason: '투자 손실은 "무엇에 썼나"가 아니라 투자 결과');
  });

  test('이미 판 포지션은 다시 팔 수 없다', () async {
    final child = await makeChild();
    await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 5000,
      indexValue: 2000,
    );
    final pos = (await db.openInvestments('kid1')).single;
    expect(await db.sellInvestment(position: pos, indexValue: 2200, editedBy: '아들'),
        isNotNull);
    // 같은(오래된) 포지션 객체로 다시 팔기 시도 → 최신 상태를 읽어와 확인
    final again = (await db.allInvestmentsRaw()).single;
    expect(
        await db.sellInvestment(position: again, indexValue: 2400, editedBy: '아들'),
        isNull);
  });

  test('평가액이 한도를 넘어도 강제로 팔지 않고, 추가 매수만 막는다', () async {
    final child = await makeChild(); // 한도 10% = 1만원
    await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 10000, // 한도를 꽉 채움
      indexValue: 2000,
    );

    // 지수가 2배로 올라 평가액은 2만원(총 저축의 약 18%)이 됐다고 가정.
    // 그래도 보유 포지션은 그대로 남아 있어야 한다(강제청산 없음).
    final open = await db.openInvestments('kid1');
    expect(open.length, 1);
    expect(open.single.soldAt, isNull);

    // 다만 추가 매수는 막힌다.
    final err = await db.buyInvestment(
      child: child,
      indexKey: 'nasdaq',
      label: '나스닥',
      symbol: '^IXIC',
      amount: 1000,
      indexValue: 20000,
    );
    expect(err, isNotNull, reason: '한도를 채웠으면 더 못 산다');
    expect((await db.openInvestments('kid1')).length, 1, reason: '기존 포지션은 그대로');
  });

  test('부모가 한도를 낮춰도 기존 투자는 유지되고 추가 매수만 막힌다', () async {
    final child = await makeChild(limit: 30);
    await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 30000,
      indexValue: 2000,
    );
    expect((await db.computeSummary('kid1'))['invested'], 30000);

    // 부모가 한도를 30% → 5%로 낮춤
    await db.updateChildPartial(
        'kid1', const ChildrenCompanion(investLimitPercent: Value(5)));
    final lowered = (await db.allChildrenRaw()).first;

    // 이미 넣은 3만원은 그대로 남는다
    expect((await db.openInvestments('kid1')).length, 1);
    expect((await db.computeSummary('kid1'))['invested'], 30000);

    // 추가로는 못 넣는다
    final err = await db.buyInvestment(
      child: lowered,
      indexKey: 'nasdaq',
      label: '나스닥',
      symbol: '^IXIC',
      amount: 1000,
      indexValue: 20000,
    );
    expect(err, isNotNull);
  });

  test('잔액보다 많이 투자할 수 없다', () async {
    // 한도는 100%지만 잔액이 10만원뿐
    final child = await makeChild(limit: 100);
    final err = await db.buyInvestment(
      child: child,
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      amount: 200000,
      indexValue: 2000,
    );
    expect(err, isNotNull);
  });
}

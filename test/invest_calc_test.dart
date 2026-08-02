import 'package:flutter_test/flutter_test.dart';
import 'package:son_allowance_app/services/invest_calc.dart';
import 'package:son_allowance_app/utils/formatters.dart';

void main() {
  InvestTradeInput buy(
    String key,
    int shares,
    int price, {
    int? fee,
    DateTime? at,
  }) => (
    indexKey: key,
    label: key,
    symbol: key,
    isBuy: true,
    shares: shares,
    pricePerShare: price,
    fee: fee ?? buyFeeOf(shares * price),
    at: at ?? DateTime(2026, 1, 1),
  );

  InvestTradeInput sell(
    String key,
    int shares,
    int price, {
    int? fee,
    DateTime? at,
  }) => (
    indexKey: key,
    label: key,
    symbol: key,
    isBuy: false,
    shares: shares,
    pricePerShare: price,
    fee: fee ?? sellFeeOf(shares * price),
    at: at ?? DateTime(2026, 1, 2),
  );

  group('1주 가격', () {
    test('지수마다 배수를 적용해 300~800원대로 맞춘다', () {
      // 지수를 그대로 쓰면 코스닥 720 vs 인도 78,095로 100배가 벌어져
      // 한도(수천 원)로는 비싼 지수를 한 주도 못 산다.
      expect(sharePriceOf('kospi', 6595.45), 660);
      expect(sharePriceOf('kosdaq', 719.76), 720);
      expect(sharePriceOf('nasdaq', 25373.85), 507);
      expect(sharePriceOf('india', 78094.64), 781);
      expect(sharePriceOf('china', 3832.26), 383);
      expect(sharePriceOf('europe', 6358.01), 636);
      expect(sharePriceOf('vietnam', 16.98), 509);
    });

    test('조각 수 설명이 실제 1주 가격과 앞뒤가 맞는다', () {
      // 아이에게 "N조각으로 잘랐어"라고 말해놓고 실제 가격이 다르면 거짓말이 된다.
      // 지수 ÷ 조각수 ≈ 1주 가격이어야 한다.
      for (final (key, index) in const [
        ('kospi', 6595.45),
        ('nasdaq', 25373.85),
        ('india', 78094.64),
        ('china', 3832.26),
        ('europe', 6358.01),
      ]) {
        final slices = shareSliceCount(key);
        expect(slices, isNotNull, reason: '$key는 조각 비유가 되어야 한다');
        expect((index / slices!).round(), sharePriceOf(key, index),
            reason: '$key: 지수를 $slices조각으로 나눈 값이 1주 가격과 같아야 한다');
      }
    });

    test('코스닥은 안 자르고(1조각), 베트남은 조각 비유가 성립하지 않는다', () {
      // 코스닥은 배수가 1이라 바구니 하나가 곧 1주다.
      expect(shareSliceCount('kosdaq'), 1);
      // 베트남은 달러 ETF라 오히려 배수를 키운다. 조각내기로 설명하면 틀린 말이 되므로
      // null을 돌려주고 화면에서 다른 문구를 쓴다.
      expect(shareSliceCount('vietnam'), isNull);
      // 모르는 지수도 조각 설명을 만들지 않는다.
      expect(shareSliceCount('unknown'), isNull);
    });

    test('모두 아이가 살 수 있는 가격대에 들어온다', () {
      final prices = [
        sharePriceOf('kospi', 6595.45),
        sharePriceOf('kosdaq', 719.76),
        sharePriceOf('nasdaq', 25373.85),
        sharePriceOf('india', 78094.64),
        sharePriceOf('china', 3832.26),
        sharePriceOf('europe', 6358.01),
        sharePriceOf('vietnam', 16.98),
      ];
      for (final p in prices) {
        expect(p, inInclusiveRange(300, 800));
      }
    });

    test('지수를 못 받아오면 0, 모르는 지수는 1배로 폴백', () {
      expect(sharePriceOf('kospi', 0), 0);
      expect(sharePriceOf('kospi', -1), 0);
      expect(sharePriceOf('알수없음', 500), 500);
    });
  });

  group('수수료', () {
    test('아이 거래 규모에서는 최소 수수료 30원이 적용된다', () {
      expect(buyFeeOf(1000), 30);
      expect(buyFeeOf(3500), 30);
      expect(sellFeeOf(1000), 30);
      expect(sellFeeOf(3500), 30);
    });

    test('매도는 약 14,000원을 넘으면 비율(0.215%)이 최소액을 넘어선다', () {
      expect(sellFeeOf(13000), 30); // 27.95 → 최소액
      expect(sellFeeOf(20000), 43); // 0.215%
      expect(sellFeeOf(100000), 215);
    });

    test('매수 비율(0.015%)은 20만원을 넘어야 최소액을 넘는다', () {
      expect(buyFeeOf(100000), 30); // 15원 → 최소액
      expect(buyFeeOf(300000), 45);
    });

    test('0원이면 수수료도 0', () {
      expect(buyFeeOf(0), 0);
      expect(sellFeeOf(0), 0);
    });
  });

  group('살 수 있는 최대 주수', () {
    test('수수료까지 감안해서 계산한다', () {
      // 1주 660원. 3,500원이면 5주(3,300) + 수수료 30 = 3,330 → 5주 가능.
      expect(maxBuyableShares(3500, 660), 5);
      // 3,300원이면 5주(3,300)+30 = 3,330 > 3,300 이라 4주로 줄어든다.
      expect(maxBuyableShares(3300, 660), 4);
    });

    test('한 주도 못 사면 0', () {
      expect(maxBuyableShares(600, 660), 0);
      expect(maxBuyableShares(0, 660), 0);
    });
  });

  group('보유 집계(평단가)', () {
    test('같은 지수를 여러 번 사면 하나로 합쳐지고 평단가가 다시 계산된다', () {
      final h = computeHoldings([
        buy('kospi', 10, 660, at: DateTime(2026, 1, 1)),
        buy('kospi', 5, 700, at: DateTime(2026, 1, 2)),
      ]);
      expect(h.length, 1);
      expect(h.first.shares, 15);
      // 10×660+30 = 6,630 / 5×700+30 = 3,530 → 합 10,160
      expect(h.first.costBasis, 10160);
      expect(h.first.avgPrice, 677); // 10,160 ÷ 15
    });

    test('평단가에 매수 수수료가 포함돼 그 값을 넘어야 이득이다', () {
      final h = computeHoldings([buy('kospi', 10, 667)]).first;
      // 6,670 + 30 = 6,700 → 평단 670 (산 값 667보다 높다)
      expect(h.costBasis, 6700);
      expect(h.avgPrice, 670);
      expect(h.unrealizedProfit(667), -30); // 산 가격 그대로면 수수료만큼 손해
      expect(h.unrealizedProfit(676), 60);
    });

    test('지수가 다르면 따로 집계된다', () {
      final h = computeHoldings([buy('kospi', 3, 660), buy('nasdaq', 2, 507)]);
      expect(h.length, 2);
      expect(h.map((e) => e.indexKey), ['kospi', 'nasdaq']);
    });
  });

  group('부분 매도', () {
    test('판 주수만큼만 원가가 줄고 나머지는 남는다', () {
      final trades = [
        buy('kospi', 10, 660, at: DateTime(2026, 1, 1)), // 원가 6,630
        sell('kospi', 4, 700, at: DateTime(2026, 1, 5)),
      ];
      final h = computeHoldings(trades).first;
      expect(h.shares, 6);
      // 6,630 × 4/10 = 2,652 가 빠진다
      expect(h.costBasis, 6630 - 2652);
    });

    test('전량 매도하면 보유 0, 원가도 정확히 0이 된다', () {
      final h = computeHoldings([
        buy('kospi', 7, 660, at: DateTime(2026, 1, 1)),
        sell('kospi', 7, 700, at: DateTime(2026, 1, 5)),
      ]).first;
      expect(h.shares, 0);
      expect(h.costBasis, 0, reason: '반올림 찌꺼기가 남으면 안 된다');
      expect(h.isEmpty, isTrue);
    });

    test('보유보다 많이 파는 기록은 보유 수량까지만 반영한다', () {
      final h = computeHoldings([
        buy('kospi', 3, 660, at: DateTime(2026, 1, 1)),
        sell('kospi', 99, 700, at: DateTime(2026, 1, 5)),
      ]).first;
      expect(h.shares, 0);
      expect(h.costBasis, 0);
    });

    test('나눠 팔아도 원가가 음수로 새지 않는다', () {
      final h = computeHoldings([
        buy('kospi', 9, 663, at: DateTime(2026, 1, 1)),
        sell('kospi', 3, 700, at: DateTime(2026, 1, 5)),
        sell('kospi', 3, 700, at: DateTime(2026, 1, 6)),
        sell('kospi', 3, 700, at: DateTime(2026, 1, 7)),
      ]).first;
      expect(h.shares, 0);
      expect(h.costBasis, 0);
    });
  });

  group('매도 정산 미리보기', () {
    Holding holdingOf(int shares, int cost) => Holding(
      indexKey: 'kospi',
      label: '코스피',
      symbol: '^KS11',
      shares: shares,
      costBasis: cost,
      realizedProfit: 0,
    );

    test('판 값에서 수수료를 빼면 받을 돈이 된다', () {
      final q = quoteSell(
        holding: holdingOf(27, 18000),
        sellShares: 10,
        pricePerShare: 676,
      );
      expect(q.gross, 6760);
      expect(q.fee, 30); // 0.215% = 14.5원 → 최소액
      expect(q.netProceeds, 6730);
    });

    test('확정 손익은 매수·매도 수수료를 모두 반영한다', () {
      // 10주를 6,700원(수수료 포함)에 산 상태에서 676원에 판다
      final q = quoteSell(
        holding: holdingOf(10, 6700),
        sellShares: 10,
        pricePerShare: 676,
      );
      expect(q.soldCost, 6700);
      // 6,760 − 30(매도수수료) − 6,700 = +30
      expect(q.realizedProfit, 30);
    });

    test('산 가격 그대로 팔면 수수료 때문에 손해다', () {
      final q = quoteSell(
        holding: holdingOf(10, 6700),
        sellShares: 10,
        pricePerShare: 670, // 평단가와 같은 값
      );
      expect(q.realizedProfit, -30, reason: '매도 수수료만큼 손해');
    });

    test('보유보다 많이 팔려고 하면 보유 수량으로 제한된다', () {
      final q = quoteSell(
        holding: holdingOf(5, 3350),
        sellShares: 100,
        pricePerShare: 700,
      );
      expect(q.shares, 5);
      expect(q.soldCost, 3350, reason: '전량이므로 원가 전부');
    });

    test('0주를 팔면 아무 일도 없다', () {
      final q = quoteSell(
        holding: holdingOf(5, 3350),
        sellShares: 0,
        pricePerShare: 700,
      );
      expect(q.gross, 0);
      expect(q.fee, 0);
      expect(q.netProceeds, 0);
    });
  });

  group('상품 이름', () {
    test('소유·거래 자리에서는 지수 이름이 아니라 ETF 이름을 쓴다', () {
      // 지수는 숫자라 가질 수 없다. "코스피 2주 보유"는 개념이 틀린 문장이다.
      expect(etfName('코스피'), '아빠표 코스피 ETF');
      expect(etfName('나스닥'), '아빠표 나스닥 ETF');
      // 지수 이름이 그대로 남아 있어야 아이가 둘을 연결할 수 있다.
      expect(etfName('코스피'), contains('코스피'));
      expect(etfName('코스피'), contains('ETF'));
    });

    test('지수 이름 받침에 맞는 조사를 고른다', () {
      // 받침 없음 → 는/가
      expect(josa('코스피', '은', '는'), '는');
      expect(josa('인도', '이', '가'), '가');
      // 받침 있음 → 은/이
      expect(josa('코스닥', '은', '는'), '은');
      expect(josa('나스닥', '이', '가'), '이');
      expect(josa('중국', '은', '는'), '은');
      // 영문으로 끝나면 받침 없는 쪽 (아빠표 코스피 ETF"를")
      expect(josa(etfName('코스피'), '을', '를'), '를');
    });
  });
}

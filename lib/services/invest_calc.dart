import 'dart:math';

/// 모의 투자 계산 — 1주 가격, 수수료, 보유(평단가) 집계.
///
/// 화면과 DB 어디서도 이 계산을 다시 쓰지 않도록 여기 한곳에 모았다.
/// 돈 계산이라 전부 순수 함수로 두고 테스트로 고정한다(test/invest_calc_test.dart).

// ─────────────────────────── 1주 가격 ───────────────────────────

/// 지수별 "1주 배수". 1주 가격 = 지수 × 배수.
///
/// 지수를 그대로 1주 값으로 쓰면 코스닥 720원 vs 인도 78,095원으로 100배가 벌어져,
/// 아이의 투자 한도(총저축의 10% ≈ 수천 원)로는 비싼 지수를 한 주도 못 산다.
/// 그래서 1주가 300~800원대에 들어오도록 지수마다 배수를 정했다.
/// 실제 ETF도 지수를 일정 비율로 나눠 살 수 있는 가격으로 만든 상품이라, 개념이 같다.
///
/// (2026-08 기준 지수: 코스피 6,595 / 코스닥 720 / 나스닥 25,374 /
///  인도 78,095 / 중국 3,832 / 유럽 6,358 / 베트남 ETF $16.98)
const Map<String, double> kSharePriceMultiplier = {
  'kospi': 0.1, // 6,595 → 660원
  'kosdaq': 1.0, // 720 → 720원
  'nasdaq': 0.02, // 25,374 → 507원
  'india': 0.01, // 78,095 → 781원
  'china': 0.1, // 3,832 → 383원
  'vietnam': 30.0, // $16.98 → 509원 (달러 ETF라 배수가 크다)
  'europe': 0.1, // 6,358 → 636원
};

/// 지금 지수로 1주 가격(원). 최소 1원.
/// 배수를 모르는 지수가 들어오면 1배로 두어 최소한 거래는 되게 한다.
int sharePriceOf(String indexKey, double indexValue) {
  if (indexValue <= 0) return 0;
  final m = kSharePriceMultiplier[indexKey] ?? 1.0;
  final p = (indexValue * m).round();
  return p < 1 ? 1 : p;
}

// ─────────────────────────── 수수료 ───────────────────────────

/// 최소 수수료(원). 실제 증권사에도 있는 제도.
/// 아이 거래 규모(수천 원)에서는 비율보다 이 값이 커서 대부분 이게 적용된다.
/// "사고팔 때마다 돈이 든다"를 체감시키고 무의미한 소액 매매를 막는 장치다.
const int kMinFee = 30;

/// 매수 위탁수수료 0.015%.
const double kBuyFeeRate = 0.00015;

/// 매도 위탁수수료 0.015% + 증권거래세 0.20%(2026년 기준) = 0.215%.
/// 코스피는 거래세 0.05% + 농특세 0.15%, 코스닥은 거래세 0.20%로 합계는 같다.
const double kSellFeeRate = 0.00215;

int buyFeeOf(int amount) =>
    amount <= 0 ? 0 : max(kMinFee, (amount * kBuyFeeRate).round());

int sellFeeOf(int amount) =>
    amount <= 0 ? 0 : max(kMinFee, (amount * kSellFeeRate).round());

/// 매수에 실제로 드는 총 지출(주식값 + 수수료).
int buyTotalCost(int shares, int pricePerShare) {
  final amount = shares * pricePerShare;
  return amount + buyFeeOf(amount);
}

/// [budget]으로 살 수 있는 최대 주수. 수수료까지 감안한다.
/// 못 사면 0.
int maxBuyableShares(int budget, int pricePerShare) {
  if (budget <= 0 || pricePerShare <= 0) return 0;
  // 수수료가 주수에 따라 달라지므로(최소액 구간) 한 번 어림잡고 넘치면 줄인다.
  var n = budget ~/ pricePerShare;
  while (n > 0 && buyTotalCost(n, pricePerShare) > budget) {
    n--;
  }
  return n;
}

// ─────────────────────────── 거래 · 보유 ───────────────────────────

/// 보유 계산에 필요한 거래 한 건. DB 타입에 묶이지 않게 최소 정보만 받는다.
typedef InvestTradeInput = ({
  String indexKey,
  String label,
  String symbol,
  bool isBuy,
  int shares,
  int pricePerShare,
  int fee,
  DateTime at,
});

/// 거래 한 건이 매수인지 판별하는 문자열. DB의 kind 컬럼 값.
const String kTradeBuy = 'buy';
const String kTradeSell = 'sell';

/// 지수 하나의 현재 보유 상태.
class Holding {
  final String indexKey;
  final String label;
  final String symbol;

  /// 남은 보유 주수
  final int shares;

  /// 남은 매수원가(매수 수수료 포함). 평단가의 분자.
  final int costBasis;

  /// 지금까지 이 지수에서 확정된 손익(매도해서 실현한 금액).
  final int realizedProfit;

  const Holding({
    required this.indexKey,
    required this.label,
    required this.symbol,
    required this.shares,
    required this.costBasis,
    required this.realizedProfit,
  });

  /// 평균 산 가격(원/주). 매수 수수료가 포함돼 있어 "이 값을 넘어야 이득"이 된다.
  int get avgPrice => shares <= 0 ? 0 : (costBasis / shares).round();

  bool get isEmpty => shares <= 0;

  /// 지금 1주 가격 기준 평가금액
  int marketValue(int nowSharePrice) => shares * nowSharePrice;

  /// 평가손익(매수 수수료 반영). 매도 수수료는 아직 확정이 아니라 넣지 않는다.
  int unrealizedProfit(int nowSharePrice) =>
      marketValue(nowSharePrice) - costBasis;

  /// 평가수익률 %
  double profitPercent(int nowSharePrice) =>
      costBasis <= 0 ? 0 : unrealizedProfit(nowSharePrice) / costBasis * 100;
}

/// 거래 원장을 접어서 지수별 보유 상태를 만든다(이동평균법).
///
/// 매도할 때는 파는 주수만큼 매수원가를 비례해서 덜어낸다. 전량 매도면 원가를
/// 정확히 0으로 맞춰 반올림 찌꺼기가 남지 않게 한다.
List<Holding> computeHoldings(List<InvestTradeInput> trades) {
  // 시각이 같으면 매수를 먼저 처리한다. 순서가 뒤집히면 "보유보다 많이 판 기록"으로
  // 보여 매도가 통째로 무시되고 주식이 공짜로 남는다.
  final sorted = [...trades]..sort((a, b) {
      final c = a.at.compareTo(b.at);
      return c != 0 ? c : (a.isBuy == b.isBuy ? 0 : (a.isBuy ? -1 : 1));
    });

  final shares = <String, int>{};
  final cost = <String, int>{};
  final realized = <String, int>{};
  final label = <String, String>{};
  final symbol = <String, String>{};
  final order = <String>[];

  for (final t in sorted) {
    final k = t.indexKey;
    if (!order.contains(k)) order.add(k);
    label[k] = t.label;
    symbol[k] = t.symbol;
    shares[k] ??= 0;
    cost[k] ??= 0;
    realized[k] ??= 0;

    if (t.isBuy) {
      shares[k] = shares[k]! + t.shares;
      cost[k] = cost[k]! + t.shares * t.pricePerShare + t.fee;
    } else {
      final held = shares[k]!;
      if (held <= 0) continue; // 보유보다 많이 판 기록은 무시(방어)
      final sell = t.shares > held ? held : t.shares;
      // 전량이면 원가를 통째로 털어 0으로 맞춘다.
      final soldCost =
          sell == held ? cost[k]! : (cost[k]! * sell / held).round();
      final proceeds = sell * t.pricePerShare - t.fee;
      realized[k] = realized[k]! + (proceeds - soldCost);
      shares[k] = held - sell;
      cost[k] = cost[k]! - soldCost;
    }
  }

  return [
    for (final k in order)
      Holding(
        indexKey: k,
        label: label[k] ?? k,
        symbol: symbol[k] ?? '',
        shares: shares[k] ?? 0,
        costBasis: cost[k] ?? 0,
        realizedProfit: realized[k] ?? 0,
      ),
  ];
}

/// 매도 정산 미리보기. 팔기 화면에서 항목별로 보여주려고 쪼개 담는다.
class SellQuote {
  /// 파는 주수
  final int shares;

  /// 1주 가격
  final int pricePerShare;

  /// 판 값(주수 × 1주 가격)
  final int gross;

  /// 매도 수수료(위탁 + 거래세)
  final int fee;

  /// 이 주식을 살 때 들인 돈(매수 수수료 포함, 비례 배분)
  final int soldCost;

  const SellQuote({
    required this.shares,
    required this.pricePerShare,
    required this.gross,
    required this.fee,
    required this.soldCost,
  });

  /// 실제로 손에 들어오는 돈
  int get netProceeds => gross - fee;

  /// 확정 손익(매수·매도 수수료 모두 반영)
  int get realizedProfit => netProceeds - soldCost;
}

/// [holding]에서 [sellShares]주를 [pricePerShare]에 팔 때의 정산 내역.
SellQuote quoteSell({
  required Holding holding,
  required int sellShares,
  required int pricePerShare,
}) {
  final n = sellShares.clamp(0, holding.shares);
  final gross = n * pricePerShare;
  final soldCost = holding.shares <= 0
      ? 0
      : (n == holding.shares
            ? holding.costBasis
            : (holding.costBasis * n / holding.shares).round());
  return SellQuote(
    shares: n,
    pricePerShare: pricePerShare,
    gross: gross,
    fee: sellFeeOf(gross),
    soldCost: soldCost,
  );
}

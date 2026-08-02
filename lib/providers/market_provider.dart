import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_search_service.dart';

/// "오늘의 지수" 시세(코스피/코스닥/나스닥).
/// autoDispose가 아니라 앱 세션 동안 한 번 받아 홈/주식탭이 공유한다(탭 전환마다 재요청 안 함).
/// 새로고침은 `ref.invalidate(marketIndicesProvider)`로 다시 받아온다.
final marketIndicesProvider = FutureProvider<List<MarketIndex>>((ref) async {
  return const StockSearchService().marketIndices();
});

/// 모의 투자 화면에서 쓰는 세계 지수 시세(코스피~유럽 7개).
final investIndicesProvider = FutureProvider<List<MarketIndex>>((ref) async {
  return const StockSearchService().investIndices();
});

/// 지수 차트용 과거 종가. key: (심볼, 기간).
final indexSeriesProvider = FutureProvider.family<List<double>,
    ({String symbol, String range})>((ref, args) async {
  return const StockSearchService().indexSeries(args.symbol, args.range);
});

/// 환율 계산기에서 다루는 통화. 야후에서 `{코드}KRW=X`로 조회되는 것만 넣었다
/// (베트남 동 등은 야후에 없어서 제외).
const List<({String code, String flag, String name, int per})> kFxCurrencies = [
  (code: 'USD', flag: '🇺🇸', name: '미국 달러', per: 1),
  // 엔화는 1엔이 10원 남짓이라 우리나라에서는 100엔 기준으로 이야기한다.
  (code: 'JPY', flag: '🇯🇵', name: '일본 엔', per: 100),
  (code: 'EUR', flag: '🇪🇺', name: '유로', per: 1),
  (code: 'CNY', flag: '🇨🇳', name: '중국 위안', per: 1),
];

/// 환율 계산기용 통화별 환율(1단위당 원). 실패한 통화는 빠진다.
final fxRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  return const StockSearchService()
      .fxRates(kFxCurrencies.map((c) => c.code).toList());
});

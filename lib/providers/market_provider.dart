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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_search_service.dart';

/// "오늘의 지수" 시세(코스피/코스닥/나스닥).
/// autoDispose가 아니라 앱 세션 동안 한 번 받아 홈/주식탭이 공유한다(탭 전환마다 재요청 안 함).
/// 새로고침은 `ref.invalidate(marketIndicesProvider)`로 다시 받아온다.
final marketIndicesProvider = FutureProvider<List<MarketIndex>>((ref) async {
  return const StockSearchService().marketIndices();
});

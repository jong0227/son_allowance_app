import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rates_service.dart';
import 'cofix_provider.dart';

/// "오늘의 금리" 지표 모음 (기준금리 / 정기예금 1년 / COFIX).
/// 기준금리·정기예금은 ECOS(내장 키 또는 사용자 키), COFIX는 은행연합회에서 가져온다.
/// 세션 동안 한 번 받아 공유하고, 새로고침은 `ref.invalidate(ratesProvider)`.
final ratesProvider = FutureProvider<List<RateInfo>>((ref) async {
  final config = ref.watch(cofixConfigProvider);
  return const RatesService().fetchAll(config.effectiveEcosKey);
});

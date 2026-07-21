import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rates_service.dart';
import 'cofix_provider.dart';
import 'settings_provider.dart';

/// "오늘의 금리" 지표 모음 (기준금리 / 정기예금 1년 / COFIX).
/// 기준금리·정기예금은 ECOS(내장 키 또는 사용자 키), COFIX는 은행연합회에서 가져온다.
/// 세션 동안 한 번 받아 공유하고, 새로고침은 `ref.invalidate(ratesProvider)`.
final ratesProvider = FutureProvider<List<RateInfo>>((ref) async {
  final config = ref.watch(cofixConfigProvider);
  return const RatesService().fetchAll(config.effectiveEcosKey);
});

/// 저축 이자 계산의 기준이 되는 실제 예금금리(정기예금 1년, 연 %).
/// 조회에 성공하면 값을 기기에 캐시해 두고, 실패(오프라인 등)하면 마지막 캐시값을 쓴다.
/// 한 번도 못 받아왔으면 null → 이자는 고정 이율로 폴백된다.
final depositRateProvider = FutureProvider<double?>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  try {
    final rates = await ref.watch(ratesProvider.future);
    for (final r in rates) {
      if (r.kind == RateKind.deposit) {
        await prefs.setDouble('cachedDepositRate', r.rate);
        return r.rate;
      }
    }
  } catch (_) {
    // 네트워크 실패 등 → 아래 캐시값으로 폴백
  }
  return prefs.getDouble('cachedDepositRate');
});

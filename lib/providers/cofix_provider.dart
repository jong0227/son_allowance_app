import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cofix_service.dart';
import 'settings_provider.dart';

/// 앱에 기본 내장된 한국은행 ECOS 인증키(기준금리·정기예금 자동조회용).
/// 설정에서 사용자가 직접 넣으면 그 값이 우선한다. COFIX는 이 키가 필요 없다.
const String kDefaultEcosApiKey = 'VQN04ECTY6QRXJ2ZMWJF';

/// COFIX 관련 설정(부모 수동 입력값 + ECOS 인증키). 기기 로컬 저장(동기화 안 함).
class CofixConfig {
  final double? manualRate; // 부모가 직접 입력한 COFIX % (자동조회 실패 시 폴백)
  final DateTime? manualDate; // 수동값 기준일(부모가 갱신한 날)
  final String ecosApiKey; // 사용자가 직접 넣은 ECOS 인증키(비우면 내장 기본키 사용)

  const CofixConfig({this.manualRate, this.manualDate, this.ecosApiKey = ''});

  bool get hasManual => manualRate != null;
  bool get hasCustomKey => ecosApiKey.trim().isNotEmpty;

  /// 실제 사용할 ECOS 키: 사용자가 넣었으면 그것, 아니면 내장 기본키.
  String get effectiveEcosKey =>
      ecosApiKey.trim().isEmpty ? kDefaultEcosApiKey : ecosApiKey.trim();
}

class CofixConfigNotifier extends StateNotifier<CofixConfig> {
  final SharedPreferences prefs;
  CofixConfigNotifier(this.prefs) : super(_load(prefs));

  static CofixConfig _load(SharedPreferences p) {
    final dateStr = p.getString('cofixManualDate');
    return CofixConfig(
      manualRate: p.getDouble('cofixManualRate'),
      manualDate: dateStr == null ? null : DateTime.tryParse(dateStr),
      ecosApiKey: p.getString('ecosApiKey') ?? '',
    );
  }

  Future<void> setManualRate(double rate) async {
    final now = DateTime.now();
    await prefs.setDouble('cofixManualRate', rate);
    await prefs.setString('cofixManualDate', now.toIso8601String());
    state = CofixConfig(manualRate: rate, manualDate: now, ecosApiKey: state.ecosApiKey);
  }

  Future<void> setEcosApiKey(String key) async {
    await prefs.setString('ecosApiKey', key.trim());
    state = CofixConfig(
        manualRate: state.manualRate, manualDate: state.manualDate, ecosApiKey: key.trim());
  }
}

final cofixConfigProvider =
    StateNotifierProvider<CofixConfigNotifier, CofixConfig>((ref) {
  return CofixConfigNotifier(ref.watch(sharedPreferencesProvider));
});

/// 이자 카드/설명에 보여줄 COFIX 값. 은행연합회 자동조회를 먼저 시도하고,
/// 실패하면 부모 수동입력값으로 폴백한다. 둘 다 없으면 null.
final cofixProvider = FutureProvider<CofixInfo?>((ref) async {
  final config = ref.watch(cofixConfigProvider);
  final auto = await const CofixService().fetchCofix();
  if (auto != null) return auto;
  if (config.hasManual) {
    return CofixInfo(rate: config.manualRate!, asOf: config.manualDate, isAuto: false);
  }
  return null;
});

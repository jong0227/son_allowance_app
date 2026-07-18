import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import 'database_provider.dart';

/// 누적 저축 티어 목록(정렬됨).
final savingsTiersProvider = StreamProvider<List<Tier>>((ref) {
  return ref.watch(databaseProvider).watchTiers('savings');
});

/// 주간 저축률 티어 목록(정렬됨).
final weeklyTiersProvider = StreamProvider<List<Tier>>((ref) {
  return ref.watch(databaseProvider).watchTiers('weekly');
});

/// 현재 값에 해당하는 티어(threshold <= value 중 가장 높은 것)와 다음 티어.
class TierPosition {
  final Tier? current;
  final Tier? next;
  final int value;
  const TierPosition(this.current, this.next, this.value);

  /// 다음 티어까지 남은 값(원 또는 %). 다음이 없으면 null.
  int? get remaining =>
      next == null ? null : (next!.threshold - value).clamp(0, next!.threshold);

  /// 현재 티어 시작~다음 티어 사이 진행률 0~1.
  double get progress {
    if (current == null) return 0;
    if (next == null) return 1;
    final span = next!.threshold - current!.threshold;
    if (span <= 0) return 1;
    return ((value - current!.threshold) / span).clamp(0.0, 1.0);
  }
}

/// 누적 저축 티어의 영어(마인크래프트) 명칭. 기본 시드 id 기준.
/// 부모가 칭호를 바꿔도 마크 영문명은 그대로 보여준다(없으면 표시 안 함).
const Map<String, String> _tierEnglish = {
  'sav_01': 'Dirt',
  'sav_02': 'Wood',
  'sav_03': 'Cobblestone',
  'sav_04': 'Coal',
  'sav_05': 'Copper',
  'sav_06': 'Iron',
  'sav_07': 'Gold',
  'sav_08': 'Redstone',
  'sav_09': 'Lapis',
  'sav_10': 'Emerald',
  'sav_11': 'Diamond',
  'sav_12': 'Netherite',
  'sav_13': 'Ender Dragon',
  'sav_14': 'Beacon',
  'sav_15': 'Nether Star',
  'sav_16': 'End Crystal',
};

String? tierEnglishName(String id) => _tierEnglish[id];

/// 티어별 이미지 파일명(assets/tiers/*.png). 파일이 있으면 이미지, 없으면 이모지 표시.
/// 부모가 직접 마인크래프트 블럭 이미지를 이 이름으로 넣으면 자동 적용된다.
const Map<String, String> _tierAssetName = {
  'sav_01': 'dirt',
  'sav_02': 'wood',
  'sav_03': 'cobblestone',
  'sav_04': 'coal',
  'sav_05': 'copper',
  'sav_06': 'iron',
  'sav_07': 'gold',
  'sav_08': 'redstone',
  'sav_09': 'lapis',
  'sav_10': 'emerald',
  'sav_11': 'diamond',
  'sav_12': 'netherite',
  'sav_13': 'ender_dragon',
  'sav_14': 'beacon',
  'sav_15': 'nether_star',
  'sav_16': 'end_crystal',
};

String? tierAssetPath(String id) {
  final n = _tierAssetName[id];
  return n == null ? null : 'assets/tiers/$n.png';
}

TierPosition tierFor(List<Tier> tiers, int value) {
  Tier? current;
  Tier? next;
  for (final t in tiers) {
    if (value >= t.threshold) {
      current = t;
    } else {
      next = t;
      break;
    }
  }
  return TierPosition(current, next, value);
}

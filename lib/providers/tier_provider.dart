import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_database.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

/// 티어별 "내가 넣은 이미지" 파일 경로 맵 (tierId -> 로컬 파일경로).
/// 기기 로컬(SharedPreferences)에만 저장되고 동기화되지 않는다(아바타와 동일).
final tierIconPathsProvider =
    StateNotifierProvider<TierIconPaths, Map<String, String>>((ref) {
  return TierIconPaths(ref.watch(sharedPreferencesProvider));
});

class TierIconPaths extends StateNotifier<Map<String, String>> {
  final SharedPreferences prefs;
  TierIconPaths(this.prefs) : super(_load(prefs));

  static Map<String, String> _load(SharedPreferences p) {
    final s = p.getString('tierIconPaths');
    if (s == null) return {};
    try {
      return Map<String, String>.from(jsonDecode(s) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> setPath(String tierId, String path) async {
    final m = {...state, tierId: path};
    await prefs.setString('tierIconPaths', jsonEncode(m));
    state = m;
  }

  Future<void> clearPath(String tierId) async {
    final m = {...state}..remove(tierId);
    await prefs.setString('tierIconPaths', jsonEncode(m));
    state = m;
  }
}

/// 누적 저축 티어 목록(정렬됨).
final savingsTiersProvider = StreamProvider<List<Tier>>((ref) {
  return ref.watch(databaseProvider).watchTiers('savings');
});

/// 주간 저축률 티어 목록(정렬됨).
final weeklyTiersProvider = StreamProvider<List<Tier>>((ref) {
  return ref.watch(databaseProvider).watchTiers('weekly');
});

/// 이번 주(월~일) 쓴 돈. 주간 저축률·절약 보너스가 모두 이 값을 쓴다.
///
/// 예전엔 이 계산이 상단 배지·홈 티어 카드·예산 카드·절약보너스 카드에 네 벌
/// 복사돼 있어 규칙을 바꿀 때마다 한 곳씩 어긋날 위험이 있었다. 여기 한 곳에서만 계산한다.
///
/// 모의투자 손실은 빼고 센다. 용돈을 "쓴" 게 아니라 투자 결과이고, 주식을 살 때는
/// 지출로 안 잡히는데 손해 보고 팔 때만 지출로 잡히면 앞뒤가 안 맞는다.
/// (카테고리 통계도 같은 이유로 이미 투자 손실을 빼고 있다)
int weeklySpent(Iterable<TransactionEntry> txs, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final weekStart =
      DateTime(n.year, n.month, n.day).subtract(Duration(days: n.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  var spent = 0;
  for (final t in txs) {
    if (t.flow != 'expense') continue;
    if (t.category == AppDatabase.kInvestLoss) continue;
    if (t.date.isBefore(weekStart) || !t.date.isBefore(weekEnd)) continue;
    spent += t.amount;
  }
  return spent;
}

/// 이번 주 저축률(0~100, 정수). 용돈을 한 푼도 안 썼을 때만 100.
///
/// ⚠️ 반드시 **내림**. 예전엔 반올림이라 용돈 3,000원 중 10원만 써도 99.67% → 100%로
/// "완벽 저축왕"이 나왔고, 10% 단위 등급에선 모든 경계(39.6% → 40%)에서 한 칸 위를
/// 줬다. 정수 나눗셈이라 부동소수 오차(0.29×100 = 28.999…)도 생기지 않는다.
int weeklySavePercent(Iterable<TransactionEntry> txs, int weeklyBudget,
    {DateTime? now}) {
  if (weeklyBudget <= 0) return 0;
  final remaining = weeklyBudget - weeklySpent(txs, now: now);
  if (remaining <= 0) return 0;
  return (remaining * 100 ~/ weeklyBudget).clamp(0, 100);
}

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
const Map<String, String> _tierEnglish = {
  'sav_01': 'Dirt',
  'sav_02': 'Wood',
  'sav_03': 'Wheat Seeds',
  'sav_04': 'Wheat',
  'sav_05': 'Glass',
  'sav_06': 'Coal',
  'sav_07': 'Water',
  'sav_08': 'Diorite',
  'sav_09': 'Stone',
  'sav_10': 'Copper',
  'sav_11': 'Iron',
  'sav_12': 'Gold',
  'sav_13': 'Lapis',
  'sav_14': 'Redstone',
  'sav_15': 'Emerald',
  'sav_16': 'Diamond',
  'sav_17': 'Netherite',
  'sav_18': 'Obsidian',
  'sav_19': 'Nether Portal',
  'sav_20': 'Beacon',
  'sav_21': 'Ender Ruins',
  'sav_22': 'Ender Portal',
  'sav_23': 'Ender Dragon',
  'sav_24': 'Star of Nether',
  'sav_25': 'End Crystal',
  'sav_26': 'Herobrine',
  'sav_27': 'Mojang',
  'sav_28': 'Torch',
  'sav_29': 'Sweden',
  'sav_30': 'Great richest',
  'sav_31': 'How Did We Get Here?',
};

String? tierEnglishName(String id) => _tierEnglish[id];

/// 티어별 이미지 파일명(assets/tiers/*.png). 파일이 있으면 이미지, 없으면 이모지 표시.
const Map<String, String> _tierAssetName = {
  'sav_01': 'dirt',
  'sav_02': 'wood',
  'sav_03': 'wheat_seeds',
  'sav_04': 'wheat',
  'sav_05': 'glass',
  'sav_06': 'coal',
  'sav_07': 'water',
  'sav_08': 'diorite',
  'sav_09': 'stone',
  'sav_10': 'copper',
  'sav_11': 'iron',
  'sav_12': 'gold',
  'sav_13': 'lapis',
  'sav_14': 'redstone',
  'sav_15': 'emerald',
  'sav_16': 'diamond',
  'sav_17': 'netherite',
  'sav_18': 'obsidian',
  'sav_19': 'nether_portal',
  'sav_20': 'beacon',
  'sav_21': 'ender_ruins',
  'sav_22': 'ender_portal',
  'sav_23': 'ender_dragon',
  'sav_24': 'nether_star',
  'sav_25': 'end_crystal',
  'sav_26': 'herobrine',
  'sav_27': 'mojang',
  'sav_28': 'torch',
  // sav_29~31(스웨덴/대애애바아악부우우자아아/어떻게 여기까지)은 마인크래프트 밖 등급이라
  // 커스텀 이미지가 없다 — 이모지로 자동 폴백된다.
};

String? tierAssetPath(String id) {
  final n = _tierAssetName[id];
  return n == null ? null : 'assets/tiers/$n.png';
}

TierPosition tierFor(List<Tier> tiers, int value) {
  // 기준값 순으로 정렬해서 본다. 목록은 sortOrder 순으로 오는데, 부모가 설정 화면에서
  // 기준을 순서가 뒤바뀌게 고치면(예: 40% → 15%) 둘이 어긋나고, 그러면 아래 break에서
  // 일찍 멈춰 엉뚱한 등급을 골랐다. 동기화 중 잠깐 sortOrder가 섞일 때도 같다.
  final sorted = [...tiers]..sort((a, b) {
      final c = a.threshold.compareTo(b.threshold);
      return c != 0 ? c : a.sortOrder.compareTo(b.sortOrder);
    });
  Tier? current;
  Tier? next;
  for (final t in sorted) {
    if (value >= t.threshold) {
      current = t;
    } else {
      next = t;
      break;
    }
  }
  return TierPosition(current, next, value);
}

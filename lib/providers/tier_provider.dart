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

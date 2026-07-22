import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/economy_topics.dart';
import 'settings_provider.dart';

/// 읽은 경제상식 주제 id 목록. 기기 로컬 저장(아이 폰에서 읽은 기록이 남으면 충분).
class ReadTopics extends StateNotifier<Set<String>> {
  final SharedPreferences prefs;
  ReadTopics(this.prefs) : super(prefs.getStringList('readTopics')?.toSet() ?? {});

  Future<void> markRead(String id) async {
    if (state.contains(id)) return;
    final next = {...state, id};
    await prefs.setStringList('readTopics', next.toList());
    state = next;
  }

  bool isRead(String id) => state.contains(id);
}

final readTopicsProvider =
    StateNotifierProvider<ReadTopics, Set<String>>((ref) {
  return ReadTopics(ref.watch(sharedPreferencesProvider));
});

/// 오늘 추천할 경제상식 한 개.
/// - 아직 안 읽은 주제 중에서 "날짜"로 정해 매일 바뀌게 한다(같은 날엔 항상 같은 주제).
/// - 다 읽었으면 전체 중에서 날짜로 하나 골라 복습용으로 보여준다.
final todayTopicProvider = Provider<EconomyTopic?>((ref) {
  if (kEconomyTopics.isEmpty) return null;
  final read = ref.watch(readTopicsProvider);
  final now = DateTime.now();
  final dayNumber = DateTime(now.year, now.month, now.day)
      .difference(DateTime(2020, 1, 1))
      .inDays;

  final unread = kEconomyTopics.where((t) => !read.contains(t.id)).toList();
  final pool = unread.isNotEmpty ? unread : kEconomyTopics;
  return pool[dayNumber % pool.length];
});

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../data/quiz_bank.dart';
import 'database_provider.dart';

/// 한 주에 풀 수 있는 문제 수.
const int kQuizPerWeek = 3;

/// 첫 시도에 맞췄을 때 / 해설을 보고 다시 맞췄을 때 보상(원).
const int kQuizFullReward = 100;
const int kQuizHalfReward = 50;

/// 남은 문제가 이 개수 이하면 부모에게 "새 문제를 추가해 주세요"라고 알린다.
const int kQuizLowBankThreshold = 5;

/// 문제 출제 순서. 고정 시드로 섞어서 주제가 골고루 나오게 하되,
/// 모든 기기에서 같은 순서가 나오도록(동기화 안전) 결정적으로 만든다.
final List<QuizQuestion> _orderedBank = () {
  final list = [...kQuizBank];
  list.shuffle(Random(20260721));
  return List<QuizQuestion>.unmodifiable(list);
}();

/// 퀴즈 화면이 필요로 하는 상태 묶음.
class QuizState {
  final List<QuizAttempt> attempts; // 전체 응답 기록
  final DateTime weekStart;

  const QuizState({required this.attempts, required this.weekStart});

  /// 이미 푼 문제 id (다시 내지 않는다).
  Set<String> get answeredIds => attempts.map((a) => a.questionId).toSet();

  List<QuizAttempt> get thisWeek =>
      attempts.where((a) => !a.weekStart.isBefore(weekStart)).toList();

  int get answeredThisWeek => thisWeek.length;
  int get correctThisWeek => thisWeek.where((a) => a.correct).length;
  int get earnedThisWeek => thisWeek.fold<int>(0, (s, a) => s + a.reward);
  int get totalEarned => attempts.fold<int>(0, (s, a) => s + a.reward);

  /// 이번 주 할당량을 다 풀었는지.
  bool get weekDone => answeredThisWeek >= kQuizPerWeek;

  /// 아직 한 번도 안 나온 문제들(출제 순서대로).
  List<QuizQuestion> get unused =>
      _orderedBank.where((q) => !answeredIds.contains(q.id)).toList();

  int get remainingInBank => unused.length;
  bool get bankRunningLow => remainingInBank <= kQuizLowBankThreshold;
  bool get bankEmpty => remainingInBank == 0;

  /// 지금 풀어야 할 문제. 이번 주를 다 풀었거나 문제가 떨어지면 null.
  QuizQuestion? get current {
    if (weekDone) return null;
    final list = unused;
    return list.isEmpty ? null : list.first;
  }

  /// 이번 주 남은 문제 수.
  int get leftThisWeek => (kQuizPerWeek - answeredThisWeek).clamp(0, kQuizPerWeek);
}

final quizStateProvider = StreamProvider.family<QuizState, String>((ref, childId) {
  final db = ref.watch(databaseProvider);
  return db.watchQuizAttempts(childId).map(
        (attempts) => QuizState(
          attempts: attempts,
          weekStart: AppDatabase.weekStartOf(DateTime.now()),
        ),
      );
});

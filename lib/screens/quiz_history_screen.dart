import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../data/quiz_bank.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 경제왕 퀴즈 기록.
/// - 푼 문제: 질문과 보기 전부, 내가 고른 답, 정답, 해설을 다시 볼 수 있다.
/// - 남은 문제: 아이가 미리 답을 외우지 못하도록 **부모 모드에서만** 보인다.
class QuizHistoryScreen extends ConsumerWidget {
  final String childId;
  const QuizHistoryScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(quizStateProvider(childId));
    final isChild = ref.watch(settingsProvider).isChild;

    return Scaffold(
      appBar: AppBar(title: const Text('퀴즈 기록')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (state) {
          // 같은 문제를 여러 번 시도했을 수 있으니 문제별 마지막 기록만 본다.
          final byQuestion = <String, QuizAttempt>{};
          for (final a in state.attempts) {
            final prev = byQuestion[a.questionId];
            if (prev == null || a.answeredAt.isAfter(prev.answeredAt)) {
              byQuestion[a.questionId] = a;
            }
          }
          final solved = state.attempts
              .map((a) => a.questionId)
              .toSet()
              .map((id) => _find(id))
              .whereType<QuizQuestion>()
              .toList();
          // 최근에 푼 순서
          solved.sort((a, b) => byQuestion[b.id]!
              .answeredAt
              .compareTo(byQuestion[a.id]!.answeredAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _SummaryCard(state: state, solvedCount: solved.length),
              SectionHeader('푼 문제 ${solved.length}개'),
              if (solved.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('아직 푼 문제가 없어요. 퀴즈를 풀어보세요!'),
                  ),
                ),
              for (final q in solved)
                _SolvedTile(question: q, attempt: byQuestion[q.id]!),
              if (!isChild) ...[
                SectionHeader('남은 문제 ${state.remainingInBank}개 (부모만 보임)'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('아이에게는 보이지 않아요. 새 문제를 준비할 때 참고하세요.',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        if (state.unused.isEmpty)
                          const Text('남은 문제가 없어요. 새 문제를 추가해 주세요!')
                        else
                          for (final q in state.unused)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TagChip(label: q.topic),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(q.question,
                                            style: const TextStyle(fontSize: 13.5)),
                                        Text('정답: ${q.answerText}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  QuizQuestion? _find(String id) {
    for (final q in kQuizBank) {
      if (q.id == id) return q;
    }
    return null; // 예전 문제은행에만 있던 문제
  }
}

class _SummaryCard extends StatelessWidget {
  final QuizState state;
  final int solvedCount;
  const _SummaryCard({required this.state, required this.solvedCount});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).income;
    final correct = state.attempts.where((a) => a.correct).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$solvedCount문제 풀고 $correct개 정답',
                    style: TextStyle(
                        color: pair.fg, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('퀴즈로 모은 돈 ${formatWon(state.totalEarned)}',
                    style: TextStyle(color: pair.fg, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 푼 문제 하나 — 펼치면 보기 전부와 내가 고른 답, 정답, 해설이 보인다.
class _SolvedTile extends StatelessWidget {
  final QuizQuestion question;
  final QuizAttempt attempt;
  const _SolvedTile({required this.question, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final ok = attempt.correct;
    final pair = ok ? palette.income : palette.expense;

    return Card(
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(ok ? Icons.check_circle : Icons.cancel,
              color: pair.fg, size: 22),
          title: Text(question.question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Row(
            children: [
              Text(question.topic,
                  style:
                      TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 8),
              Text(formatDateShort(attempt.answeredAt),
                  style:
                      TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
              if (attempt.reward > 0) ...[
                const SizedBox(width: 8),
                Text('+${formatWon(attempt.reward)}',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: palette.income.fg,
                        fontWeight: FontWeight.w800)),
              ],
            ],
          ),
          children: [
            for (var i = 0; i < question.options.length; i++)
              _OptionRow(
                text: question.options[i],
                isAnswer: i == question.answerIndex,
                isPicked: attempt.pickedIndex == i,
              ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: palette.allowance.bg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(question.explanation,
                        style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: palette.allowance.fg)),
                  ),
                ],
              ),
            ),
            if (!attempt.firstTry && attempt.correct)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('해설을 읽고 다시 풀어서 맞췄어요',
                    style:
                        TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String text;
  final bool isAnswer;
  final bool isPicked;
  const _OptionRow(
      {required this.text, required this.isAnswer, required this.isPicked});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final pair = isAnswer ? palette.income : (isPicked ? palette.expense : null);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: pair?.bg ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isAnswer
                ? Icons.check_circle
                : (isPicked ? Icons.cancel : Icons.circle_outlined),
            size: 16,
            color: pair?.fg ?? theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: (isAnswer || isPicked) ? FontWeight.w700 : null,
                    color: pair?.fg ?? theme.colorScheme.onSurface)),
          ),
          if (isPicked)
            Text(isAnswer ? '내 답 ✓' : '내가 고른 답',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pair?.fg ?? theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

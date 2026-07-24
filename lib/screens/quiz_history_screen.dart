import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/quiz_bank.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 아이가 지금까지 푼 경제왕 퀴즈 기록. 부모가 "무엇을 풀었고 어떻게 맞췄는지"
/// 확인할 수 있게 한다. (준비된 문제 수 / 푼 문제 수도 함께)
class QuizHistoryScreen extends ConsumerWidget {
  final String childId;
  final String childName;
  const QuizHistoryScreen({super.key, required this.childId, required this.childName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(quizStateProvider(childId));
    final palette = appPalette(context);
    final byId = {for (final q in kQuizBank) q.id: q};
    // 남은 문제 정보(개수·내용)는 아이가 미리 답을 외우지 못하도록 부모에게만 보여준다.
    final isChild = ref.watch(settingsProvider).isChild;

    return Scaffold(
      appBar: AppBar(title: const Text('경제왕 퀴즈 기록')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (state) {
          final total = kQuizBank.length;
          final solved = state.answeredIds.length;
          final correct = state.attempts.where((a) => a.correct).length;
          final firstTry = state.attempts.where((a) => a.firstTry && a.correct).length;
          // 최신순
          final attempts = [...state.attempts]
            ..sort((a, b) => b.answeredAt.compareTo(a.answeredAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // 요약: 준비된 문제 / 푼 문제 / 모은 돈
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: palette.income.bg, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$childName의 퀴즈 성적',
                        style: TextStyle(
                            fontSize: 13, color: palette.income.fg.withValues(alpha: 0.85))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Stat(label: '푼 문제', value: '$solved / $total개', pair: palette.income),
                        const SizedBox(width: 8),
                        _Stat(label: '정답', value: '$correct개', pair: palette.income),
                        const SizedBox(width: 8),
                        _Stat(
                            label: '모은 돈',
                            value: formatWon(state.totalEarned),
                            pair: palette.income),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isChild
                          ? '한 번에 맞춘 문제 $firstTry개'
                          : '한 번에 맞춘 문제 $firstTry개 · 남은 문제 ${state.remainingInBank}개',
                      style: TextStyle(
                          fontSize: 12.5, color: palette.income.fg.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (!isChild && state.remainingInBank <= kQuizLowBankThreshold)
                _Notice(
                  pair: palette.expense,
                  text: state.remainingInBank == 0
                      ? '준비된 문제를 모두 풀었어요. 새 문제를 추가하면 다시 풀 수 있어요.'
                      : '남은 문제가 ${state.remainingInBank}개예요. 곧 새 문제가 필요해요.',
                ),
              // 부모만: 아이가 아직 안 푼 문제를 미리 볼 수 있게 한다(정답·해설 포함).
              // 아이에게는 절대 안 보여준다(미리 외우면 퀴즈 의미가 없어짐).
              if (!isChild) ...[
                const SectionHeader('안 푼 문제 미리 보기'),
                _UnsolvedSection(questions: state.unused, palette: palette),
              ],
              const SectionHeader('푼 문제 기록'),
              if (attempts.isEmpty)
                _Notice(pair: palette.savings, text: '아직 푼 문제가 없어요.')
              else
                for (final a in attempts)
                  _AttemptTile(
                    question: byId[a.questionId],
                    correct: a.correct,
                    firstTry: a.firstTry,
                    reward: a.reward,
                    answeredAt: a.answeredAt,
                    pickedIndex: a.pickedIndex,
                    palette: palette,
                  ),
            ],
          );
        },
      ),
    );
  }
}

/// 아직 안 푼 문제를 주제별로 묶어 미리 볼 수 있는 부모 전용 섹션.
/// 기본은 접어둬서(전체 펼치면 화면이 너무 길어짐) 필요할 때만 열어본다.
class _UnsolvedSection extends StatelessWidget {
  final List<QuizQuestion> questions;
  final AppPalette palette;
  const _UnsolvedSection({required this.questions, required this.palette});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return _Notice(pair: palette.savings, text: '준비된 문제를 모두 풀었어요.');
    }
    // 주제별로 묶되, 문제은행에 나온 주제 순서를 그대로 따른다.
    final byTopic = <String, List<QuizQuestion>>{};
    for (final q in questions) {
      byTopic.putIfAbsent(q.topic, () => []).add(q);
    }
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          leading: CircleAvatar(
            backgroundColor: palette.allowance.bg,
            child: Icon(Icons.visibility_outlined, color: palette.allowance.fg),
          ),
          title: Text('안 푼 문제 ${questions.length}개',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text('주제별로 정답·해설까지 미리 확인할 수 있어요',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          children: [
            for (final entry in byTopic.entries) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${entry.key} · ${entry.value.length}개',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurfaceVariant)),
              ),
              for (final q in entry.value) _UnsolvedTile(question: q, palette: palette),
            ],
          ],
        ),
      ),
    );
  }
}

/// 안 푼 문제 하나. 펼치면 보기 전부 + 정답 + 해설을 볼 수 있다(부모 전용).
class _UnsolvedTile extends StatelessWidget {
  final QuizQuestion question;
  final AppPalette palette;
  const _UnsolvedTile({required this.question, required this.palette});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Text(question.question,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          children: [
            for (var i = 0; i < question.options.length; i++)
              _OptionRow(
                text: question.options[i],
                isAnswer: i == question.answerIndex,
                isPicked: false,
                palette: palette,
              ),
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
                            fontSize: 13, height: 1.5, color: palette.allowance.fg)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final PastelPair pair;
  const _Stat({required this.label, required this.value, required this.pair});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: pair.fg.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: pair.fg)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: pair.fg)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final QuizQuestion? question;
  final bool correct;
  final bool firstTry;
  final int reward;
  final DateTime answeredAt;
  final int? pickedIndex;
  final AppPalette palette;
  const _AttemptTile({
    required this.question,
    required this.correct,
    required this.firstTry,
    required this.reward,
    required this.answeredAt,
    required this.pickedIndex,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pair = correct ? palette.income : palette.expense;
    final resultText = !correct
        ? '틀림'
        : firstTry
            ? '한 번에 정답'
            : '해설 보고 정답';
    final q = question;

    return Card(
      child: Theme(
        // 펼쳤을 때 위아래 구분선이 생기지 않도록
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: CircleAvatar(
            backgroundColor: pair.bg,
            child: Icon(correct ? Icons.check : Icons.close, color: pair.fg),
          ),
          title: Text(q?.question ?? '(삭제된 문제)',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${q?.topic ?? ''} · $resultText · ${formatDate(answeredAt)}'
              '${reward > 0 ? ' · +${formatWon(reward)}' : ''}',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          children: [
            if (q == null)
              Text('문제 내용을 찾을 수 없어요.',
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant))
            else ...[
              // 보기를 전부 보여주고 "내가 고른 답"과 정답을 표시한다.
              for (var i = 0; i < q.options.length; i++)
                _OptionRow(
                  text: q.options[i],
                  isAnswer: i == q.answerIndex,
                  isPicked: pickedIndex == i,
                  palette: palette,
                ),
              if (pickedIndex == null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 6),
                  child: Text('(이 기록엔 고른 답이 저장되어 있지 않아요)',
                      style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: palette.allowance.bg,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(q.explanation,
                          style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: palette.allowance.fg)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 기록에서 보기 한 줄 — 정답은 초록, 내가 틀리게 고른 답은 빨강으로 표시.
class _OptionRow extends StatelessWidget {
  final String text;
  final bool isAnswer;
  final bool isPicked;
  final AppPalette palette;
  const _OptionRow({
    required this.text,
    required this.isAnswer,
    required this.isPicked,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pair = isAnswer ? palette.income : (isPicked ? palette.expense : null);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: pair?.bg ?? scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isAnswer
                ? Icons.check_circle
                : (isPicked ? Icons.cancel : Icons.circle_outlined),
            size: 16,
            color: pair?.fg ?? scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: (isAnswer || isPicked) ? FontWeight.w700 : null,
                    color: pair?.fg ?? scheme.onSurface)),
          ),
          if (isPicked)
            Text(isAnswer ? '내 답 ✓' : '내가 고른 답',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pair?.fg ?? scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final PastelPair pair;
  final String text;
  const _Notice({required this.pair, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: TextStyle(color: pair.fg, fontSize: 13, height: 1.4)),
    );
  }
}

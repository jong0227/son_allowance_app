import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../data/quiz_bank.dart';
import '../providers/database_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 해설을 실제로 읽도록 강제하는 최소 시간(초).
const int _readSeconds = 5;

enum _Phase { asking, explaining, retrying, correct, failed }

/// 도전! 경제왕 Quiz — 주 1회 3문제.
/// 첫 시도에 맞추면 100원, 틀리면 해설을 읽고 다시 풀어 맞추면 50원.
/// 재도전 때는 보기 순서를 섞어서 "정답 위치"만 외워 찍는 걸 막는다.
class QuizScreen extends ConsumerStatefulWidget {
  final Child child;
  const QuizScreen({super.key, required this.child});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  _Phase _phase = _Phase.asking;
  String? _questionId; // 지금 화면에 띄운 문제(바뀌면 상태 초기화)
  List<int> _order = [0, 1, 2]; // 보기 표시 순서
  int? _picked; // 사용자가 고른 보기(원본 인덱스)
  int _reward = 0;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetFor(QuizQuestion q) {
    _questionId = q.id;
    _phase = _Phase.asking;
    _order = List.generate(q.options.length, (i) => i);
    _picked = null;
    _reward = 0;
    _timer?.cancel();
    _countdown = 0;
  }

  void _startReadTimer() {
    _countdown = _readSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _countdown--;
        if (_countdown <= 0) t.cancel();
      });
    });
  }

  Future<void> _answer(QuizQuestion q, int originalIndex) async {
    final isCorrect = originalIndex == q.answerIndex;
    final firstTry = _phase == _Phase.asking;
    final full = widget.child.quizReward;

    if (isCorrect) {
      final reward = firstTry ? full : quizHalfReward(full);
      setState(() {
        _picked = originalIndex;
        _reward = reward;
        _phase = _Phase.correct;
      });
      await ref.read(databaseProvider).recordQuizAnswer(
            childId: widget.child.id,
            questionId: q.id,
            correct: true,
            firstTry: firstTry,
            reward: reward,
            pickedIndex: originalIndex,
            editedBy: ref.read(settingsProvider).deviceOwner ?? '',
          );
      return;
    }

    if (firstTry) {
      // 틀림 → 해설을 읽게 하고, 보기를 섞어서 다시 풀게 한다.
      setState(() {
        _picked = originalIndex;
        _phase = _Phase.explaining;
      });
      _startReadTimer();
    } else {
      // 두 번째도 틀림 → 정답을 알려주고 이번 문제는 마무리(보상 없음).
      setState(() {
        _picked = originalIndex;
        _reward = 0;
        _phase = _Phase.failed;
      });
      await ref.read(databaseProvider).recordQuizAnswer(
            childId: widget.child.id,
            questionId: q.id,
            correct: false,
            firstTry: false,
            reward: 0,
            pickedIndex: originalIndex,
            editedBy: ref.read(settingsProvider).deviceOwner ?? '',
          );
    }
  }

  void _goRetry(QuizQuestion q) {
    setState(() {
      _order = List.generate(q.options.length, (i) => i)..shuffle(Random());
      _picked = null;
      _phase = _Phase.retrying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(quizStateProvider(widget.child.id));
    return Scaffold(
      appBar: AppBar(title: const Text('도전! 경제왕 Quiz')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (state) {
          if (state.weekDone) return _WeekDoneView(state: state);
          final q = state.current;
          if (q == null) return const _BankEmptyView();
          if (_questionId != q.id) _resetFor(q);
          return _buildQuestion(context, state, q);
        },
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, QuizState state, QuizQuestion q) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final showingOptions = _phase == _Phase.asking || _phase == _Phase.retrying;
    final done = state.answeredThisWeek;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // 진행 상황
        Row(
          children: [
            for (var i = 0; i < kQuizPerWeek; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < done
                        ? palette.income.fg
                        : (i == done
                            ? palette.income.bg
                            : theme.colorScheme.surfaceContainerHighest),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (i < kQuizPerWeek - 1) const SizedBox(width: 6),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TagChip(label: q.topic),
            const Spacer(),
            Text('${done + 1} / $kQuizPerWeek 문제',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 16),
        Text(q.question,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.4)),
        const SizedBox(height: 20),

        if (showingOptions)
          for (final idx in _order)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionButton(
                text: q.options[idx],
                onTap: () => _answer(q, idx),
              ),
            ),

        if (_phase == _Phase.explaining) ...[
          _WrongCard(picked: _picked == null ? '' : q.options[_picked!]),
          const SizedBox(height: 12),
          _ExplanationCard(explanation: q.explanation),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _countdown > 0 ? null : () => _goRetry(q),
              child: Text(_countdown > 0
                  ? '해설을 읽어보세요 ($_countdown)'
                  : '이해했어요! 다시 풀기 (맞히면 ${formatWon(quizHalfReward(widget.child.quizReward))})'),
            ),
          ),
        ],

        if (_phase == _Phase.correct) ...[
          _CorrectCard(reward: _reward, firstTry: _reward == widget.child.quizReward),
          const SizedBox(height: 12),
          _ExplanationCard(explanation: q.explanation),
          const SizedBox(height: 16),
          _NextButton(state: state, onNext: () => setState(() => _questionId = null)),
        ],

        if (_phase == _Phase.failed) ...[
          _AnswerRevealCard(answer: q.answerText),
          const SizedBox(height: 12),
          _ExplanationCard(explanation: q.explanation),
          const SizedBox(height: 16),
          _NextButton(state: state, onNext: () => setState(() => _questionId = null)),
        ],
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _OptionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor, width: 1.4),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _WrongCard extends StatelessWidget {
  final String picked;
  const _WrongCard({required this.picked});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).expense;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Text('🤔', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('아쉬워요!',
                    style: TextStyle(
                        color: pair.fg, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('아래 설명을 읽고 다시 풀어보면 절반을 받을 수 있어요.',
                    style: TextStyle(color: pair.fg, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String explanation;
  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).allowance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text('알아두기',
                  style:
                      TextStyle(color: pair.fg, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Text(explanation,
              style: TextStyle(color: pair.fg, fontSize: 14.5, height: 1.55)),
        ],
      ),
    );
  }
}

/// 정답 축하 카드 — 아이가 뿌듯하도록 적립 안내를 크게 보여준다.
class _CorrectCard extends StatelessWidget {
  final int reward;
  final bool firstTry;
  const _CorrectCard({required this.reward, required this.firstTry});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).income;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Text(firstTry ? '🎉' : '👏', style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 6),
          Text(firstTry ? '정답이에요!' : '다시 풀어서 맞췄어요!',
              style:
                  TextStyle(color: pair.fg, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
                color: pair.fg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Text('+${formatWon(reward)} 저금통에 쏙!',
                style: TextStyle(
                    color: pair.fg, fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          Text(
            firstTry
                ? '경제 지식이 쑥쑥 자라고 있어요. 이 돈도 이자를 받아요!'
                : '틀려도 배우면 그게 진짜 실력이에요. 잘했어요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: pair.fg, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _AnswerRevealCard extends StatelessWidget {
  final String answer;
  const _AnswerRevealCard({required this.answer});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).special;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Text('📘', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Text('정답은 "$answer" 였어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: pair.fg, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('괜찮아요! 오늘 하나 배웠으니 다음엔 맞출 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: pair.fg, fontSize: 13.5, height: 1.4)),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final QuizState state;
  final VoidCallback onNext;
  const _NextButton({required this.state, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final last = state.answeredThisWeek >= kQuizPerWeek;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onNext,
        child: Text(last ? '결과 보기' : '다음 문제'),
      ),
    );
  }
}

/// 이번 주 할당량을 다 푼 뒤 보여주는 요약.
class _WeekDoneView extends StatelessWidget {
  final QuizState state;
  const _WeekDoneView({required this.state});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).income;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              Text('이번 주 퀴즈 끝!',
                  style: TextStyle(
                      color: pair.fg, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text('$kQuizPerWeek문제 중 ${state.correctThisWeek}문제 정답',
                  style: TextStyle(color: pair.fg, fontSize: 15)),
              const SizedBox(height: 4),
              Text('이번 주에 모은 돈 ${formatWon(state.earnedThisWeek)}',
                  style: TextStyle(
                      color: pair.fg, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('다음 주 월요일에 새 문제가 열려요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: pair.fg, fontSize: 13.5, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: Text('퀴즈로 모은 돈 ${formatWon(state.totalEarned)}'),
            subtitle: Text('남은 문제 ${state.remainingInBank}개',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ),
      ],
    );
  }
}

class _BankEmptyView extends StatelessWidget {
  const _BankEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📚', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('문제를 모두 풀었어요!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('대단해요. 부모님이 새 문제를 준비해 주실 거예요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

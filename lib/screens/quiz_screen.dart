import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../data/quiz_bank.dart';
import '../providers/database_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 해설을 실제로 읽도록 강제하는 최소 시간(초).
const int _readSeconds = 5;

enum _Phase { asking, explaining, retrying, correct, failed }

/// 도전! 경제왕 Quiz — 주 1회 3문제.
/// 첫 시도에 맞추면 설정된 보상(기본 10원), 틀리면 해설을 읽고 다시 풀어 맞추면 절반.
/// 재도전 때는 보기 순서를 섞어서 "정답 위치"만 외워 찍는 걸 막는다.
class QuizScreen extends ConsumerStatefulWidget {
  final Child child;
  const QuizScreen({super.key, required this.child});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  _Phase _phase = _Phase.asking;
  // 지금 화면에 띄운 문제. 답을 기록하면 스트림이 곧바로 다음 문제를 내주지만,
  // 아이가 "다음 문제"를 누를 때까지는 이 문제(축하 카드·해설)를 붙잡아 둔다.
  QuizQuestion? _shown;
  int _number = 1; // 이번 주 몇 번째 문제인지(기록 전에 정해 둔다)
  List<int> _order = const []; // 보기 표시 순서
  int? _picked; // 사용자가 고른 보기(원본 인덱스)
  int _reward = 0;
  int _countdown = 0;
  bool _saving = false; // 기록 중에는 다음 문제로 못 넘어가게(같은 문제가 다시 뜨는 것 방지)
  final Set<String> _answeredHere = {}; // 이 화면에서 답한 문제(스트림이 따라오기 전 재출제 방지)
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetFor(QuizQuestion q, QuizState state) {
    _shown = q;
    _number = state.answeredThisWeek + 1;
    _phase = _Phase.asking;
    _order = q.displayOrder;
    _picked = null;
    _reward = 0;
    _saving = false;
    _timer?.cancel();
    _countdown = 0;
  }

  Future<void> _record(QuizQuestion q,
      {required bool correct, required bool firstTry, required int reward, required int picked}) async {
    _answeredHere.add(q.id);
    setState(() => _saving = true);
    try {
      await ref.read(databaseProvider).recordQuizAnswer(
            childId: widget.child.id,
            questionId: q.id,
            correct: correct,
            firstTry: firstTry,
            reward: reward,
            pickedIndex: picked,
            editedBy: ref.read(settingsProvider).deviceOwner ?? '',
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    // 이미 답이 정해진 뒤에 들어온 연타는 무시한다.
    if (_phase != _Phase.asking && _phase != _Phase.retrying) return;
    final isCorrect = originalIndex == q.answerIndex;
    final firstTry = _phase == _Phase.asking;

    if (isCorrect) {
      final full = widget.child.quizReward;
      final reward = firstTry ? full : quizHalfReward(full);
      setState(() {
        _picked = originalIndex;
        _reward = reward;
        _phase = _Phase.correct;
      });
      await _record(q, correct: true, firstTry: firstTry, reward: reward, picked: originalIndex);
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
      await _record(q, correct: false, firstTry: false, reward: 0, picked: originalIndex);
    }
  }

  /// 재도전 때는 정답이 처음과 다른 자리에 오도록 섞는다("몇 번째였지"로 찍는 걸 막는다).
  void _goRetry(QuizQuestion q) {
    final before = _order.indexOf(q.answerIndex);
    final next = [..._order];
    final rnd = Random();
    do {
      next.shuffle(rnd);
    } while (next.length > 1 && next.indexOf(q.answerIndex) == before);
    setState(() {
      _order = next;
      _picked = null;
      _phase = _Phase.retrying;
    });
  }

  void _goNext() => setState(() => _shown = null);

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(quizStateProvider(widget.child.id));
    return Scaffold(
      appBar: AppBar(title: const Text('도전! 경제왕 Quiz')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (state) {
          // 방금 푼 문제는 "다음 문제"/"결과 보기"를 누를 때까지 그대로 보여준다.
          final shown = _shown;
          if (shown != null && (_phase == _Phase.correct || _phase == _Phase.failed)) {
            return _buildQuestion(context, state, shown);
          }
          if (state.weekDone) return _WeekDoneView(state: state);
          final q = state.current;
          if (q == null) return const _BankEmptyView();
          if (_answeredHere.contains(q.id)) {
            // 방금 기록한 문제가 아직 목록에 남아 있음 — 스트림이 따라올 때까지 잠깐 기다린다.
            return const Center(child: CircularProgressIndicator());
          }
          if (shown?.id != q.id) _resetFor(q, state);
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
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ),
              if (i < kQuizPerWeek - 1) const SizedBox(width: AppGap.snug),
            ],
          ],
        ),
        const SizedBox(height: AppGap.sm),
        Row(
          children: [
            TagChip(label: q.topic),
            const Spacer(),
            Text('$_number / $kQuizPerWeek 문제',
                style: TextStyle(fontSize: AppText.label, color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: AppGap.lg),
        Text(q.question,
            style: const TextStyle(fontSize: AppText.heading, fontWeight: FontWeight.w800, height: 1.4)),
        const SizedBox(height: AppGap.xl),

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
          const SizedBox(height: AppGap.md),
          _ExplanationCard(explanation: q.explanation),
          const SizedBox(height: AppGap.lg),
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
          const SizedBox(height: AppGap.md),
          _ExplanationCard(explanation: q.explanation),
          const SizedBox(height: AppGap.lg),
          _NextButton(last: _number >= kQuizPerWeek, onNext: _saving ? null : _goNext),
        ],

        if (_phase == _Phase.failed) ...[
          _AnswerRevealCard(answer: q.answerText),
          const SizedBox(height: AppGap.md),
          _ExplanationCard(explanation: q.explanation),
          const SizedBox(height: AppGap.lg),
          _NextButton(last: _number >= kQuizPerWeek, onNext: _saving ? null : _goNext),
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
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor, width: 1.4),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Text(text, style: const TextStyle(fontSize: AppText.title, fontWeight: FontWeight.w600)),
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
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Row(
        children: [
          const Text('🤔', style: TextStyle(fontSize: AppText.numXl)),
          const SizedBox(width: AppGap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('아쉬워요!',
                    style: TextStyle(
                        color: pair.fg, fontSize: AppText.titleLg, fontWeight: FontWeight.w800)),
                const SizedBox(height: AppGap.xxs),
                Text('아래 설명을 읽고 다시 풀어보면 절반을 받을 수 있어요.',
                    style: TextStyle(color: pair.fg, fontSize: AppText.body, height: 1.4)),
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
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: AppText.heading)),
              const SizedBox(width: AppGap.snug),
              Text('알아두기',
                  style:
                      TextStyle(color: pair.fg, fontSize: AppText.bodyLg, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: AppGap.sm),
          Text(explanation,
              style: TextStyle(color: pair.fg, fontSize: AppText.bodyLg, height: 1.55)),
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
      padding: const EdgeInsets.all(AppGap.xl),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        children: [
          Text(firstTry ? '🎉' : '👏', style: const TextStyle(fontSize: AppEmoji.md)),
          const SizedBox(height: AppGap.snug),
          Text(firstTry ? '정답이에요!' : '다시 풀어서 맞췄어요!',
              style:
                  TextStyle(color: pair.fg, fontSize: AppText.numSm, fontWeight: FontWeight.w900)),
          const SizedBox(height: AppGap.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
                color: pair.fg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.xl)),
            child: Text('+${formatWon(reward)} 저금통에 쏙!',
                style: TextStyle(
                    color: pair.fg, fontSize: AppText.title, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: AppGap.cozy),
          Text(
            firstTry
                ? '경제 지식이 쑥쑥 자라고 있어요. 이 돈도 이자를 받아요!'
                : '틀려도 배우면 그게 진짜 실력이에요. 잘했어요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: pair.fg, fontSize: AppText.body, height: 1.45),
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
      padding: const EdgeInsets.all(AppGap.lg),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        children: [
          const Text('📘', style: TextStyle(fontSize: AppEmoji.sm)),
          const SizedBox(height: AppGap.snug),
          Text('정답은 "$answer" 였어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: pair.fg, fontSize: AppText.titleLg, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppGap.snug),
          Text('괜찮아요! 오늘 하나 배웠으니 다음엔 맞출 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: pair.fg, fontSize: AppText.body, height: 1.4)),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool last;
  final VoidCallback? onNext;
  const _NextButton({required this.last, required this.onNext});

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(AppGap.xxl),
          decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
          child: Column(
            children: [
              const Text('🏆', style: TextStyle(fontSize: AppEmoji.lg)),
              const SizedBox(height: AppGap.sm),
              Text('이번 주 퀴즈 끝!',
                  style: TextStyle(
                      color: pair.fg, fontSize: AppText.numMd, fontWeight: FontWeight.w900)),
              const SizedBox(height: AppGap.cozy),
              Text('$kQuizPerWeek문제 중 ${state.correctThisWeek}문제 정답',
                  style: TextStyle(color: pair.fg, fontSize: AppText.title)),
              const SizedBox(height: AppGap.xs),
              Text('이번 주에 모은 돈 ${formatWon(state.earnedThisWeek)}',
                  style: TextStyle(
                      color: pair.fg, fontSize: AppText.heading, fontWeight: FontWeight.w900)),
              const SizedBox(height: AppGap.md),
              Text('다음 주 월요일에 새 문제가 열려요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: pair.fg, fontSize: AppText.body, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: AppGap.lg),
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
        padding: const EdgeInsets.all(AppGap.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📚', style: TextStyle(fontSize: AppEmoji.lg)),
            const SizedBox(height: AppGap.md),
            const Text('문제를 모두 풀었어요!',
                style: TextStyle(fontSize: AppText.heading, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppGap.sm),
            Text('대단해요. 부모님이 새 문제를 준비해 주실 거예요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

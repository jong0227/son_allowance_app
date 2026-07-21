import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../data/economy_topics.dart';
import '../providers/quiz_provider.dart';
import '../providers/rates_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';
import 'cofix_explainer_screen.dart';
import 'compound_simulator_screen.dart';
import 'interest_explainer_screen.dart';
import 'quiz_screen.dart';
import 'topic_explainer_screen.dart';

/// "경제왕" 탭 — 주 1회 퀴즈 + 경제상식 읽을거리 + 복리 시뮬레이터.
class EconomyScreen extends ConsumerWidget {
  final Child child;
  const EconomyScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizStateProvider(child.id));
    final isChild = ref.watch(settingsProvider).isChild;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          quizAsync.when(
            loading: () => const Card(
                child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))),
            error: (e, _) => Card(
                child: Padding(padding: const EdgeInsets.all(16), child: Text('오류: $e'))),
            data: (state) => Column(
              children: [
                _QuizCard(childId: child.id, state: state),
                // 부모에게만: 문제은행이 바닥나기 전에 알려준다.
                if (!isChild && state.bankRunningLow) ...[
                  const SizedBox(height: 8),
                  _LowBankNotice(remaining: state.remainingInBank),
                ],
              ],
            ),
          ),
          const SectionHeader('우리 동네 경제'),
          const _IndicatorsCard(),
          const SectionHeader('돈이 불어나는 걸 보자'),
          _NavCard(
            emoji: '📈',
            title: '얼마나 모일까?',
            subtitle: '지금처럼 모으면 1년 뒤 얼마가 될지 보기',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CompoundSimulatorScreen(child: child))),
          ),
          const SectionHeader('경제상식'),
          _NavCard(
            emoji: '💰',
            title: '이자가 뭐야?',
            subtitle: '왜 주는지, 어떻게 하면 더 받는지',
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InterestExplainerScreen())),
          ),
          for (final topic in kEconomyTopics)
            _NavCard(
              emoji: topic.emoji,
              title: topic.title,
              subtitle: topic.summary,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TopicExplainerScreen(topic: topic))),
            ),
          _NavCard(
            emoji: '🏛️',
            title: 'COFIX 금리란?',
            subtitle: '은행이 돈을 빌려올 때 내는 값 (대출의 기준)',
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CofixExplainerScreen())),
          ),
        ],
      ),
    );
  }
}

/// 이번 주 퀴즈 진입 카드.
class _QuizCard extends StatelessWidget {
  final String childId;
  final QuizState state;
  const _QuizCard({required this.childId, required this.state});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final pair = state.weekDone ? palette.savings : palette.income;
    final canPlay = !state.weekDone && !state.bankEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('도전! 경제왕 Quiz',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900, color: pair.fg)),
                    const SizedBox(height: 2),
                    Text(
                      state.weekDone
                          ? '이번 주 완료! 다음 주 월요일에 또 만나요'
                          : '이번 주 ${state.leftThisWeek}문제 남았어요 · 맞히면 ${formatWon(kQuizFullReward)}',
                      style: TextStyle(fontSize: 12.5, color: pair.fg, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(label: '이번 주', value: '${state.correctThisWeek}개 정답', pair: pair),
              const SizedBox(width: 8),
              _Stat(label: '모은 돈', value: formatWon(state.totalEarned), pair: pair),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canPlay
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => QuizScreen(childId: childId)))
                  : null,
              child: Text(state.bankEmpty
                  ? '문제를 모두 풀었어요'
                  : (state.weekDone ? '이번 주 완료' : '퀴즈 풀러 가기')),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: pair.fg.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: pair.fg)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w900, color: pair.fg)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 문제은행이 얼마 안 남았을 때 부모에게 보이는 안내.
class _LowBankNotice extends StatelessWidget {
  final int remaining;
  const _LowBankNotice({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).expense;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: pair.fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              remaining == 0
                  ? '퀴즈 문제를 모두 풀었어요. 새 문제를 추가해 주세요!'
                  : '퀴즈 문제가 $remaining개 남았어요. 곧 새 문제가 필요해요.',
              style: TextStyle(color: pair.fg, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 물가 상승률 + 원/달러 환율. 아이가 "요즘 물건값이 얼마나 올랐나"를 체감하도록.
class _IndicatorsCard extends ConsumerWidget {
  const _IndicatorsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(economyIndicatorsProvider);
    final theme = Theme.of(context);
    final palette = appPalette(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.public, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('물가와 환율',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: '새로고침',
                  onPressed: () => ref.invalidate(economyIndicatorsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            async.when(
              loading: () => const SizedBox(
                  height: 44,
                  child: Center(
                      child: SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))),
              error: (_, __) => _msg('불러오지 못했어요. 새로고침을 눌러보세요.', theme),
              data: (d) {
                if (d.isEmpty) return _msg('불러오지 못했어요. 잠시 후 새로고침해 주세요.', theme);
                return Row(
                  children: [
                    Expanded(
                      child: _Cell(
                        label: '물가 (1년 전보다)',
                        value: d.inflationYoY == null
                            ? '-'
                            : '${formatPercent(d.inflationYoY!)}% ↑',
                        hint: '작년보다 물건값이 이만큼 올랐어요',
                        pair: palette.expense,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Cell(
                        label: '1달러',
                        value: d.usdKrw == null ? '-' : '${d.usdKrw!.round()}원',
                        hint: '미국 주식 살 때 쓰는 값',
                        pair: palette.savings,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _msg(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(text,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
      );
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final PastelPair pair;
  const _Cell(
      {required this.label, required this.value, required this.hint, required this.pair});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, color: pair.fg)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: pair.fg)),
          ),
          const SizedBox(height: 3),
          Text(hint, style: TextStyle(fontSize: 10.5, height: 1.3, color: pair.fg)),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _NavCard(
      {required this.emoji,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

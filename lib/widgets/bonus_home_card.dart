import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/category_history_screen.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'ui_kit.dart';

/// 홈의 "이번 주 절약 도전 / 절약 보너스" 카드.
/// - 진행 중이거나 못 받았으면: 큰 카드.
/// - 이미 받았으면: 작은 카드로 접히고, 누르면 펼쳐진다.
class BonusHomeCard extends ConsumerStatefulWidget {
  final Child child;
  final bool isChild;
  const BonusHomeCard({super.key, required this.child, required this.isChild});

  @override
  ConsumerState<BonusHomeCard> createState() => _BonusHomeCardState();
}

class _BonusHomeCardState extends ConsumerState<BonusHomeCard> {
  bool _open = false;

  Child get child => widget.child;
  bool get isChild => widget.isChild;

  @override
  Widget build(BuildContext context) {
    if (!child.bonusEnabled) return const SizedBox.shrink();
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dayName = weekdayName(child.bonusDayOfWeek);
    final given = ref.watch(bonusGivenThisWeekProvider(child.id)).valueOrNull ?? false;
    final pendingBonusReq = ref
            .watch(requestsProvider(child.id))
            .valueOrNull
            ?.any((r) => r.type == 'bonus' && r.status == 'pending') ??
        false;

    final txs = ref.watch(transactionsProvider(child.id)).valueOrNull ?? const [];
    final weekStart =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weeklyBudget = child.weeklyAllowanceDefault;
    final weekSpent = txs
        .where((t) =>
            t.flow == 'expense' && !t.date.isBefore(weekStart) && t.date.isBefore(weekEnd))
        .fold<int>(0, (a, b) => a + b.amount);
    final weekRemaining = weeklyBudget - weekSpent;

    final progress = child.bonusThreshold == 0
        ? 1.0
        : (weekRemaining / child.bonusThreshold).clamp(0.0, 1.0);
    final dayReached = now.weekday >= child.bonusDayOfWeek;
    final met = weekRemaining >= child.bonusThreshold;
    final daysLeft = child.bonusDayOfWeek - now.weekday;

    String spendLine() =>
        '이번 주 용돈 ${formatWon(weeklyBudget)} 중 ${formatWon(weekSpent)} 썼어요 '
        '(${formatWon(weekRemaining < 0 ? 0 : weekRemaining)} 남음)';
    String dayLeftText() =>
        daysLeft == 1 ? '내일 $dayName요일까지' : '$dayName요일까지 D-$daysLeft';

    // 이미 받았고 접혀 있으면: 작은 한 줄 카드.
    if (given && !_open) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: MiniBar(
          pair: palette.income,
          text: '이번 주 절약 보너스 ${formatWon(child.bonusAmount)} 받음',
          onTap: () => setState(() => _open = true),
        ),
      );
    }

    Widget progressBar(Color color) => ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );

    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String title;
    late final String sub;
    Widget? trailing;

    if (given) {
      bg = palette.income.bg;
      fg = palette.income.fg;
      icon = Icons.check_circle;
      title = '이번 주 절약 보너스 완료';
      sub = '${formatWon(child.bonusAmount)}을 지급했어요. 다음 주에 또 도전!';
      trailing = InkWell(
        onTap: () => setState(() => _open = false),
        child: Icon(Icons.expand_less, color: fg.withValues(alpha: 0.8), size: 20),
      );
    } else if (dayReached && met) {
      bg = palette.special.bg;
      fg = palette.special.fg;
      icon = Icons.emoji_events;
      title = '절약 목표 달성! 🎉';
      sub = '${spendLine()}\n$dayName요일까지 ${formatWon(child.bonusThreshold)} 이상 남겼어요.';
      if (isChild) {
        trailing = pendingBonusReq
            ? const Chip(label: Text('요청함'))
            : FilledButton(
                onPressed: () => _requestBonus(context),
                child: const Text('보너스 요청'),
              );
      } else {
        trailing = FilledButton(
          onPressed: _giveBonus,
          child: Text('보너스 ${formatWon(child.bonusAmount)}'),
        );
      }
    } else if (!dayReached) {
      bg = palette.allowance.bg;
      fg = palette.allowance.fg;
      icon = Icons.savings_outlined;
      title = '이번 주 절약 도전';
      sub = '${spendLine()}\n${dayLeftText()} · ${formatWon(child.bonusThreshold)} 이상 남기면 '
          '+${formatWon(child.bonusAmount)}';
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
      icon = Icons.sentiment_neutral;
      title = '이번 주는 목표에 조금 못 미쳤어요';
      sub = '${spendLine()}\n목표 ${formatWon(child.bonusThreshold)}엔 못 미쳤어요. 다음 주에 다시 도전!';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(AppGap.lg),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: fg, size: 22),
                const SizedBox(width: AppGap.sm),
                Expanded(
                  child: Text(title,
                      style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: AppText.title)),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: AppGap.sm),
            Text(sub, style: TextStyle(color: fg, fontSize: AppText.body, height: 1.5)),
            if (!given) ...[
              const SizedBox(height: AppGap.md),
              progressBar(fg),
            ],
            const SizedBox(height: AppGap.cozy),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _openHistory(context),
                child: Text('달성 이력 보기',
                    style: TextStyle(
                        color: fg, fontSize: AppText.caption, decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CategoryHistoryScreen(
        childId: child.id,
        category: AppDatabase.kSavingsBonus,
        title: '절약 보너스 지급 이력',
        icon: Icons.emoji_events_outlined,
      ),
    ));
  }

  Future<void> _giveBonus() async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).giveSavingsBonus(child, owner);
  }

  Future<void> _requestBonus(BuildContext context) async {
    final ok = await ref.read(databaseProvider).requestBonus(child, '아들');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? '부모님께 보너스를 요청했어요.' : '이미 요청한 보너스가 있어요.')));
    }
  }
}


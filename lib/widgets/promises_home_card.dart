import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/rates_provider.dart';
import '../screens/promise_detail_screen.dart';
import '../services/interest_calc.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'ui_kit.dart';

/// 홈의 "부모님과 약속" 카드.
/// 아이도 부모도 같은 카드를 본다. 약속을 누르면 상세 + 댓글로 들어간다.
/// (ON/OFF는 부모만 바꿀 수 있고, 아이는 댓글로 어떻게 지키는지 남긴다)
class PromisesHomeCard extends ConsumerWidget {
  final Child child;
  const PromisesHomeCard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childId = child.id;
    final promises = ref.watch(promisesProvider(childId)).valueOrNull ?? const [];
    if (promises.isEmpty) return const SizedBox.shrink();

    final comments = ref.watch(allPromiseCommentsProvider(childId)).valueOrNull ?? const [];
    final commentCount = <String, int>{};
    for (final c in comments) {
      if (c.kind != 'comment') continue;
      commentCount[c.promiseId] = (commentCount[c.promiseId] ?? 0) + 1;
    }
    final bonus = promises
        .where((p) => p.enabled)
        .fold<double>(0, (sum, p) => sum + p.bonusPercent);
    final palette = appPalette(context);
    final theme = Theme.of(context);

    // 약속까지 다 반영한 "최종 적용 이자"(연). 이자 규칙이 꺼져 있으면 표시하지 않는다.
    double? finalAnnualPercent;
    if (child.interestEnabled) {
      final balance = ref.watch(summaryProvider(childId)).valueOrNull?['balance'] ?? 0;
      final bankRate = ref.watch(depositRateProvider).valueOrNull;
      final b = computeInterest(
        balance: balance,
        period: child.interestPeriod,
        useBankRate: child.interestUseBankRate,
        multiplier: child.interestMultiplier,
        fixedPercent: child.interestPercent,
        promiseBonusAnnualPercent: bonus,
        bankAnnualPercent: bankRate,
      );
      finalAnnualPercent = b.annualPercent;
    }

    return Card(
      // 간격은 이 카드를 놓는 쪽(이자 카드)이 정한다.
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.handshake_outlined,
                    size: 17, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppGap.snug),
                Text('부모님과 약속',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (finalAnnualPercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                        color: palette.income.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
                    child: Text('최종 이자 연 ${formatPercent(finalAnnualPercent)}%',
                        style: TextStyle(
                            color: palette.income.fg,
                            fontSize: AppText.caption,
                            fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            if (finalAnnualPercent != null && bonus > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Text('약속 보너스 연 +${formatPercent(bonus)}%p 포함',
                    style: TextStyle(
                        fontSize: AppText.caption, color: theme.colorScheme.onSurfaceVariant)),
              ),
            const SizedBox(height: AppGap.xs),
            for (final p in promises)
              _PromiseRow(promise: p, comments: commentCount[p.id] ?? 0),
          ],
        ),
      ),
    );
  }
}

class _PromiseRow extends StatelessWidget {
  final Promise promise;
  final int comments;
  const _PromiseRow({required this.promise, required this.comments});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final on = promise.enabled;
    final pair = on ? palette.income : palette.expense;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PromiseDetailScreen(promise: promise)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        child: Row(
          children: [
            Icon(on ? Icons.check_circle : Icons.pause_circle_outlined,
                size: 18, color: pair.fg),
            const SizedBox(width: AppGap.sm),
            Expanded(
              child: Text(promise.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppText.bodyLg,
                    fontWeight: FontWeight.w600,
                    color: on ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  )),
            ),
            if (comments > 0) ...[
              Icon(Icons.chat_bubble_outline,
                  size: 13, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppGap.xs),
              Text('$comments',
                  style: TextStyle(
                      fontSize: AppText.caption, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: AppGap.sm),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration:
                  BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
              child: Text(on ? 'ON +${formatPercent(promise.bonusPercent)}%' : 'OFF',
                  style: TextStyle(
                      color: pair.fg, fontSize: AppText.caption, fontWeight: FontWeight.w800)),
            ),
            Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

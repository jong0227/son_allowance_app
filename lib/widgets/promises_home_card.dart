import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../screens/promise_detail_screen.dart';
import '../utils/formatters.dart';
import 'ui_kit.dart';

/// 홈의 "부모님과 약속" 카드.
/// 아이도 부모도 같은 카드를 본다. 약속을 누르면 상세 + 댓글로 들어간다.
/// (ON/OFF는 부모만 바꿀 수 있고, 아이는 댓글로 어떻게 지키는지 남긴다)
class PromisesHomeCard extends ConsumerWidget {
  final String childId;
  const PromisesHomeCard({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.handshake_outlined,
                    size: 17, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('부모님과 약속',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (bonus > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                        color: palette.income.bg, borderRadius: BorderRadius.circular(20)),
                    child: Text('이자 +${formatPercent(bonus)}%',
                        style: TextStyle(
                            color: palette.income.fg,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
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
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PromiseDetailScreen(promise: promise)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        child: Row(
          children: [
            Icon(on ? Icons.check_circle : Icons.pause_circle_outlined,
                size: 18, color: pair.fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(promise.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: on ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                  )),
            ),
            if (comments > 0) ...[
              Icon(Icons.chat_bubble_outline,
                  size: 13, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
              Text('$comments',
                  style: TextStyle(
                      fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration:
                  BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(20)),
              child: Text(on ? 'ON +${formatPercent(promise.bonusPercent)}%' : 'OFF',
                  style: TextStyle(
                      color: pair.fg, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

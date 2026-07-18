import 'package:flutter/material.dart';
import '../data/app_database.dart';
import '../providers/tier_provider.dart';
import '../utils/formatters.dart';

/// 앱 상단 제목 옆에 붙는 컴팩트 티어 배지 (아이콘 + 칭호).
class TierBadge extends StatelessWidget {
  final Tier tier;
  const TierBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tier.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(tier.title,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: scheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}

/// 홈 상단 큰 티어 카드: 현재 칭호 + 다음 티어까지 진행바 + 티어표(?) 버튼.
class TierProgressCard extends StatelessWidget {
  final List<Tier> tiers;
  final int savings; // 총 저축액
  const TierProgressCard({super.key, required this.tiers, required this.savings});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pos = tierFor(tiers, savings);
    final cur = pos.current;
    final next = pos.next;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(cur?.icon ?? '🟫', style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(cur?.title ?? '흙',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: scheme.onPrimaryContainer)),
                          ),
                          if (cur != null && tierEnglishName(cur.id) != null) ...[
                            const SizedBox(width: 6),
                            Text(tierEnglishName(cur.id)!,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onPrimaryContainer.withValues(alpha: 0.75))),
                          ],
                        ],
                      ),
                      Text('총 저축 ${formatWon(savings)}',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onPrimaryContainer.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '티어표 보기',
                  icon: Icon(Icons.help_outline, color: scheme.onPrimaryContainer),
                  onPressed: () => showTierTable(context, tiers, savings),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pos.progress,
                minHeight: 9,
                backgroundColor: scheme.onPrimaryContainer.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              next == null
                  ? '최고 티어 달성! 대단해요 🎉'
                  : '다음 "${next.icon} ${next.title}"까지 ${formatWon(pos.remaining ?? 0)}',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

/// 전체 티어표 모달. 현재 티어 하이라이트 + 각 티어 보상 표시.
void showTierTable(BuildContext context, List<Tier> tiers, int savings) {
  final pos = tierFor(tiers, savings);
  final currentId = pos.current?.id;
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            const Text('저축 티어표',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text('총 저축 ${formatWon(savings)} · 현재 "${pos.current?.title ?? '흙'}"',
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            for (final t in tiers)
              Card(
                color: t.id == currentId ? scheme.primaryContainer : null,
                child: ListTile(
                  leading: Text(t.icon, style: const TextStyle(fontSize: 26)),
                  title: Row(
                    children: [
                      Text(t.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: t.id == currentId ? scheme.onPrimaryContainer : null)),
                      if (tierEnglishName(t.id) != null) ...[
                        const SizedBox(width: 6),
                        Text(tierEnglishName(t.id)!,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (t.id == currentId
                                        ? scheme.onPrimaryContainer
                                        : scheme.onSurfaceVariant)
                                    .withValues(alpha: 0.7))),
                      ],
                      if (t.id == currentId) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle, size: 16, color: scheme.primary),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${formatWon(t.threshold)}${t.reward != null && t.reward!.isNotEmpty ? '\n🎁 ${t.reward}' : ''}',
                    style: TextStyle(
                        color: t.id == currentId
                            ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
                            : scheme.onSurfaceVariant),
                  ),
                  isThreeLine: t.reward != null && t.reward!.isNotEmpty,
                ),
              ),
          ],
        ),
      );
    },
  );
}

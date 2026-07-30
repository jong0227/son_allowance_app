import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 특정 카테고리 수입 내역만 모아 보여주는 이력 화면.
/// (저축 이자 = '이자', 절약 보너스 = '절약보너스' 처럼 재사용)
class CategoryHistoryScreen extends ConsumerWidget {
  final String childId;
  final String category;
  final String title;
  final IconData icon;
  const CategoryHistoryScreen({
    super.key,
    required this.childId,
    required this.category,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txsAsync = ref.watch(transactionsProvider(childId));
    final palette = appPalette(context);
    final pair = palette.income;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: txsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (txs) {
          final list = txs
              .where((t) => t.flow == 'income' && t.category == category)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final total = list.fold<int>(0, (s, t) => s + t.amount);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(AppGap.lg),
                decoration: BoxDecoration(
                    color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('지금까지 받은 $title',
                        style: TextStyle(
                            fontSize: AppText.body, color: pair.fg.withValues(alpha: 0.85))),
                    const SizedBox(height: AppGap.xs),
                    Text(formatWon(total),
                        style: TextStyle(
                            fontSize: AppText.numLg,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: pair.fg)),
                    const SizedBox(height: AppGap.snug),
                    Text('받은 횟수 ${list.length}회',
                        style: TextStyle(
                            fontSize: AppText.body, color: pair.fg.withValues(alpha: 0.9))),
                  ],
                ),
              ),
              const SizedBox(height: AppGap.sm),
              if (list.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppGap.xl),
                    child: Text('아직 받은 $title이 없어요.',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ),
                )
              else
                for (final t in list)
                  Card(
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      leading: CircleAvatar(
                          backgroundColor: pair.bg,
                          child: Icon(icon, color: pair.fg)),
                      title: Text('+${formatWon(t.amount)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: pair.fg,
                              letterSpacing: -0.3)),
                      subtitle: Text(
                        '${formatDate(t.date)}${(t.memo ?? '').isNotEmpty ? ' · ${t.memo}' : ''}',
                        style: TextStyle(
                            fontSize: AppText.label,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

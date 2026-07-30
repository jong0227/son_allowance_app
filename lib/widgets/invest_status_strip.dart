import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';
import '../providers/market_provider.dart';
import '../screens/invest_screen.dart' show positionValue, investUp, investDown;
import '../screens/main_shell.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// 홈의 "오늘의 투자현황" 스트립.
/// 모의 투자 원금 · 평가손익 · 수익률을 한 줄로 보여주고, 누르면 주식 탭으로 간다.
/// 아직 투자한 게 없으면 시작을 권하는 안내만 짧게 띄운다.
class InvestStatusStrip extends ConsumerWidget {
  final String childId;
  /// 바로 위 카드와 붙여 보이도록 위쪽 마진을 없앤다(홈의 등급 카드 아래).
  const InvestStatusStrip({super.key, required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final border = theme.dividerColor;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    final positions = ref.watch(investmentsProvider(childId)).valueOrNull ?? const [];
    final indicesAsync = ref.watch(investIndicesProvider);
    final indices = indicesAsync.valueOrNull ?? const [];
    final bySymbol = {for (final i in indices) i.symbol: i};

    final open = positions.where((p) => p.soldAt == null).toList();
    final principal = open.fold<int>(0, (s, p) => s + p.amount);
    final value =
        open.fold<int>(0, (s, p) => s + positionValue(p, bySymbol[p.symbol]?.value));
    final gain = value - principal;
    final rate = principal == 0 ? 0.0 : gain / principal * 100;
    final gainColor =
        gain > 0 ? investUp : (gain < 0 ? investDown : theme.colorScheme.onSurface);

    return Card(
      // 간격은 이 카드를 놓는 화면이 정한다(홈 카드 간격 통일).
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // 주식 탭(모의 투자)으로 이동
        onTap: () => ref.read(mainTabIndexProvider.notifier).state = 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.public, size: 16, color: textSecondary),
                  const SizedBox(width: AppGap.snug),
                  Text('오늘의 투자현황',
                      style:
                          theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (open.isNotEmpty)
                    Text('${open.length}개 보유',
                        style: TextStyle(fontSize: AppText.caption, color: textSecondary)),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    color: textSecondary,
                    tooltip: '새로고침',
                    onPressed: () => ref.invalidate(investIndicesProvider),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: AppGap.xs),
              if (open.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('아직 투자한 게 없어요. 주식 탭에서 저축 포인트로 시작해보세요.',
                            style: TextStyle(fontSize: AppText.label, color: textSecondary)),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: textSecondary),
                    ],
                  ),
                )
              else if (indicesAsync.isLoading && indices.isEmpty)
                const SizedBox(
                  height: 44,
                  child: Center(
                      child: SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Cell(label: '원금', value: formatWon(principal)),
                      ),
                      VerticalDivider(width: 1, thickness: 1, color: border),
                      Expanded(
                        child: _Cell(
                          label: '평가손익',
                          value: '${gain >= 0 ? '+' : ''}${formatWon(gain)}',
                          color: gainColor,
                        ),
                      ),
                      VerticalDivider(width: 1, thickness: 1, color: border),
                      Expanded(
                        child: _Cell(
                          label: '수익률',
                          value: '${gain >= 0 ? '+' : ''}${rate.toStringAsFixed(1)}%',
                          color: gainColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Cell({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 지수·금리 스트립과 같은 방식으로 줄 높이를 고정해 칸끼리 선을 맞춘다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 16,
          child: Center(
            child: Text(label,
                maxLines: 1,
                style: TextStyle(
                    fontSize: AppText.caption, height: 1.0, color: theme.colorScheme.onSurfaceVariant)),
          ),
        ),
        const SizedBox(height: AppGap.xs),
        SizedBox(
          height: 20,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: AppText.titleLg,
                    height: 1.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: color ?? theme.colorScheme.onSurface,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}

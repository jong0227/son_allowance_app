import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rates_provider.dart';
import '../screens/rates_explainer_screen.dart';
import '../services/rates_service.dart';
import '../utils/formatters.dart';

/// 홈 화면의 "오늘의 금리" 스트립 (기준금리 / 정기예금 1년 / COFIX).
/// 실제 은행 금리를 보여줘 저축·이자 개념을 실감나게 하고, COFIX 설명으로 연결한다.
class RatesStrip extends ConsumerWidget {
  const RatesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ratesProvider);
    final theme = Theme.of(context);
    final border = theme.dividerColor;
    final textSecondary = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_outlined, size: 16, color: textSecondary),
                const SizedBox(width: 6),
                Text('오늘의 금리',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RatesExplainerScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text('금리란?',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        )),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  color: textSecondary,
                  tooltip: '새로고침',
                  onPressed: () => ref.invalidate(ratesProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 4),
            async.when(
              loading: () => const SizedBox(
                height: 40,
                child: Center(
                    child: SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => _message('금리를 불러오지 못했어요. 새로고침을 눌러보세요.', textSecondary),
              data: (rates) {
                if (rates.isEmpty) {
                  return _message('금리를 불러오지 못했어요. 잠시 후 새로고침해 주세요.', textSecondary);
                }
                return IntrinsicHeight(
                  child: Row(
                    children: [
                      for (var i = 0; i < rates.length; i++) ...[
                        if (i > 0) VerticalDivider(width: 1, thickness: 1, color: border),
                        Expanded(child: _RateCell(rate: rates[i])),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(String text, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Text(text, style: TextStyle(fontSize: 12, color: color)),
      );
}

class _RateCell extends StatelessWidget {
  final RateInfo rate;
  const _RateCell({required this.rate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = rate.kind == RateKind.cofix;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(rate.label,
            style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('${formatPercent(rate.rate)}%',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              )),
        ),
      ],
    );
  }
}

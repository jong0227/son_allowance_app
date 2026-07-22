import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/market_provider.dart';
import '../services/stock_search_service.dart';

/// 오르면 빨강/내리면 파랑 (한국식). 라이트·다크 모두 읽히는 중간 톤.
const _upColor = Color(0xFFE0574A);
const _downColor = Color(0xFF3B7BD8);

final _indexFormat = NumberFormat('#,##0.##');

/// 홈 상단 + 주식이체 탭에 쓰는 "오늘의 지수" 스트립(코스피/코스닥/나스닥).
class MarketIndexStrip extends ConsumerWidget {
  const MarketIndexStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketIndicesProvider);
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
                Icon(Icons.trending_up, size: 17, color: textSecondary),
                const SizedBox(width: 6),
                Text('오늘의 지수',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(DateFormat('M월 d일').format(DateTime.now()),
                    style: TextStyle(fontSize: 11.5, color: textSecondary)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  color: textSecondary,
                  tooltip: '새로고침',
                  onPressed: () => ref.invalidate(marketIndicesProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 4),
            async.when(
              loading: () => const SizedBox(
                height: 44,
                child: Center(
                    child: SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => _message('지수를 불러오지 못했어요. 새로고침을 눌러보세요.', textSecondary),
              data: (indices) {
                if (indices.isEmpty) {
                  return _message('지수를 불러오지 못했어요. 잠시 후 새로고침해 주세요.', textSecondary);
                }
                // 칸마다 숫자 길이가 달라도(2,845 vs 18,502) 줄이 어긋나지 않도록
                // 각 줄 높이를 고정한다.
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var i = 0; i < indices.length; i++) ...[
                        if (i > 0)
                          VerticalDivider(width: 1, thickness: 1, color: border),
                        Expanded(child: _IndexCell(index: indices[i])),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Text(text, style: TextStyle(fontSize: 12, color: color)),
      );
}

class _IndexCell extends StatelessWidget {
  final MarketIndex index;
  const _IndexCell({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = index.isUp
        ? _upColor
        : index.isDown
            ? _downColor
            : theme.colorScheme.onSurfaceVariant;
    final arrow = index.isUp
        ? '▲'
        : index.isDown
            ? '▼'
            : '–';
    final sign = index.change > 0 ? '+' : '';
    // 각 줄을 고정 높이로 두면 세 칸의 라벨/숫자/등락률이 정확히 같은 선에 놓인다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 15,
          child: Center(
            child: Text(index.label,
                style:
                    TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
          ),
        ),
        SizedBox(
          height: 21,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_indexFormat.format(index.value),
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
          ),
        ),
        SizedBox(
          height: 15,
          child: Center(
            child: Text('$arrow $sign${index.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

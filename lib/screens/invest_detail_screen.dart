import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/market_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';
import 'invest_screen.dart';

/// 차트에서 고를 수 있는 기간.
const _ranges = [
  ('1mo', '1개월'),
  ('3mo', '3개월'),
  ('1y', '1년'),
  ('5y', '5년'),
];

/// 지수 하나의 차트 + 사고팔기 화면.
class InvestDetailScreen extends ConsumerStatefulWidget {
  final Child child;
  final String indexKey;
  final String label;
  final String symbol;
  final String note;
  const InvestDetailScreen({
    super.key,
    required this.child,
    required this.indexKey,
    required this.label,
    required this.symbol,
    required this.note,
  });

  @override
  ConsumerState<InvestDetailScreen> createState() => _InvestDetailScreenState();
}

class _InvestDetailScreenState extends ConsumerState<InvestDetailScreen> {
  String _range = '3mo';

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final summary = ref.watch(summaryProvider(widget.child.id)).valueOrNull;
    final indices = ref.watch(investIndicesProvider).valueOrNull ?? const [];
    final positions =
        ref.watch(investmentsProvider(widget.child.id)).valueOrNull ?? const [];
    final seriesAsync =
        ref.watch(indexSeriesProvider((symbol: widget.symbol, range: _range)));

    final idx = indices.where((i) => i.symbol == widget.symbol).firstOrNull;
    final nowValue = idx?.value;

    final balance = summary?['balance'] ?? 0;
    final invested = summary?['invested'] ?? 0;
    final cap =
        ((balance + invested) * widget.child.investLimitPercent / 100).floor();
    final canInvest = (cap - invested).clamp(0, balance);

    final mine = positions
        .where((p) => p.soldAt == null && p.indexKey == widget.indexKey)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // 현재 지수
          Container(
            padding: const EdgeInsets.all(AppGap.lg),
            decoration: BoxDecoration(
                color: palette.savings.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.note,
                    style: TextStyle(
                        fontSize: AppText.label,
                        color: palette.savings.fg.withValues(alpha: 0.85))),
                const SizedBox(height: AppGap.snug),
                if (idx == null)
                  Text('지수를 불러오는 중...',
                      style: TextStyle(fontSize: AppText.heading, color: palette.savings.fg))
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(indexFormat.format(idx.value),
                          style: TextStyle(
                              fontSize: AppText.numXl,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: palette.savings.fg)),
                      const SizedBox(width: AppGap.cozy),
                      Text(
                          '어제보다 ${idx.isUp ? '▲' : (idx.isDown ? '▼' : '–')} '
                          '${idx.change > 0 ? '+' : ''}${idx.changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                              fontSize: AppText.body,
                              fontWeight: FontWeight.w800,
                              color: idx.isUp
                                  ? investUp
                                  : (idx.isDown ? investDown : palette.savings.fg))),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppGap.md),
          // 기간 선택
          SegmentedButton<String>(
            segments: [
              for (final (v, l) in _ranges) ButtonSegment(value: v, label: Text(l)),
            ],
            selected: {_range},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _range = s.first),
          ),
          const SizedBox(height: AppGap.cozy),
          // 차트
          SizedBox(
            height: 200,
            child: seriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text('차트를 불러오지 못했어요.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ),
              data: (series) {
                if (series.length < 2) {
                  return Center(
                    child: Text('차트 데이터가 없어요.',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  );
                }
                final rising = series.last >= series.first;
                final color = rising ? investUp : investDown;
                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < series.length; i++)
                            FlSpot(i.toDouble(), series[i]),
                        ],
                        isCurved: false,
                        color: color,
                        barWidth: 2.2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: color.withValues(alpha: 0.13)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          seriesAsync.maybeWhen(
            data: (s) => s.length < 2
                ? const SizedBox.shrink()
                : Center(
                    child: Text(
                      '${_rangeLabel(_range)} 동안 '
                      '${((s.last / s.first - 1) * 100).toStringAsFixed(1)}% '
                      '${s.last >= s.first ? '올랐어요' : '내렸어요'}',
                      style: TextStyle(
                          fontSize: AppText.label, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppGap.lg),
          // 사기
          FilledButton.icon(
            onPressed: (nowValue == null || canInvest <= 0)
                ? null
                : () => _showBuySheet(context, nowValue, canInvest),
            icon: const Icon(Icons.add),
            label: Text(canInvest <= 0
                ? '더 넣을 수 있는 돈이 없어요'
                : '투자하기 (최대 ${formatWon(canInvest)})'),
          ),
          if (mine.isNotEmpty) ...[
            const SectionHeader('내가 가진 것'),
            for (final p in mine)
              _MyPositionCard(
                position: p,
                nowValue: nowValue,
                onSell: nowValue == null ? null : () => _confirmSell(p, nowValue),
              ),
          ],
        ],
      ),
    );
  }

  String _rangeLabel(String r) =>
      _ranges.firstWhere((e) => e.$1 == r, orElse: () => (r, r)).$2;

  Future<void> _showBuySheet(
      BuildContext context, double indexValue, int maxAmount) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            final amount = int.tryParse(controller.text) ?? 0;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.label}에 투자하기',
                      style: const TextStyle(
                          fontSize: AppText.heading, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  const SizedBox(height: AppGap.xs),
                  Text('지금 지수 ${indexFormat.format(indexValue)} · '
                      '최대 ${formatWon(maxAmount)}',
                      style: TextStyle(
                          fontSize: AppText.label,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppGap.md),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: AppText.numLg, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '0',
                      suffixText: '원',
                    ),
                    onChanged: (_) => setSheet(() {}),
                  ),
                  const SizedBox(height: AppGap.cozy),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in const [0.25, 0.5, 1.0])
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(f == 1.0 ? '전부' : '${(f * 100).round()}%'),
                          onPressed: () {
                            controller.text = '${(maxAmount * f).floor()}';
                            setSheet(() {});
                          },
                        ),
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.backspace_outlined, size: 15),
                        label: const Text('지우기'),
                        onPressed: () {
                          controller.clear();
                          setSheet(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppGap.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (amount <= 0 || amount > maxAmount)
                          ? null
                          : () async {
                              final err = await ref
                                  .read(databaseProvider)
                                  .buyInvestment(
                                    child: widget.child,
                                    indexKey: widget.indexKey,
                                    label: widget.label,
                                    symbol: widget.symbol,
                                    amount: amount,
                                    indexValue: indexValue,
                                  );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(err ??
                                      '${widget.label}에 ${formatWon(amount)} 투자했어요!')));
                            },
                      child: Text(amount <= 0
                          ? '금액을 입력해주세요'
                          : '${formatWon(amount)} 투자하기'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmSell(Investment p, double indexValue) async {
    final value = positionValue(p, indexValue);
    final diff = value - p.amount;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('팔까요?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${p.label} · 투자한 돈 ${formatWon(p.amount)}'),
            const SizedBox(height: AppGap.snug),
            Text('지금 팔면 ${formatWon(value)}을 받아요.',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppGap.xs),
            Text(
                diff >= 0
                    ? '${formatWon(diff)} 벌었어요 🎉'
                    : '${formatWon(diff.abs())} 잃었어요 😢',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: diff >= 0 ? investUp : investDown)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('아니요')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('팔기')),
        ],
      ),
    );
    if (ok != true) return;
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    final returned = await ref
        .read(databaseProvider)
        .sellInvestment(position: p, indexValue: indexValue, editedBy: owner);
    if (!mounted || returned == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${formatWon(returned)}을 저축 포인트로 돌려받았어요.')));
  }
}

class _MyPositionCard extends StatelessWidget {
  final Investment position;
  final double? nowValue;
  final VoidCallback? onSell;
  const _MyPositionCard(
      {required this.position, required this.nowValue, required this.onSell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = positionValue(position, nowValue);
    final diff = value - position.amount;
    final pct = position.amount == 0 ? 0.0 : diff / position.amount * 100;
    final color = diff > 0
        ? investUp
        : (diff < 0 ? investDown : theme.colorScheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${formatWon(position.amount)} → ${formatWon(value)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: AppText.bodyLg)),
                  const SizedBox(height: AppGap.xxs),
                  Text(
                      '${formatDateShort(position.buyAt)} 투자 · '
                      '지수 ${indexFormat.format(position.buyValue)}',
                      style: TextStyle(
                          fontSize: AppText.caption, color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: AppGap.xxs),
                  Text(
                      '${diff >= 0 ? '+' : ''}${formatWon(diff)} '
                      '(${diff >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%)',
                      style: TextStyle(
                          fontSize: AppText.label, fontWeight: FontWeight.w800, color: color)),
                ],
              ),
            ),
            const SizedBox(width: AppGap.sm),
            FilledButton(onPressed: onSell, child: const Text('팔기')),
          ],
        ),
      ),
    );
  }
}

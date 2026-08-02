import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/market_provider.dart';
import '../providers/settings_provider.dart';
import '../services/invest_calc.dart';
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
    final holdings = ref.watch(holdingsProvider(widget.child.id));
    final seriesAsync =
        ref.watch(indexSeriesProvider((symbol: widget.symbol, range: _range)));

    final idx = indices.where((i) => i.symbol == widget.symbol).firstOrNull;
    final nowValue = idx?.value;
    // 지금 1주 가격. 지수를 못 받아오면 0(사고팔기 비활성).
    final nowPrice =
        nowValue == null ? 0 : sharePriceOf(widget.indexKey, nowValue);

    final balance = summary?['balance'] ?? 0;
    final invested = summary?['invested'] ?? 0;
    final cap =
        ((balance + invested) * widget.child.investLimitPercent / 100).floor();
    final canInvest = (cap - invested).clamp(0, balance);

    // 이 지수의 보유. 다 팔았으면 주수 0이라 카드가 안 보인다.
    final mine = holdings
        .where((h) => h.indexKey == widget.indexKey && !h.isEmpty)
        .firstOrNull;

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
          // 어느 쪽 눈금이 무엇인지. 이게 없으면 숫자 두 줄이 그냥 혼란스럽다.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('◀ ${widget.label} 지수',
                  style: TextStyle(
                      fontSize: AppText.micro,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant)),
              Text('${etfName(widget.label)} 1주 ▶',
                  style: TextStyle(
                      fontSize: AppText.micro,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppGap.xxs),
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
                // 같은 선을 두 눈금으로 읽는다. 왼쪽은 지수(6,595), 오른쪽은 그 지수일
                // 때 내 1주 값(660원). 아이가 "이 두 숫자가 같은 지점"임을 눈으로 잇게
                // 하려는 것이라, 축을 나눠 그리지 않고 한 선에 눈금만 둘 붙인다.
                final lo = series.reduce((a, b) => a < b ? a : b);
                final hi = series.reduce((a, b) => a > b ? a : b);
                final span = (hi - lo).abs();
                // 위아래 여백. 선이 눈금 글씨에 닿지 않게 한다.
                final pad = span < 1e-9 ? (hi.abs() * 0.05 + 1) : span * 0.15;
                final minY = lo - pad;
                final maxY = hi + pad;
                // 4등분해서 가운데 3개만 그린다. 맨 위·맨 아래 눈금은 위쪽 범례와
                // 아래쪽 "N% 올랐어요" 캡션에 부딪혀 글씨가 겹치던 주범이었다.
                final step = (maxY - minY) / 4;
                bool isEdge(double v) =>
                    (v - minY).abs() < step * 0.25 || (maxY - v).abs() < step * 0.25;
                final muted = theme.colorScheme.onSurfaceVariant;
                Widget axisLabel(String text) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(text,
                          // 폭이 모자라 두 줄로 쪼개지던 문제(8,215.6 / 4) 방지.
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize: AppText.micro, color: muted)),
                    );
                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    // 눈금 계산과 같은 범위를 써야 라벨이 실제 격자선 위에 놓인다.
                    minY: minY,
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      // 왼쪽: 지수 그대로
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 54,
                          interval: step,
                          // 소수점(8,215.64)은 아이에게 읽는 부담만 준다. 정수로 반올림.
                          getTitlesWidget: (v, meta) => isEdge(v)
                              ? const SizedBox.shrink()
                              : axisLabel(indexFormat.format(v.round())),
                        ),
                      ),
                      // 오른쪽: 같은 지점의 1주 가격(원)
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 54,
                          interval: step,
                          getTitlesWidget: (v, meta) => isEdge(v)
                              ? const SizedBox.shrink()
                              : axisLabel(
                                  formatWon(sharePriceOf(widget.indexKey, v))),
                        ),
                      ),
                    ),
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
          // 1주 가격 안내 — 몇 주를 살지 정하려면 이 값이 먼저 보여야 한다.
          if (nowPrice > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppGap.sm),
              child: Text('1주에 ${formatWon(nowPrice)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: AppText.body,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          // 왜 이 가격인지(접이식). 사기 버튼 바로 위에 둬서, 사기 직전에
          // 궁금해진 아이가 그 자리에서 펼쳐볼 수 있게 했다.
          if (nowPrice > 0 && nowValue != null)
            _WhyThisPriceCard(
              indexKey: widget.indexKey,
              label: widget.label,
              indexValue: nowValue,
              sharePrice: nowPrice,
            ),
          // 사기
          FilledButton.icon(
            onPressed: (nowValue == null || nowPrice <= 0 || canInvest < nowPrice)
                ? null
                : () => _showBuySheet(context, nowValue, nowPrice, canInvest),
            icon: const Icon(Icons.add),
            label: Text(canInvest < nowPrice
                ? '살 수 있는 돈이 모자라요'
                : '사기 (최대 ${maxBuyableShares(canInvest, nowPrice)}주)'),
          ),
          if (mine != null) ...[
            SectionHeader('내가 가진 ${etfName(widget.label)}'),
            _MyHoldingCard(
              holding: mine,
              nowPrice: nowPrice,
              onSell: nowValue == null || nowPrice <= 0
                  ? null
                  : () => _showSellSheet(context, mine, nowValue, nowPrice),
            ),
          ],
        ],
      ),
    );
  }

  String _rangeLabel(String r) =>
      _ranges.firstWhere((e) => e.$1 == r, orElse: () => (r, r)).$2;

  /// 몇 주 살지 정하는 시트. 수수료를 포함한 실제 지출을 항목별로 보여준다.
  Future<void> _showBuySheet(
    BuildContext context,
    double indexValue,
    int pricePerShare,
    int budget,
  ) async {
    final controller = TextEditingController();
    final maxShares = maxBuyableShares(budget, pricePerShare);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            final shares = int.tryParse(controller.text.trim()) ?? 0;
            final amount = shares * pricePerShare;
            final fee = buyFeeOf(amount);
            final total = amount + fee;
            final tooMany = shares > maxShares;
            final muted = Theme.of(ctx).colorScheme.onSurfaceVariant;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${etfName(widget.label)} 사기',
                      style: const TextStyle(
                          fontSize: AppText.heading,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4)),
                  const SizedBox(height: AppGap.xs),
                  Text(
                      '1주 ${formatWon(pricePerShare)} · '
                      '최대 $maxShares주까지 살 수 있어요',
                      style: TextStyle(fontSize: AppText.label, color: muted)),
                  const SizedBox(height: AppGap.md),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    // 정수 주만 다루므로 숫자 외 입력을 아예 막는다.
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: AppText.numLg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '0',
                      suffixText: '주',
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
                          label: Text(f == 1.0 ? '최대' : '${(f * 100).round()}%'),
                          onPressed: () {
                            final n = (maxShares * f).floor();
                            controller.text = '${n < 1 ? 1 : n}';
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
                  const SizedBox(height: AppGap.md),
                  if (shares > 0)
                    _Receipt(
                      rows: [
                        ('$shares주 × ${formatWon(pricePerShare)}', formatWon(amount), null),
                        ('수수료', '+${formatWon(fee)}', investDown),
                      ],
                      totalLabel: '낼 돈',
                      totalValue: formatWon(total),
                      note: tooMany
                          ? '지금 넣을 수 있는 돈(${formatWon(budget)})을 넘었어요.'
                          : null,
                      noteIsWarning: tooMany,
                    ),
                  const SizedBox(height: AppGap.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (shares <= 0 || tooMany)
                          ? null
                          : () async {
                              final err = await ref
                                  .read(databaseProvider)
                                  .buySharesInvest(
                                    child: widget.child,
                                    indexKey: widget.indexKey,
                                    label: widget.label,
                                    symbol: widget.symbol,
                                    shares: shares,
                                    indexValue: indexValue,
                                  );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(err ??
                                      '${etfName(widget.label)} $shares주를 샀어요! '
                                          '(수수료 ${formatWon(fee)} 포함 ${formatWon(total)})'),
                                ),
                              );
                            },
                      child: Text(shares <= 0 ? '몇 주 살지 입력해주세요' : '$shares주 사기'),
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

  /// 몇 주 팔지 정하는 시트. 수수료를 빼고 실제로 받을 돈을 보여준다.
  Future<void> _showSellSheet(
    BuildContext context,
    Holding holding,
    double indexValue,
    int pricePerShare,
  ) async {
    final controller = TextEditingController(text: '${holding.shares}');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            final shares = int.tryParse(controller.text.trim()) ?? 0;
            final tooMany = shares > holding.shares;
            final quote = quoteSell(
              holding: holding,
              sellShares: shares,
              pricePerShare: pricePerShare,
            );
            final profit = quote.realizedProfit;
            final muted = Theme.of(ctx).colorScheme.onSurfaceVariant;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${etfName(widget.label)} 팔기',
                      style: const TextStyle(
                          fontSize: AppText.heading,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4)),
                  const SizedBox(height: AppGap.xs),
                  Text(
                      '${holding.shares}주 보유 · 1주 ${formatWon(pricePerShare)}',
                      style: TextStyle(fontSize: AppText.label, color: muted)),
                  const SizedBox(height: AppGap.md),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: AppText.numLg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '0',
                      suffixText: '주',
                    ),
                    onChanged: (_) => setSheet(() {}),
                  ),
                  const SizedBox(height: AppGap.cozy),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in const [(0.25, '1/4'), (0.5, '절반'), (1.0, '전부')])
                        ActionChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(f.$2),
                          onPressed: () {
                            final n = (holding.shares * f.$1).floor();
                            controller.text = '${n < 1 ? 1 : n}';
                            setSheet(() {});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppGap.md),
                  if (shares > 0 && !tooMany)
                    _Receipt(
                      rows: [
                        ('$shares주 × ${formatWon(pricePerShare)}', formatWon(quote.gross), null),
                        ('수수료 (0.215%, 최소 30원)', '−${formatWon(quote.fee)}', investDown),
                      ],
                      totalLabel: '받을 돈',
                      totalValue: formatWon(quote.netProceeds),
                      // 매수 수수료까지 반영한 진짜 손익을 보여준다.
                      note: '산 값 ${formatWon(quote.soldCost)} → '
                          '수수료까지 빼면 ${profit >= 0 ? '+' : ''}${formatWon(profit)}',
                      noteIsWarning: profit < 0,
                    )
                  else if (tooMany)
                    _Receipt(
                      rows: const [],
                      totalLabel: '',
                      totalValue: '',
                      note: '가진 것보다 많이 팔 수 없어요. (${holding.shares}주 보유)',
                      noteIsWarning: true,
                    ),
                  const SizedBox(height: AppGap.sm),
                  Container(
                    padding: const EdgeInsets.all(AppGap.md),
                    decoration: BoxDecoration(
                      color: appPalette(ctx).allowance.bg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '💡 사고팔 때마다 수수료가 들어요. 자주 사고팔면 수수료만 쌓여서 '
                      '손해가 될 수 있어요.',
                      style: TextStyle(
                          fontSize: AppText.caption,
                          height: 1.45,
                          color: appPalette(ctx).allowance.fg),
                    ),
                  ),
                  const SizedBox(height: AppGap.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: (shares <= 0 || tooMany)
                          ? null
                          : () async {
                              final owner =
                                  ref.read(settingsProvider).deviceOwner ?? '';
                              final got = await ref
                                  .read(databaseProvider)
                                  .sellSharesInvest(
                                    child: widget.child,
                                    holding: holding,
                                    shares: shares,
                                    indexValue: indexValue,
                                    editedBy: owner,
                                  );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (!context.mounted || got == null) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$shares주를 팔아 ${formatWon(got)}을 '
                                      '저축 포인트로 돌려받았어요.'),
                                ),
                              );
                            },
                      child: Text(shares <= 0 ? '몇 주 팔지 입력해주세요' : '$shares주 팔기'),
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
}

/// "지수는 6,595인데 내 1주는 왜 660원이야?"를 초등 저학년 눈높이로 풀어주는 카드.
///
/// 기본은 접어둔다. 한 번 이해하고 나면 매번 보이는 게 오히려 성가시기 때문에,
/// 궁금할 때만 펼쳐 보게 했다.
class _WhyThisPriceCard extends StatelessWidget {
  final String indexKey;
  final String label;
  final double indexValue;
  final int sharePrice;

  const _WhyThisPriceCard({
    required this.indexKey,
    required this.label,
    required this.indexValue,
    required this.sharePrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final slices = shareSliceCount(indexKey);

    // 조각 비유가 지수마다 달라진다. 억지로 하나로 맞추면 거짓말이 되므로 갈래를 나눈다.
    final String sliceStory;
    if (slices == null) {
      // 베트남처럼 달러로 값이 매겨진 바구니. 조각내기로는 설명이 안 된다.
      sliceStory = '$label${josa(label, '은', '는')} 달러로 사고파는 바구니예요. '
          '우리 돈으로 살 수 있는 크기로 바꿔서 ${etfName(label)}를 만들었어요. '
          '1주에 ${formatWon(sharePrice)}이에요.';
    } else if (slices <= 1) {
      // 코스닥처럼 원래 싼 바구니. 안 자른다는 게 오히려 좋은 대비가 된다.
      sliceStory = '$label${josa(label, '은', '는')} 바구니가 원래 싸서 자르지 않아도 살 수 있어요. '
          '그래서 ${etfName(label)} 1주가 바구니 하나 통째예요.';
    } else {
      sliceStory = '$label 바구니 하나는 ${indexFormat.format(indexValue)}이에요. '
          '통째로 사기엔 비싸니까 $slices조각으로 잘라서 ${etfName(label)}를 만들었어요. '
          '그 1조각이 바로 내가 사는 1주, ${formatWon(sharePrice)}이에요.';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppGap.sm),
      child: Theme(
        // ExpansionTile 기본 구분선을 없애 카드가 깔끔하게 보이도록.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: AppGap.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppGap.lg, 0, AppGap.lg, AppGap.lg),
          leading: const Text('🧺', style: TextStyle(fontSize: 22)),
          title: Text(
            '$label${josa(label, '은', '는')} ${indexFormat.format(indexValue)}인데 '
            '왜 1주가 ${formatWon(sharePrice)}이야?',
            style: const TextStyle(
                fontSize: AppText.body, fontWeight: FontWeight.w800),
          ),
          children: [
            _Para(sliceStory),
            const SizedBox(height: AppGap.sm),
            _Para('$label 숫자는 가질 수 없어요. 그건 "지금 얼마인지" 알려주는 숫자거든요. '
                '내가 가질 수 있는 건 그 숫자를 따라가도록 만든 ${etfName(label)} 1주예요.'),
            const SizedBox(height: AppGap.sm),
            _Para('바구니가 커지면 내 1주도 똑같이 커져요. '
                '$label${josa(label, '이', '가')} 1% 오르면 내 1주도 딱 1% 올라요. '
                '위 그래프에서 왼쪽 숫자($label)와 오른쪽 숫자(내 1주)가 '
                '같은 선을 가리키는 게 그래서예요.'),
            const SizedBox(height: AppGap.sm),
            Container(
              padding: const EdgeInsets.all(AppGap.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: AppGap.sm),
                  Expanded(
                    child: Text(
                      '1주 값이 싸다고 더 좋은 건 아니에요. '
                      '바구니마다 조각 크기가 다를 뿐이거든요. '
                      '어느 게 더 잘했는지 보려면 값이 아니라 "몇 % 올랐나"를 봐야 해요.',
                      style: TextStyle(
                          fontSize: AppText.label, height: 1.5, color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Para extends StatelessWidget {
  final String text;
  const _Para(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: AppText.label,
          height: 1.6,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}

/// 사기·팔기 시트의 정산 미리보기. 수수료를 항목으로 드러내는 게 목적이다.
class _Receipt extends StatelessWidget {
  final List<(String, String, Color?)> rows;
  final String totalLabel;
  final String totalValue;
  final String? note;
  final bool noteIsWarning;

  const _Receipt({
    required this.rows,
    required this.totalLabel,
    required this.totalValue,
    this.note,
    this.noteIsWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppGap.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.$1,
                      style: TextStyle(fontSize: AppText.label, color: muted)),
                  Text(r.$2,
                      style: TextStyle(
                          fontSize: AppText.label,
                          fontWeight: FontWeight.w700,
                          color: r.$3)),
                ],
              ),
            ),
          if (rows.isNotEmpty) const Divider(height: AppGap.lg),
          if (totalLabel.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(totalLabel,
                    style: const TextStyle(
                        fontSize: AppText.bodyLg, fontWeight: FontWeight.w800)),
                Text(totalValue,
                    style: const TextStyle(
                        fontSize: AppText.titleLg, fontWeight: FontWeight.w900)),
              ],
            ),
          if (note != null) ...[
            const SizedBox(height: AppGap.xs),
            Text(note!,
                style: TextStyle(
                    fontSize: AppText.caption,
                    height: 1.4,
                    fontWeight: noteIsWarning ? FontWeight.w700 : FontWeight.w400,
                    color: noteIsWarning ? investDown : muted)),
          ],
        ],
      ),
    );
  }
}

/// 이 지수의 보유 상태. 여러 번 나눠 샀어도 평단가 하나로 합쳐 보여준다.
class _MyHoldingCard extends StatelessWidget {
  final Holding holding;
  final int nowPrice;
  final VoidCallback? onSell;
  const _MyHoldingCard(
      {required this.holding, required this.nowPrice, required this.onSell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    // 지수를 못 받아오면 산 값 그대로 둔다(손익 0). 억지 숫자를 보여주지 않는다.
    final value = nowPrice > 0 ? holding.marketValue(nowPrice) : holding.costBasis;
    final diff = value - holding.costBasis;
    final pct = holding.costBasis == 0 ? 0.0 : diff / holding.costBasis * 100;
    final color = diff > 0 ? investUp : (diff < 0 ? investDown : muted);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${holding.shares}주',
                          style: const TextStyle(
                              fontSize: AppText.numMd,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6)),
                      const SizedBox(height: AppGap.xxs),
                      Text('평균 ${formatWon(holding.avgPrice)}에 샀어요',
                          style: TextStyle(fontSize: AppText.caption, color: muted)),
                    ],
                  ),
                ),
                const SizedBox(width: AppGap.sm),
                FilledButton(onPressed: onSell, child: const Text('팔기')),
              ],
            ),
            const Divider(height: AppGap.lg),
            _Line(label: '산 값 (수수료 포함)', value: formatWon(holding.costBasis)),
            _Line(
                label: nowPrice > 0 ? '지금 값 (1주 ${formatWon(nowPrice)})' : '지금 값',
                value: nowPrice > 0 ? formatWon(value) : '—'),
            const SizedBox(height: AppGap.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('평가손익',
                    style: const TextStyle(
                        fontSize: AppText.body, fontWeight: FontWeight.w700)),
                Text(
                    nowPrice > 0
                        ? '${diff >= 0 ? '+' : ''}${formatWon(diff)} '
                            '(${diff >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%)'
                        : '—',
                    style: TextStyle(
                        fontSize: AppText.titleLg,
                        fontWeight: FontWeight.w900,
                        color: color)),
              ],
            ),
            if (holding.realizedProfit != 0) ...[
              const SizedBox(height: AppGap.xs),
              Text(
                  '지금까지 팔아서 낸 손익 '
                  '${holding.realizedProfit >= 0 ? '+' : ''}'
                  '${formatWon(holding.realizedProfit)}',
                  style: TextStyle(fontSize: AppText.caption, color: muted)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: AppText.label, color: muted)),
          Text(value,
              style: const TextStyle(
                  fontSize: AppText.label, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

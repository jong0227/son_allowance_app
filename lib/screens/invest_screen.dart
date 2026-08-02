import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/market_provider.dart';
import '../services/invest_calc.dart';
import '../services/stock_search_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';
import 'invest_detail_screen.dart';

final indexFormat = NumberFormat('#,##0.##');

/// 오르면 빨강 / 내리면 파랑 (한국식).
const investUp = Color(0xFFE0574A);
const investDown = Color(0xFF3B7BD8);

/// 보유의 현재 평가액. 지수를 못 받아오면 원가 그대로 보여준다(손익 0으로 취급).
int holdingValue(Holding h, double? nowIndexValue) {
  if (nowIndexValue == null || nowIndexValue <= 0) return h.costBasis;
  final price = sharePriceOf(h.indexKey, nowIndexValue);
  return price <= 0 ? h.costBasis : h.marketValue(price);
}

/// 모의 투자 섹션. 저축 포인트로 세계 지수에 투자해보고, 팔면 손익이 저축에 반영된다.
/// 주식 탭 본문에 그대로 끼워 넣어 쓴다(별도 화면이 아니라 인라인 섹션).
class InvestSection extends ConsumerWidget {
  final Child child;
  const InvestSection({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = appPalette(context);
    final summary = ref.watch(summaryProvider(child.id)).valueOrNull;
    final indicesAsync = ref.watch(investIndicesProvider);
    final holdings = ref.watch(holdingsProvider(child.id));
    final trades = ref.watch(investTradesProvider(child.id)).valueOrNull ?? const [];

    final balance = summary?['balance'] ?? 0;
    final invested = summary?['invested'] ?? 0;
    final totalSavings = balance + invested;
    final cap = (totalSavings * child.investLimitPercent / 100).floor();
    final canInvest = (cap - invested).clamp(0, balance);

    final indices = indicesAsync.valueOrNull ?? const <MarketIndex>[];
    final bySymbol = {for (final i in indices) i.symbol: i};

    // 주수가 남아 있는 것만 "보유". 다 판 지수는 목록에서 빠진다.
    final open = holdings.where((h) => !h.isEmpty).toList();
    final openValue =
        open.fold<int>(0, (s, h) => s + holdingValue(h, bySymbol[h.symbol]?.value));
    final openGain = openValue - invested;
    final sellTrades = trades.where((t) => t.kind == kTradeSell).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader('모의 투자')),
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 19,
              tooltip: '지수 새로고침',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              onPressed: () => ref.invalidate(investIndicesProvider),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        _SummaryCard(
          canInvest: canInvest,
          invested: invested,
          openValue: openValue,
          gain: openGain,
          limitPercent: child.investLimitPercent,
          cap: cap,
          palette: palette,
        ),
        _Notice(
          pair: palette.allowance,
          text: '진짜 돈이 아니라 저축 포인트로 연습하는 투자예요. '
              '지수가 오르면 포인트가 늘고, 내리면 줄어요.',
        ),
        const SizedBox(height: AppGap.md),
        Text('지수를 눌러 차트를 보고 투자할 수 있어요',
            style: TextStyle(
                fontSize: AppText.label, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: AppGap.snug),
        if (indicesAsync.isLoading && indices.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppGap.xxl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (indices.isEmpty)
          _Notice(
            pair: palette.expense,
            text: '지수를 불러오지 못했어요. 인터넷 연결을 확인하고 새로고침해주세요.',
          )
        else
          for (final target in StockSearchService.investTargets)
            if (bySymbol[target.$3] != null)
              _IndexTile(
                index: bySymbol[target.$3]!,
                note: target.$4,
                holdingCount: open
                    .where((h) => h.indexKey == target.$1)
                    .fold<int>(0, (s, h) => s + h.shares),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => InvestDetailScreen(
                    child: child,
                    indexKey: target.$1,
                    label: target.$2,
                    symbol: target.$3,
                    note: target.$4,
                  ),
                )),
              ),
        if (open.isNotEmpty) ...[
          const SectionHeader('내가 가진 것'),
          for (final h in open)
            _HoldingTile(
              holding: h,
              nowIndexValue: bySymbol[h.symbol]?.value,
              palette: palette,
              onTap: () {
                final t = StockSearchService.investTargets
                    .where((e) => e.$1 == h.indexKey)
                    .firstOrNull;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => InvestDetailScreen(
                    child: child,
                    indexKey: h.indexKey,
                    label: h.label,
                    symbol: h.symbol,
                    note: t?.$4 ?? '',
                  ),
                ));
              },
            ),
        ],
        if (sellTrades.isNotEmpty) ...[
          const SectionHeader('판 기록'),
          for (final t in sellTrades.take(10))
            _SellTradeTile(trade: t, palette: palette),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int canInvest;
  final int invested;
  final int openValue;
  final int gain;
  final double limitPercent;
  final int cap;
  final AppPalette palette;
  const _SummaryCard({
    required this.canInvest,
    required this.invested,
    required this.openValue,
    required this.gain,
    required this.limitPercent,
    required this.cap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final pair = palette.savings;
    final gainColor = gain > 0 ? investUp : (gain < 0 ? investDown : pair.fg);
    final rate = invested == 0 ? 0.0 : gain / invested * 100;
    return Container(
      padding: const EdgeInsets.all(AppGap.lg),
      decoration:
          BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('지금 투자한 돈 (평가액)',
              style: TextStyle(fontSize: AppText.body, color: pair.fg.withValues(alpha: 0.85))),
          const SizedBox(height: AppGap.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(formatWon(openValue),
                    style: TextStyle(
                        fontSize: AppText.numLg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: pair.fg)),
                if (invested > 0) ...[
                  const SizedBox(width: AppGap.sm),
                  Text(
                      '${gain >= 0 ? '+' : ''}${formatWon(gain)} '
                      '(${gain >= 0 ? '+' : ''}${rate.toStringAsFixed(1)}%)',
                      style: TextStyle(
                          fontSize: AppText.bodyLg, fontWeight: FontWeight.w800, color: gainColor)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppGap.md),
          Row(
            children: [
              _Cell(label: '원금', value: formatWon(invested), pair: pair),
              const SizedBox(width: AppGap.sm),
              _Cell(
                label: '평가손익',
                value: invested == 0
                    ? '-'
                    : '${gain >= 0 ? '+' : ''}${formatWon(gain)}',
                pair: pair,
                valueColor: invested == 0 ? null : gainColor,
              ),
              const SizedBox(width: AppGap.sm),
              _Cell(
                label: '수익률',
                value: invested == 0
                    ? '-'
                    : '${gain >= 0 ? '+' : ''}${rate.toStringAsFixed(1)}%',
                pair: pair,
                valueColor: invested == 0 ? null : gainColor,
              ),
            ],
          ),
          const SizedBox(height: AppGap.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                    '더 넣을 수 있는 돈 ${formatWon(canInvest)} · '
                    '한도 총 저축의 ${formatPercent(limitPercent)}%(${formatWon(cap)})',
                    style:
                        TextStyle(fontSize: AppText.caption, color: pair.fg.withValues(alpha: 0.8))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label;
  final String value;
  final PastelPair pair;
  final Color? valueColor; // 손익처럼 색으로 뜻을 주는 값에만 지정
  const _Cell(
      {required this.label,
      required this.value,
      required this.pair,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: pair.fg.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: AppText.caption, color: pair.fg)),
            const SizedBox(height: AppGap.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: AppText.bodyLg,
                      fontWeight: FontWeight.w900,
                      color: valueColor ?? pair.fg)),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexTile extends StatelessWidget {
  final MarketIndex index;
  final String note;
  final int holdingCount;
  final VoidCallback onTap;
  const _IndexTile({
    required this.index,
    required this.note,
    required this.holdingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = index.isUp
        ? investUp
        : (index.isDown ? investDown : theme.colorScheme.onSurfaceVariant);
    final arrow = index.isUp ? '▲' : (index.isDown ? '▼' : '–');
    final sign = index.change > 0 ? '+' : '';
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Text(index.label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: AppText.title)),
            if (holdingCount > 0) ...[
              const SizedBox(width: AppGap.snug),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.xl)),
                child: Text('보유 $holdingCount',
                    style: TextStyle(
                        fontSize: AppText.micro,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary)),
              ),
            ],
          ],
        ),
        subtitle: Text(note,
            style: TextStyle(fontSize: AppText.label, color: theme.colorScheme.onSurfaceVariant)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(indexFormat.format(index.value),
                style: const TextStyle(
                    fontSize: AppText.title, height: 1.1, fontWeight: FontWeight.w800)),
            const SizedBox(height: AppGap.xxs),
            // "어제" 를 붙여 하루 등락률임을 분명히 한다.
            Text('어제 $arrow $sign${index.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                    fontSize: AppText.caption, height: 1.1, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// 보유 종목 한 줄. 지수별로 합쳐서 평단가·평가손익을 보여준다.
/// (예전엔 매수 건마다 한 줄이라 같은 코스피가 세 줄로 나뉘어 보였다)
class _HoldingTile extends StatelessWidget {
  final Holding holding;
  final double? nowIndexValue;
  final AppPalette palette;
  final VoidCallback onTap;
  const _HoldingTile({
    required this.holding,
    required this.nowIndexValue,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nowPrice = nowIndexValue == null
        ? 0
        : sharePriceOf(holding.indexKey, nowIndexValue!);
    final value = holdingValue(holding, nowIndexValue);
    final diff = value - holding.costBasis;
    final pct = holding.costBasis == 0 ? 0.0 : diff / holding.costBasis * 100;
    final color = diff > 0
        ? investUp
        : (diff < 0 ? investDown : theme.colorScheme.onSurfaceVariant);
    final muted = theme.colorScheme.onSurfaceVariant;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(fontSize: AppText.label, color: muted)),
              Text(value,
                  style: const TextStyle(
                      fontSize: AppText.label, fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppGap.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(etfName(holding.label),
                        style: const TextStyle(
                            fontSize: AppText.titleLg,
                            fontWeight: FontWeight.w800)),
                  ),
                  Text('${diff >= 0 ? '+' : ''}${formatWon(diff)}',
                      style: TextStyle(
                          fontSize: AppText.titleLg,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ],
              ),
              const SizedBox(height: AppGap.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${holding.shares}주 보유',
                      style: TextStyle(fontSize: AppText.label, color: muted)),
                  Text(
                      '${diff >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: AppText.label,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ],
              ),
              const Divider(height: AppGap.xl),
              // 평단가에는 매수 수수료가 들어 있어 "이 값을 넘어야 이득"이 된다.
              row('평균 산 가격', formatWon(holding.avgPrice)),
              if (nowPrice > 0) row('지금 가격', formatWon(nowPrice)),
              row('평가금액', formatWon(value)),
              const SizedBox(height: AppGap.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('눌러서 사고팔기',
                      style: TextStyle(fontSize: AppText.caption, color: muted)),
                  Icon(Icons.chevron_right, size: 16, color: muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 매도 기록 한 줄.
class _SellTradeTile extends StatelessWidget {
  final InvestTrade trade;
  final AppPalette palette;
  const _SellTradeTile({required this.trade, required this.palette});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gross = trade.shares * trade.pricePerShare;
    return Card(
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(Icons.sell_outlined, color: palette.savings.fg),
        title: Text('${etfName(trade.label)} ${trade.shares}주 팔았어요',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: AppText.body)),
        subtitle: Text(
            '${formatDateShort(trade.tradedAt)} · '
            '1주 ${formatWon(trade.pricePerShare)} · 수수료 ${formatWon(trade.fee)}',
            style: TextStyle(
                fontSize: AppText.caption,
                color: theme.colorScheme.onSurfaceVariant)),
        trailing: Text(formatWon(gross - trade.fee),
            style: const TextStyle(
                fontSize: AppText.label, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final PastelPair pair;
  final String text;
  const _Notice({required this.pair, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(AppGap.md),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Text(text, style: TextStyle(color: pair.fg, fontSize: AppText.label, height: 1.45)),
    );
  }
}

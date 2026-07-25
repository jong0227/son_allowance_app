import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/market_provider.dart';
import '../services/stock_search_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';
import 'invest_detail_screen.dart';

final indexFormat = NumberFormat('#,##0.##');

/// 오르면 빨강 / 내리면 파랑 (한국식).
const investUp = Color(0xFFE0574A);
const investDown = Color(0xFF3B7BD8);

/// 보유 포지션의 현재 평가액. 지수를 못 받아오면 원금 그대로.
int positionValue(Investment p, double? nowValue) {
  if (nowValue == null || nowValue <= 0 || p.buyValue <= 0) return p.amount;
  return (p.amount * nowValue / p.buyValue).round();
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
    final positions = ref.watch(investmentsProvider(child.id)).valueOrNull ?? const [];

    final balance = summary?['balance'] ?? 0;
    final invested = summary?['invested'] ?? 0;
    final totalSavings = balance + invested;
    final cap = (totalSavings * child.investLimitPercent / 100).floor();
    final canInvest = (cap - invested).clamp(0, balance);

    final indices = indicesAsync.valueOrNull ?? const <MarketIndex>[];
    final bySymbol = {for (final i in indices) i.symbol: i};

    final open = positions.where((p) => p.soldAt == null).toList();
    final closed = positions.where((p) => p.soldAt != null).toList();
    final openValue = open.fold<int>(
        0, (s, p) => s + positionValue(p, bySymbol[p.symbol]?.value));
    final openGain = openValue - invested;

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
        const SizedBox(height: 12),
        Text('지수를 눌러 차트를 보고 투자할 수 있어요',
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        if (indicesAsync.isLoading && indices.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
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
                holdingCount: open.where((p) => p.indexKey == target.$1).length,
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
          for (final p in open)
            _OpenPositionTile(
              position: p,
              nowValue: bySymbol[p.symbol]?.value,
              palette: palette,
            ),
        ],
        if (closed.isNotEmpty) ...[
          const SectionHeader('판 기록'),
          for (final p in closed.take(10))
            _ClosedPositionTile(position: p, palette: palette),
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
      padding: const EdgeInsets.all(18),
      decoration:
          BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('지금 투자한 돈 (평가액)',
              style: TextStyle(fontSize: 13, color: pair.fg.withValues(alpha: 0.85))),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(formatWon(openValue),
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: pair.fg)),
                if (invested > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                      '${gain >= 0 ? '+' : ''}${formatWon(gain)} '
                      '(${gain >= 0 ? '+' : ''}${rate.toStringAsFixed(1)}%)',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800, color: gainColor)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Cell(label: '원금', value: formatWon(invested), pair: pair),
              const SizedBox(width: 8),
              _Cell(
                label: '평가손익',
                value: invested == 0
                    ? '-'
                    : '${gain >= 0 ? '+' : ''}${formatWon(gain)}',
                pair: pair,
                valueColor: invested == 0 ? null : gainColor,
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                    '더 넣을 수 있는 돈 ${formatWon(canInvest)} · '
                    '한도 총 저축의 ${formatPercent(limitPercent)}%(${formatWon(cap)})',
                    style:
                        TextStyle(fontSize: 11.5, color: pair.fg.withValues(alpha: 0.8))),
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
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: pair.fg)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 14.5,
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
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            if (holdingCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('보유 $holdingCount',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary)),
              ),
            ],
          ],
        ),
        subtitle: Text(note,
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(indexFormat.format(index.value),
                style: const TextStyle(
                    fontSize: 15, height: 1.1, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            // "어제" 를 붙여 하루 등락률임을 분명히 한다.
            Text('어제 $arrow $sign${index.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(
                    fontSize: 11.5, height: 1.1, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _OpenPositionTile extends StatelessWidget {
  final Investment position;
  final double? nowValue;
  final AppPalette palette;
  const _OpenPositionTile(
      {required this.position, required this.nowValue, required this.palette});

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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: palette.savings.bg,
          child: Icon(Icons.show_chart, color: palette.savings.fg),
        ),
        title: Text('${position.label} · ${formatWon(position.amount)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(
            '${formatDateShort(position.buyAt)} 투자 · 지금 ${formatWon(value)}',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        trailing: Text(
            '${diff >= 0 ? '+' : ''}${formatWon(diff)}\n'
            '${diff >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12.5, height: 1.35, fontWeight: FontWeight.w800, color: color)),
      ),
    );
  }
}

class _ClosedPositionTile extends StatelessWidget {
  final Investment position;
  final AppPalette palette;
  const _ClosedPositionTile({required this.position, required this.palette});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final returned = position.returned ?? position.amount;
    final diff = returned - position.amount;
    final color = diff > 0
        ? investUp
        : (diff < 0 ? investDown : theme.colorScheme.onSurfaceVariant);
    return Card(
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Icon(diff >= 0 ? Icons.trending_up : Icons.trending_down,
            color: color),
        title: Text('${position.label} · ${formatWon(position.amount)} → ${formatWon(returned)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        subtitle: Text(
            '${formatDateShort(position.buyAt)} ~ ${formatDateShort(position.soldAt!)}',
            style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
        trailing: Text('${diff >= 0 ? '+' : ''}${formatWon(diff)}',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: TextStyle(color: pair.fg, fontSize: 12.5, height: 1.45)),
    );
  }
}

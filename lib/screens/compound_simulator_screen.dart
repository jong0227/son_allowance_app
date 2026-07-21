import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/rates_provider.dart';
import '../services/interest_calc.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// "지금처럼 모으면 나중에 얼마가 될까?" 복리 시뮬레이터.
/// 매주 넣는 돈과 기간을 바꿔가며, 이자가 붙어 불어나는 모습을 그래프로 본다.
class CompoundSimulatorScreen extends ConsumerStatefulWidget {
  final Child child;
  const CompoundSimulatorScreen({super.key, required this.child});

  @override
  ConsumerState<CompoundSimulatorScreen> createState() => _CompoundSimulatorScreenState();
}

class _CompoundSimulatorScreenState extends ConsumerState<CompoundSimulatorScreen> {
  double _weeklySave = 1000;
  double _weeks = 52;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final balance = ref.watch(summaryProvider(child.id)).valueOrNull?['balance'] ?? 0;
    final bonus = ref.watch(promiseBonusProvider(child.id)).valueOrNull ?? 0.0;
    final bankRate = ref.watch(depositRateProvider).valueOrNull;

    if (!_initialized && child.weeklyAllowanceDefault > 0) {
      // 기본값: 주간 용돈의 절반쯤 모으는 시나리오
      _weeklySave = (child.weeklyAllowanceDefault / 2).roundToDouble();
      _initialized = true;
    }

    // 한 주당 이자율(약속 보너스 포함). 월간 설정이면 주간으로 환산해 그래프를 그린다.
    final b = computeInterest(
      balance: balance,
      period: child.interestPeriod,
      useBankRate: child.interestUseBankRate,
      multiplier: child.interestMultiplier,
      fixedPercent: child.interestPercent,
      promiseBonusPercent: bonus,
      bankAnnualPercent: bankRate,
    );
    final weeklyRate = child.interestPeriod == 0
        ? b.totalPercent / 100
        : b.totalPercent / 100 / 4.345; // 월 → 주 근사

    final weeks = _weeks.round();
    final series = _simulate(
      start: balance.toDouble(),
      weeklySave: _weeklySave,
      weeklyRate: weeklyRate,
      weeks: weeks,
    );
    final finalAmount = series.last.round();
    final deposited = balance + (_weeklySave * weeks).round();
    final interestEarned = finalAmount - deposited;
    final palette = appPalette(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('얼마나 모일까?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: palette.savings.bg, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('${_weeksLabel(weeks)} 뒤에는',
                    style: TextStyle(fontSize: 14, color: palette.savings.fg)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(formatWon(finalAmount),
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: palette.savings.fg)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Pill(
                        label: '내가 넣은 돈',
                        value: formatWon(deposited),
                        pair: palette.savings),
                    _Pill(
                        label: '이자로 번 돈',
                        value: '+${formatWon(interestEarned)}',
                        pair: palette.income),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  // 이자 없이 그냥 모으기만 했을 때(비교용)
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i <= weeks; i++)
                        FlSpot(i.toDouble(), balance + _weeklySave * i),
                    ],
                    isCurved: false,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                    barWidth: 2,
                    dashArray: [5, 4],
                    dotData: const FlDotData(show: false),
                  ),
                  // 이자가 붙었을 때
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < series.length; i++)
                        FlSpot(i.toDouble(), series[i]),
                    ],
                    isCurved: true,
                    color: palette.income.fg,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: palette.income.fg.withValues(alpha: 0.15)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text('점선 = 이자 없이 모으기만 했을 때',
                style: TextStyle(fontSize: 11.5, color: theme.colorScheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 20),
          _SliderRow(
            label: '매주 모으는 돈',
            value: formatWon(_weeklySave.round()),
            slider: Slider(
              value: _weeklySave,
              min: 0,
              max: 10000,
              divisions: 100,
              onChanged: (v) => setState(() => _weeklySave = v),
            ),
          ),
          _SliderRow(
            label: '기간',
            value: _weeksLabel(weeks),
            slider: Slider(
              value: _weeks,
              min: 4,
              max: 156,
              divisions: 38,
              onChanged: (v) => setState(() => _weeks = v),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: palette.allowance.bg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '이자를 받으면 그 이자에 또 이자가 붙어요. 이걸 복리라고 해요. '
                    '오래 둘수록 초록 선이 점선에서 점점 더 멀어지는 걸 볼 수 있어요!',
                    style: TextStyle(
                        fontSize: 13.5, height: 1.5, color: palette.allowance.fg),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 매주 저축액을 넣고 이자를 붙여가며 잔액 변화를 만든다.
  List<double> _simulate({
    required double start,
    required double weeklySave,
    required double weeklyRate,
    required int weeks,
  }) {
    final out = <double>[start];
    var current = start;
    for (var i = 0; i < weeks; i++) {
      current += weeklySave;
      current += current * weeklyRate; // 이자에 또 이자(복리)
      out.add(current);
    }
    return out;
  }

  String _weeksLabel(int weeks) {
    if (weeks % 52 == 0) return '${weeks ~/ 52}년';
    if (weeks >= 52) {
      final y = weeks ~/ 52;
      final w = weeks % 52;
      return '$y년 $w주';
    }
    return '$weeks주';
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final PastelPair pair;
  const _Pill({required this.label, required this.value, required this.pair});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration:
          BoxDecoration(color: pair.fg.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Text('$label $value',
          style: TextStyle(color: pair.fg, fontSize: 12.5, fontWeight: FontWeight.w800)),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget slider;
  const _SliderRow({required this.label, required this.value, required this.slider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          ],
        ),
        slider,
      ],
    );
  }
}

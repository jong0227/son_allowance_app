import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';
import 'main_shell.dart';

/// 홈 + 통계를 합친 대시보드. 잔액/저축비율/이번 주 용돈/지출분석/최근내역을 한눈에.
class OverviewScreen extends ConsumerWidget {
  final Child child;
  const OverviewScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider(child.id));
    final schedulesAsync = ref.watch(schedulesProvider(child.id));
    final transactionsAsync = ref.watch(transactionsProvider(child.id));
    final expenseByCategoryAsync = ref.watch(expenseByCategoryProvider(child.id));
    final monthlyAsync = ref.watch(monthlyStatsProvider(child.id));
    final goalsAsync = ref.watch(goalsProvider(child.id));
    final palette = appPalette(context);
    final balanceNow = summaryAsync.valueOrNull?['balance'] ?? 0;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(summaryProvider(child.id)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildBackupReminder(context, ref),
          summaryAsync.when(
            loading: () => const _LoadingBox(height: 150),
            error: (e, _) => Text('오류: $e'),
            data: (s) {
              final balance = s['balance'] ?? 0;
              final income = s['totalIncome'] ?? 0;
              final expense = s['totalExpense'] ?? 0;
              final savings = s['totalSavings'] ?? 0;
              final rate = income == 0 ? 0.0 : (savings / income * 100).clamp(0, 100).toDouble();
              final threshold = child.autoTransferThreshold;
              final overThreshold = balance >= threshold;

              if (overThreshold) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  NotificationService.instance.showTransferRecommended(
                    childName: child.name,
                    balance: balance,
                    threshold: threshold,
                  );
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroBalanceCard(childName: child.name, balance: balance, rate: rate),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                            label: '총 수입',
                            value: formatWon(income),
                            pair: palette.income,
                            icon: Icons.south_west),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(
                            label: '총 소비',
                            value: formatWon(expense),
                            pair: palette.expense,
                            icon: Icons.north_east),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatTile(
                            label: '저축',
                            value: formatWon(savings),
                            pair: palette.savings,
                            icon: Icons.savings_outlined),
                      ),
                    ],
                  ),
                  if (overThreshold) ...[
                    const SizedBox(height: 12),
                    _TransferBanner(threshold: threshold),
                  ],
                  const SizedBox(height: 8),
                  _SavingsRateCard(income: income, expense: expense, savings: savings, rate: rate),
                  _buildBonus(context, ref, balance),
                ],
              );
            },
          ),
          const SectionHeader('이번 주 용돈'),
          schedulesAsync.when(
            loading: () => const _LoadingBox(height: 72),
            error: (e, _) => Text('오류: $e'),
            data: (schedules) {
              final now = DateTime.now();
              final within = schedules
                  .where((s) => s.scheduledDate.difference(now).inDays.abs() <= 7)
                  .toList();
              final unpaid = within.where((s) => !s.isPaid).toList()
                ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
              final paid = within.where((s) => s.isPaid).toList()
                ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
              final s = unpaid.isNotEmpty
                  ? unpaid.first
                  : (paid.isNotEmpty ? paid.first : null);
              if (s == null) {
                return const _MutedCard(text: '지급 요일이 되면 자동으로 일정이 만들어져요.');
              }
              final overdue = !s.isPaid && s.scheduledDate.isBefore(now);
              final pair =
                  s.isPaid ? palette.income : (overdue ? palette.expense : palette.allowance);
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: pair.bg,
                    child: Icon(s.isPaid ? Icons.check_rounded : Icons.schedule, color: pair.fg),
                  ),
                  title: Text(formatWon(s.amount),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${formatDate(s.scheduledDate)} · ${s.isPaid ? '지급 완료' : (overdue ? '미지급' : '지급 예정')}'),
                  trailing: s.isPaid
                      ? TextButton(onPressed: () => _undoPay(ref, s), child: const Text('취소'))
                      : FilledButton(onPressed: () => _payNow(ref, s), child: const Text('지급')),
                ),
              );
            },
          ),
          const SectionHeader('이번 주 예산'),
          transactionsAsync.maybeWhen(
            orElse: () => const _LoadingBox(height: 64),
            data: (txs) => _WeeklyBudgetCard(
                txs: txs, weeklyBudget: child.weeklyAllowanceDefault),
          ),
          SectionHeader('저축 목표',
              trailing: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showGoalDialog(context, ref),
              )),
          goalsAsync.when(
            loading: () => const _LoadingBox(height: 64),
            error: (e, _) => Text('오류: $e'),
            data: (goals) {
              if (goals.isEmpty) {
                return const _MutedCard(text: '갖고 싶은 것을 목표로 등록해보세요. (+ 버튼)');
              }
              return Column(
                children: [
                  for (final g in goals)
                    _GoalCard(
                      goal: g,
                      balance: balanceNow,
                      onEdit: () => _showGoalDialog(context, ref, existing: g),
                    ),
                ],
              );
            },
          ),
          const SectionHeader('카테고리별 지출'),
          expenseByCategoryAsync.when(
            loading: () => const _LoadingBox(height: 120),
            error: (e, _) => Text('오류: $e'),
            data: (map) {
              if (map.isEmpty) return const _MutedCard(text: '아직 지출 내역이 없어요.');
              final total = map.values.fold<int>(0, (a, b) => a + b);
              final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 32,
                            sectionsSpace: 2,
                            sections: [
                              for (final e in entries)
                                PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: palette.tagFor(e.key).fg,
                                  radius: 26,
                                  showTitle: false,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final e in entries)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: palette.tagFor(e.key).fg,
                                            borderRadius: BorderRadius.circular(3))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(e.key,
                                            style: const TextStyle(
                                                fontSize: 13, fontWeight: FontWeight.w600))),
                                    Text('${(e.value / total * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SectionHeader('받은 사람별 특별수입'),
          ref.watch(incomeByGiverProvider(child.id)).when(
                loading: () => const _LoadingBox(height: 80),
                error: (e, _) => Text('오류: $e'),
                data: (map) {
                  if (map.isEmpty) {
                    return const _MutedCard(text: '아직 특별수입(설날/생일 등) 기록이 없어요.');
                  }
                  final entries = map.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final maxV = entries.first.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          for (final e in entries)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 78,
                                    child: Text(e.key,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: maxV == 0 ? 0 : e.value / maxV,
                                        minHeight: 10,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        valueColor:
                                            AlwaysStoppedAnimation(palette.tagFor(e.key).fg),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(formatWon(e.value),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          const SectionHeader('이번 달 지출'),
          monthlyAsync.when(
            loading: () => const _LoadingBox(height: 80),
            error: (e, _) => Text('오류: $e'),
            data: (map) => _MonthSummaryCard(monthly: map),
          ),
          const SectionHeader('월별 수입 vs 지출'),
          monthlyAsync.when(
            loading: () => const _LoadingBox(height: 160),
            error: (e, _) => Text('오류: $e'),
            data: (map) {
              if (map.isEmpty) return const _MutedCard(text: '데이터가 아직 없어요.');
              final keys = map.keys.toList()..sort();
              final recent = keys.length > 6 ? keys.sublist(keys.length - 6) : keys;
              final maxVal = recent.fold<int>(0, (m, k) {
                final v = map[k]!;
                return [m, v['income'] ?? 0, v['expense'] ?? 0].reduce((a, b) => a > b ? a : b);
              });
              return Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        maxY: maxVal == 0 ? 10 : maxVal * 1.2,
                        barTouchData: BarTouchData(enabled: false),
                        barGroups: [
                          for (var i = 0; i < recent.length; i++)
                            BarChartGroupData(x: i, barsSpace: 4, barRods: [
                              BarChartRodData(
                                  toY: (map[recent[i]]!['income'] ?? 0).toDouble(),
                                  color: palette.income.fg,
                                  width: 9,
                                  borderRadius: BorderRadius.circular(3)),
                              BarChartRodData(
                                  toY: (map[recent[i]]!['expense'] ?? 0).toDouble(),
                                  color: palette.expense.fg,
                                  width: 9,
                                  borderRadius: BorderRadius.circular(3)),
                            ]),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= recent.length) return const SizedBox();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(recent[idx].substring(5),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Theme.of(context).colorScheme.onSurfaceVariant)),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SectionHeader('최근 내역'),
          transactionsAsync.when(
            loading: () => const _LoadingBox(height: 80),
            error: (e, _) => Text('오류: $e'),
            data: (txs) {
              final recent = txs.take(5).toList();
              if (recent.isEmpty) return const _MutedCard(text: '아직 등록된 내역이 없어요.');
              return Column(children: [for (final t in recent) _TxRow(t: t)]);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _payNow(WidgetRef ref, AllowanceSchedule s) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).markSchedulePaid(s, owner, child);
  }

  Future<void> _undoPay(WidgetRef ref, AllowanceSchedule s) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).markScheduleUnpaid(s, owner, child);
  }

  /// 조건부 절약 보너스 카드. 규칙이 켜져 있으면 항상 현재 상태를 안내한다.
  /// - 이미 이번 주에 받음: 완료 안내
  /// - 기준일 당일 이후 + 목표 달성: 축하 + 원버튼 지급
  /// - 기준일 이전: 목표 유지 안내 + 진행바
  /// - 기준일 지남 + 미달: 이번 주 미달 안내
  Widget _buildBonus(BuildContext context, WidgetRef ref, int balance) {
    if (!child.bonusEnabled) return const SizedBox.shrink();
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dayName = weekdayName(child.bonusDayOfWeek);
    final given = ref.watch(bonusGivenThisWeekProvider(child.id)).valueOrNull ?? false;
    final progress =
        child.bonusThreshold == 0 ? 1.0 : (balance / child.bonusThreshold).clamp(0.0, 1.0);
    final dayReached = now.weekday >= child.bonusDayOfWeek;
    final met = balance >= child.bonusThreshold;

    // 공통 진행 바 위젯
    Widget progressBar(Color color) => ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );

    // 상태별 구성
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String title;
    late final String sub;
    Widget? trailing;

    if (given) {
      bg = palette.income.bg;
      fg = palette.income.fg;
      icon = Icons.check_circle;
      title = '이번 주 절약 보너스 완료';
      sub = '${formatWon(child.bonusAmount)}을 지급했어요. 다음 주에 또 도전!';
    } else if (dayReached && met) {
      bg = palette.special.bg;
      fg = palette.special.fg;
      icon = Icons.emoji_events;
      title = '절약 목표 달성! 🎉';
      sub = '$dayName요일까지 ${formatWon(child.bonusThreshold)} 이상 유지했어요.';
      trailing = FilledButton(
        onPressed: () => _giveBonus(ref),
        child: Text('보너스 ${formatWon(child.bonusAmount)}'),
      );
    } else if (!dayReached) {
      bg = palette.allowance.bg;
      fg = palette.allowance.fg;
      icon = Icons.savings_outlined;
      title = '$dayName요일까지 ${formatWon(child.bonusThreshold)} 유지하기';
      sub =
          '지금 ${formatWon(balance)} · 유지하면 보너스 ${formatWon(child.bonusAmount)}';
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
      icon = Icons.sentiment_neutral;
      title = '이번 주는 목표에 조금 못 미쳤어요';
      sub = '현재 ${formatWon(balance)} / 목표 ${formatWon(child.bonusThreshold)}';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: fg, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: fg, fontWeight: FontWeight.w800, fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text(sub, style: TextStyle(color: fg, fontSize: 12.5)),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing],
              ],
            ),
            if (!given) ...[
              const SizedBox(height: 12),
              progressBar(fg),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _giveBonus(WidgetRef ref) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).giveSavingsBonus(child, owner);
  }

  /// Export를 오래 안 했으면 상단에 백업 공유 안내 배너.
  Widget _buildBackupReminder(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final txs = ref.watch(transactionsProvider(child.id)).valueOrNull ?? const [];
    if (txs.isEmpty) return const SizedBox.shrink();
    final last = settings.lastExportedAt;
    final stale = last == null || DateTime.now().difference(last).inDays >= 14;
    if (!stale) return const SizedBox.shrink();
    final pair = appPalette(context).savings;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(Icons.backup_outlined, color: pair.fg, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  last == null
                      ? '아직 백업을 공유한 적이 없어요. 가족과 데이터를 맞춰보세요.'
                      : '백업 공유한 지 2주가 지났어요. 최신 내용을 공유해보세요.',
                  style: TextStyle(color: pair.fg, fontSize: 12.5)),
            ),
            TextButton(
              onPressed: () => ref.read(mainTabIndexProvider.notifier).state = 3,
              child: const Text('설정으로'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref, {Goal? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController =
        TextEditingController(text: existing != null ? '${existing.targetAmount}' : '');
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? '목표 수정' : '저축 목표 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '갖고 싶은 것', hintText: '예: 레고 세트'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '목표 금액(원)'),
            ),
          ],
        ),
        actions: [
          if (isEdit)
            TextButton(
              onPressed: () async {
                final owner = ref.read(settingsProvider).deviceOwner ?? '';
                await ref.read(databaseProvider).softDeleteGoal(existing.id, owner);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text('삭제', style: TextStyle(color: appPalette(context).expense.fg)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final amount = int.tryParse(amountController.text);
              if (title.isEmpty || amount == null || amount <= 0) return;
              final db = ref.read(databaseProvider);
              final owner = ref.read(settingsProvider).deviceOwner ?? '';
              if (isEdit) {
                await db.updateGoalFields(existing.id,
                    title: title, targetAmount: amount, editedBy: owner);
              } else {
                await db.upsertGoal(GoalsCompanion.insert(
                  id: const Uuid().v4(),
                  childId: child.id,
                  title: title,
                  targetAmount: amount,
                  editedBy: Value(owner),
                  updatedAt: Value(DateTime.now()),
                ));
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

class _HeroBalanceCard extends StatelessWidget {
  final String childName;
  final int balance;
  final double rate;
  const _HeroBalanceCard({required this.childName, required this.balance, required this.rate});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [palette.heroFrom, palette.heroTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$childName의 잔여금액',
              style: TextStyle(
                  color: palette.heroText.withValues(alpha: 0.75),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(formatWon(balance),
              style: TextStyle(
                  color: palette.heroText,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.heroText.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, size: 15, color: palette.heroText),
                const SizedBox(width: 6),
                Text('저축비율 ${rate.toStringAsFixed(0)}%',
                    style: TextStyle(
                        color: palette.heroText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsRateCard extends StatelessWidget {
  final int income;
  final int expense;
  final int savings;
  final double rate;
  const _SavingsRateCard(
      {required this.income,
      required this.expense,
      required this.savings,
      required this.rate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 118,
              height: 118,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 118,
                    height: 118,
                    child: CircularProgressIndicator(
                      value: rate / 100,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(scheme.primary),
                    ),
                  ),
                  Container(
                    width: 84,
                    height: 84,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).cardColor),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${rate.toStringAsFixed(0)}%',
                            style:
                                const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                        Text('저축비율',
                            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(context, '총 수입', formatWon(income)),
                  _row(context, '총 소비', formatWon(expense)),
                  _row(context, '저축(이체+잔액)', formatWon(savings)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          ],
        ),
      );
}

class _TransferBanner extends StatelessWidget {
  final int threshold;
  const _TransferBanner({required this.threshold});

  @override
  Widget build(BuildContext context) {
    final pair = appPalette(context).savings;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(Icons.account_balance, color: pair.fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('주식계좌 이체를 고려해보세요',
                    style: TextStyle(
                        color: pair.fg, fontWeight: FontWeight.w700, fontSize: 14)),
                Text('잔액이 기준 금액(${formatWon(threshold)})을 넘었어요.',
                    style: TextStyle(color: pair.fg, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final TransactionEntry t;
  const _TxRow({required this.t});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final isIncome = t.flow == 'income';
    final pair = isIncome
        ? (t.category == '정기용돈' ? palette.allowance : palette.special)
        : palette.expense;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: pair.bg,
          child: Icon(isIncome ? Icons.add_rounded : Icons.remove_rounded, color: pair.fg),
        ),
        title: Row(
          children: [
            TagChip(label: t.category, pair: palette.tagFor(t.category)),
            const Spacer(),
            Text('${isIncome ? '+' : '-'}${formatWon(t.amount)}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isIncome ? palette.income.fg : palette.expense.fg)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(txSubtitle(t)),
        ),
      ),
    );
  }
}

class _MutedCard extends StatelessWidget {
  final String text;
  const _MutedCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  final double height;
  const _LoadingBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _WeeklyBudgetCard extends StatelessWidget {
  final List<TransactionEntry> txs;
  final int weeklyBudget;
  const _WeeklyBudgetCard({required this.txs, required this.weeklyBudget});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final spent = txs
        .where((t) =>
            t.flow == 'expense' &&
            !t.date.isBefore(weekStart) &&
            t.date.isBefore(weekEnd))
        .fold<int>(0, (a, b) => a + b.amount);
    final remaining = weeklyBudget - spent;
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    final ratio = weeklyBudget == 0 ? 0.0 : (spent / weeklyBudget).clamp(0.0, 1.0);
    final over = remaining < 0;
    final barColor = over ? palette.expense.fg : palette.income.fg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(over ? '이번 주 예산 초과' : '이번 주 남은 예산',
                    style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                Text('용돈 ${formatWon(weeklyBudget)}',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 6),
            Text('${over ? '-' : ''}${formatWon(remaining.abs())}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: over ? palette.expense.fg : scheme.onSurface)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 6),
            Text('이번 주 지출 ${formatWon(spent)}',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final int balance;
  final VoidCallback onEdit;
  const _GoalCard({required this.goal, required this.balance, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    final pair = palette.tagFor(goal.title);
    final ratio =
        goal.targetAmount == 0 ? 0.0 : (balance / goal.targetAmount).clamp(0.0, 1.0);
    final reached = balance >= goal.targetAmount;
    final pct = (ratio * 100).toStringAsFixed(0);

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(reached ? Icons.emoji_events : Icons.flag_outlined,
                      size: 18, color: reached ? palette.special.fg : pair.fg),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(goal.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text('$pct%',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: reached ? palette.special.fg : scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 9,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation(reached ? palette.special.fg : pair.fg),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                  reached
                      ? '목표 달성! ${formatWon(goal.targetAmount)} 모았어요 🎉'
                      : '${formatWon(balance)} / ${formatWon(goal.targetAmount)} · ${formatWon(goal.targetAmount - balance)} 남음',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  final Map<String, Map<String, int>> monthly;
  const _MonthSummaryCard({required this.monthly});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String key(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
    final thisKey = key(now);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastKey = key(lastMonth);

    final thisExpense = monthly[thisKey]?['expense'] ?? 0;
    final lastExpense = monthly[lastKey]?['expense'] ?? 0;
    final dailyAvg = (thisExpense / now.day).round();
    final diff = thisExpense - lastExpense;
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;

    Widget cell(String label, String value, {Color? valueColor}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: valueColor ?? scheme.onSurface)),
              ),
            ],
          ),
        );

    final diffText = diff == 0
        ? '지난달과 동일'
        : (diff > 0
            ? '지난달보다 ${formatWon(diff)} ▲'
            : '지난달보다 ${formatWon(-diff)} ▼');
    final diffColor = diff > 0 ? palette.expense.fg : palette.income.fg;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                cell('이번 달 지출', formatWon(thisExpense)),
                cell('하루 평균', formatWon(dailyAvg)),
              ],
            ),
            const SizedBox(height: 12),
            Text(diffText,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: diffColor)),
          ],
        ),
      ),
    );
  }
}

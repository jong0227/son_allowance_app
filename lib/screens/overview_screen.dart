import 'package:drift/drift.dart' show Value;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/rates_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tier_provider.dart';
import '../services/interest_calc.dart';
import '../services/notification_service.dart';
import '../utils/formatters.dart';
import '../widgets/market_index_strip.dart';
import '../widgets/promises_home_card.dart';
import '../widgets/rates_strip.dart';
import '../widgets/tier_widgets.dart';
import '../widgets/ui_kit.dart';
import 'interest_explainer_screen.dart';
import 'main_shell.dart';

/// 홈 화면에서 상세 통계(차트 묶음)를 펼쳤는지 여부. 기본은 접힘.
final _showDetailsProvider = StateProvider<bool>((ref) => false);

/// 홈 + 통계를 합친 대시보드. 기본은 핵심 정보만, "상세 통계"는 접어서 보여준다.
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
    final isChild = ref.watch(settingsProvider).isChild;
    final showDetails = ref.watch(_showDetailsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(summaryProvider(child.id)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _buildLevelUpBanner(context, ref),
          _buildTierCard(ref),
          const MarketIndexStrip(),
          if (!isChild) _buildBackupReminder(context, ref),
          _buildRequestsSection(context, ref, isChild),
          summaryAsync.when(
            loading: () => const _LoadingBox(height: 150),
            error: (e, _) => Text('오류: $e'),
            data: (s) {
              final balance = s['balance'] ?? 0;
              final income = s['totalIncome'] ?? 0;
              final expense = s['totalExpense'] ?? 0;
              final savings = s['totalSavings'] ?? 0;
              // 저축률 = 받은 용돈 중 안 쓴 비율 (시작 잔액은 제외해 왜곡 방지).
              // "용돈을 받아서 그중 얼마를 안 쓰고 모았나"를 뜻함.
              final rate =
                  income == 0 ? 0.0 : (((income - expense) / income) * 100).clamp(0, 100).toDouble();
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

              final txsForBudget = transactionsAsync.valueOrNull ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 잔액 + 이번 주 남은 예산 나란히
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _BalanceMiniCard(
                              childName: child.name, balance: balance, rate: rate),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _WeeklyBudgetMiniCard(
                              txs: txsForBudget,
                              weeklyBudget: child.weeklyAllowanceDefault,
                              weeklyTiers:
                                  ref.watch(weeklyTiersProvider).valueOrNull ?? const []),
                        ),
                      ],
                    ),
                  ),
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
                  _SavingsRateCard(
                      income: income, expense: expense, savings: savings, rate: rate),
                  const SizedBox(height: 8),
                  const RatesStrip(),
                  _buildBonus(context, ref, isChild),
                  _buildInterest(context, ref, balance, isChild),
                  // 약속 카드는 부모/아이 모두에게 보인다(아이는 댓글로 참여).
                  PromisesHomeCard(childId: child.id),
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
              final today = DateTime(now.year, now.month, now.day);
              bool isPastDay(DateTime d) =>
                  DateTime(d.year, d.month, d.day).isBefore(today);
              // 밀린 용돈(지난 미지급) 요약 — 내역 탭에서 지급/건너뛰기 처리
              final overdueList =
                  schedules.where((s) => !s.isPaid && isPastDay(s.scheduledDate)).toList();
              final overdueSum =
                  overdueList.fold<int>(0, (a, b) => a + b.amount);
              // 이번 주 카드: 오늘 이후 첫 미지급 예정, 없으면 최근 지급 완료
              final upcoming = schedules
                  .where((s) => !s.isPaid && !isPastDay(s.scheduledDate))
                  .toList()
                ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
              final paid = schedules
                  .where((s) =>
                      s.isPaid && s.scheduledDate.difference(now).inDays.abs() <= 7)
                  .toList()
                ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
              final s = upcoming.isNotEmpty
                  ? upcoming.first
                  : (paid.isNotEmpty ? paid.first : null);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (overdueList.isNotEmpty)
                    Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: palette.expense.bg,
                          child: Icon(Icons.history, color: palette.expense.fg),
                        ),
                        title: Text(
                            '밀린 용돈 ${overdueList.length}건 · ${formatWon(overdueSum)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('내역 탭에서 지급하거나 건너뛸 수 있어요'),
                      ),
                    ),
                  if (s == null)
                    const _MutedCard(text: '지급 요일이 되면 자동으로 일정이 만들어져요.')
                  else
                    Card(
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor:
                              s.isPaid ? palette.income.bg : palette.allowance.bg,
                          child: Icon(s.isPaid ? Icons.check_rounded : Icons.schedule,
                              color: s.isPaid ? palette.income.fg : palette.allowance.fg),
                        ),
                        title: Text(formatWon(s.amount),
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                            '${formatDate(s.scheduledDate)} · ${s.isPaid ? '지급 완료' : '지급 예정'}'),
                        trailing: isChild
                            ? null
                            : (s.isPaid
                                ? TextButton(
                                    onPressed: () => _undoPay(ref, s), child: const Text('취소'))
                                : FilledButton(
                                    onPressed: () => _payNow(ref, s), child: const Text('지급'))),
                      ),
                    ),
                ],
              );
            },
          ),
          SectionHeader(isChild ? '갖고 싶은 것 (위시리스트)' : '저축 목표',
              trailing: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: isChild ? '부모님께 요청' : '목표 추가',
                onPressed: () => isChild
                    ? _showWishlistRequestDialog(context, ref)
                    : _showGoalDialog(context, ref),
              )),
          goalsAsync.when(
            loading: () => const _LoadingBox(height: 64),
            error: (e, _) => Text('오류: $e'),
            data: (goals) {
              if (goals.isEmpty) {
                return _MutedCard(
                    text: isChild
                        ? '갖고 싶은 게 있으면 + 버튼으로 부모님께 요청해보세요.'
                        : '갖고 싶은 것을 목표로 등록해보세요. (+ 버튼)');
              }
              return Column(
                children: [
                  for (final g in goals)
                    _GoalCard(
                      goal: g,
                      balance: balanceNow,
                      onEdit: isChild ? null : () => _showGoalDialog(context, ref, existing: g),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          // 최근 내역은 내역 탭으로 이동(홈을 간결하게).
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: palette.expense.bg,
                child: Icon(Icons.receipt_long, color: palette.expense.fg),
              ),
              title: const Text('전체 내역 보기',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('수입·지출 내역을 내역 탭에서 확인해요'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ref.read(mainTabIndexProvider.notifier).state = 1,
            ),
          ),
          const SizedBox(height: 12),
          // 상세 통계 바로가기 — 크고 눈에 띄게(접근성 ↑). 누르면 아래 통계가 펼쳐진다.
          _DetailsToggleButton(
            expanded: showDetails,
            onTap: () =>
                ref.read(_showDetailsProvider.notifier).state = !showDetails,
          ),
          const SizedBox(height: 12),
          if (showDetails) ...[
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
          const SectionHeader('월별 요약'),
          ref.watch(monthlyBreakdownProvider(child.id)).when(
                loading: () => const _LoadingBox(height: 120),
                error: (e, _) => Text('오류: $e'),
                data: (byMonth) => _MonthlyBreakdownCard(byMonth: byMonth),
              ),
          const SectionHeader('올해 요약'),
          ref.watch(yearlyStatsProvider(child.id)).when(
                loading: () => const _LoadingBox(height: 120),
                error: (e, _) => Text('오류: $e'),
                data: (byYear) => _YearSummaryCard(byYear: byYear),
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
          ], // showDetails
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
  ///
  /// 판단 기준은 "이번 주 받은 용돈 중 얼마가 남았는지"다(전체 누적 잔액이 아님).
  /// 누적 잔액으로 비교하면 저축이 쌓일수록 목표가 항상 저절로 달성돼 버려
  /// 정보로서 의미가 없어진다.
  Widget _buildBonus(BuildContext context, WidgetRef ref, bool isChild) {
    if (!child.bonusEnabled) return const SizedBox.shrink();
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dayName = weekdayName(child.bonusDayOfWeek);
    final given = ref.watch(bonusGivenThisWeekProvider(child.id)).valueOrNull ?? false;
    // 자녀 모드: 이미 보낸 대기 중 보너스 요청이 있으면 버튼 대신 "요청함" 표시
    final pendingBonusReq = ref
            .watch(requestsProvider(child.id))
            .valueOrNull
            ?.any((r) => r.type == 'bonus' && r.status == 'pending') ??
        false;

    final txs = ref.watch(transactionsProvider(child.id)).valueOrNull ?? const [];
    final weekStart =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final weeklyBudget = child.weeklyAllowanceDefault;
    final weekSpent = txs
        .where((t) =>
            t.flow == 'expense' && !t.date.isBefore(weekStart) && t.date.isBefore(weekEnd))
        .fold<int>(0, (a, b) => a + b.amount);
    final weekRemaining = weeklyBudget - weekSpent;

    final progress = child.bonusThreshold == 0
        ? 1.0
        : (weekRemaining / child.bonusThreshold).clamp(0.0, 1.0);
    final dayReached = now.weekday >= child.bonusDayOfWeek;
    final met = weekRemaining >= child.bonusThreshold;
    final daysLeft = child.bonusDayOfWeek - now.weekday; // !dayReached일 때만 유효(항상 ≥1)

    // "이번 주 용돈 3,000원 중 1,200원 썼어요 (1,800원 남음)"
    String spendLine() => '이번 주 용돈 ${formatWon(weeklyBudget)} 중 ${formatWon(weekSpent)} 썼어요 '
        '(${formatWon(weekRemaining < 0 ? 0 : weekRemaining)} 남음)';
    // "내일 목요일까지" / "목요일까지 D-2"
    String dayLeftText() =>
        daysLeft == 1 ? '내일 $dayName요일까지' : '$dayName요일까지 D-$daysLeft';

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
      sub = '${spendLine()}\n$dayName요일까지 ${formatWon(child.bonusThreshold)} 이상 남겼어요.';
      if (isChild) {
        // 자녀: 직접 지급 대신 부모에게 요청
        trailing = pendingBonusReq
            ? const Chip(label: Text('요청함'))
            : FilledButton(
                onPressed: () => _requestBonus(context, ref),
                child: const Text('보너스 요청'),
              );
      } else {
        trailing = FilledButton(
          onPressed: () => _giveBonus(ref),
          child: Text('보너스 ${formatWon(child.bonusAmount)}'),
        );
      }
    } else if (!dayReached) {
      bg = palette.allowance.bg;
      fg = palette.allowance.fg;
      icon = Icons.savings_outlined;
      // 제목은 "무엇을 하는 카드인지", 부제는 "조건 → 보상"을 한 문장으로.
      // (예전엔 제목이 조건으로 시작해 아이가 왜 이 숫자가 있는지 이해하기 어려웠음)
      title = '이번 주 절약 도전';
      sub = '${spendLine()}\n${dayLeftText()} · ${formatWon(child.bonusThreshold)} 이상 남기면 '
          '+${formatWon(child.bonusAmount)}';
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
      icon = Icons.sentiment_neutral;
      title = '이번 주는 목표에 조금 못 미쳤어요';
      sub = '${spendLine()}\n목표 ${formatWon(child.bonusThreshold)}엔 못 미쳤어요. 다음 주에 다시 도전!';
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

  // ---------- 자녀 요청 ----------
  Future<void> _requestBonus(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(databaseProvider).requestBonus(child, '아들');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? '부모님께 보너스를 요청했어요.' : '이미 요청한 보너스가 있어요.')));
    }
  }

  void _showWishlistRequestDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('갖고 싶은 것 요청'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: '갖고 싶은 것', hintText: '예: 레고 세트'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '가격(원)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final amount = int.tryParse(amountController.text) ?? 0;
              if (title.isEmpty) return;
              await ref.read(databaseProvider).requestWishlist(child, title, amount, '아들');
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('부모님께 요청했어요.')));
              }
            },
            child: const Text('요청'),
          ),
        ],
      ),
    );
  }

  /// 요청 섹션.
  /// - 부모: 대기 중 요청을 승인/거절.
  /// - 자녀: 내가 보낸 요청의 상태를 확인(대기 중이면 취소 가능).
  Widget _buildRequestsSection(BuildContext context, WidgetRef ref, bool isChild) {
    final palette = appPalette(context);
    if (isChild) {
      final reqs = ref.watch(requestsProvider(child.id)).valueOrNull ?? const [];
      final visible = reqs.where((r) => r.status == 'pending').toList();
      if (visible.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader('내 요청'),
          for (final r in visible)
            Card(
              child: ListTile(
                leading: Icon(
                    r.type == 'bonus'
                        ? Icons.emoji_events_outlined
                        : (r.type == 'stock' ? Icons.request_quote : Icons.card_giftcard),
                    color: palette.special.fg),
                title: Text(_requestLabel(r)),
                subtitle: const Text('부모님 확인 대기 중'),
                trailing: TextButton(
                  onPressed: () =>
                      ref.read(databaseProvider).cancelRequest(r.id, '아들'),
                  child: const Text('취소'),
                ),
              ),
            ),
        ],
      );
    }
    // 부모
    final pending = ref.watch(pendingRequestsProvider(child.id)).valueOrNull ?? const [];
    if (pending.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader('${child.name}의 요청 ${pending.length}건'),
        for (final r in pending)
          Card(
            color: palette.special.bg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(
                children: [
                  Icon(
                      r.type == 'bonus'
                          ? Icons.emoji_events
                          : (r.type == 'stock' ? Icons.request_quote : Icons.card_giftcard),
                      color: palette.special.fg),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_requestLabel(r),
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: palette.special.fg)),
                        Text(
                            r.type == 'bonus'
                                ? '승인하면 보너스가 지급돼요'
                                : (r.type == 'stock'
                                    ? '주식이체 탭에서 구매 결과를 입력해요'
                                    : '승인하면 저축 목표로 등록돼요'),
                            style:
                                TextStyle(fontSize: 12, color: palette.special.fg.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(databaseProvider).rejectRequest(
                        r, ref.read(settingsProvider).deviceOwner ?? ''),
                    child: const Text('거절'),
                  ),
                  // 주식 요청은 구매 수량/금액 입력이 필요해 주식이체 탭으로 보낸다.
                  if (r.type == 'stock')
                    FilledButton(
                      onPressed: () =>
                          ref.read(mainTabIndexProvider.notifier).state = 2,
                      child: const Text('구매하러'),
                    )
                  else
                    FilledButton(
                      onPressed: () => ref.read(databaseProvider).approveRequest(
                          r, ref.read(settingsProvider).deviceOwner ?? ''),
                      child: const Text('승인'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _requestLabel(Request r) {
    if (r.type == 'bonus') return '절약 보너스 ${formatWon(r.amount)} 지급';
    if (r.type == 'stock') return '주식: ${r.title ?? ''} ${formatWon(r.amount)}어치';
    final price = r.amount > 0 ? ' (${formatWon(r.amount)})' : '';
    return '위시리스트: ${r.title ?? ''}$price';
  }

  /// 저축 이자 카드. 규칙이 켜져 있을 때만 표시.
  /// COFIX 금리 안내 + "이자가 뭐야?" 설명 링크 + 약속 보너스가 반영된 실효 이자율을 보여준다.
  /// - 부모 모드: 원버튼 지급 버튼(이미 지급했으면 카드 자체가 사라짐)
  /// - 자녀 모드: 지급 버튼 없이, 지금 적용받는 이자율/금액을 항상 볼 수 있는 정보 카드
  ///   (예전엔 부모 전용 카드라 자녀 화면엔 아예 안 보였음)
  Widget _buildInterest(BuildContext context, WidgetRef ref, int balance, bool isChild) {
    if (!child.interestEnabled) return const SizedBox.shrink();
    final given = ref
            .watch(interestGivenProvider((childId: child.id, period: child.interestPeriod)))
            .valueOrNull ??
        false;
    if (!isChild && given) return const SizedBox.shrink();
    final bonus = ref.watch(promiseBonusProvider(child.id)).valueOrNull ?? 0.0;
    final bankRate = ref.watch(depositRateProvider).valueOrNull;
    final b = computeInterest(
      balance: balance,
      period: child.interestPeriod,
      useBankRate: child.interestUseBankRate,
      multiplier: child.interestMultiplier,
      fixedPercent: child.interestPercent,
      promiseBonusPercent: bonus,
      bankAnnualPercent: bankRate,
    );
    if (b.amount <= 0) return const SizedBox.shrink();
    final pair = appPalette(context).savings;
    final multiple = b.multipleOfBank;
    final promiseCount =
        (ref.watch(promisesProvider(child.id)).valueOrNull ?? const [])
            .where((p) => p.enabled)
            .length;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings_outlined, color: pair.fg, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      isChild
                          ? (given ? '${b.periodName} 이자 받았어요' : '${b.periodName} 이자율')
                          : '${b.periodName} 저축 이자 받기',
                      style: TextStyle(
                          color: pair.fg, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => InterestExplainerScreen(breakdown: b)),
                  ),
                  child: Text('이자가 뭐야?',
                      style: TextStyle(
                        color: pair.fg,
                        fontSize: 11.5,
                        decoration: TextDecoration.underline,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 정확한 이자율(1회분/주/월/년) — "지금 몇 % 받고 있나"에 바로 답한다.
            Text(
              '${formatPercent(b.totalPercent)}% (주 ${formatPercent(b.weeklyPercent)}% · '
              '월 ${formatPercent(b.monthlyPercent)}% · 년 ${formatPercent(b.annualPercent)}%)',
              style: TextStyle(color: pair.fg, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            // 은행보다 얼마나 더 주는지 — 아이가 금리 차이를 체감하는 핵심 줄.
            if (multiple != null) ...[
              Text('은행에 맡기면 ${formatWon(b.bankAmount)}  →  우리집은 ${formatWon(b.amount)}',
                  style: TextStyle(color: pair.fg, fontSize: 12.5)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: pair.fg.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  promiseCount > 0
                      ? '약속 $promiseCount개 지킴 · 은행의 ${formatPercent(multiple)}배!'
                      : '은행의 ${formatPercent(multiple)}배!',
                  style: TextStyle(
                      color: pair.fg, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ] else
              Text('잔액 ${formatWon(balance)}의 ${formatPercent(b.totalPercent)}%',
                  style: TextStyle(color: pair.fg, fontSize: 12.5)),
            const SizedBox(height: 10),
            if (isChild)
              Text(
                given ? '다음 지급 때 새로 계산돼요.' : '부모님이 지급하면 +${formatWon(b.amount)} 받아요.',
                style: TextStyle(color: pair.fg.withValues(alpha: 0.85), fontSize: 12),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _giveInterest(ref, bankRate),
                  child: Text('+${formatWon(b.amount)} 받기'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _giveInterest(WidgetRef ref, double? bankRate) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref
        .read(databaseProvider)
        .giveInterest(child, owner, bankAnnualPercent: bankRate);
  }

  /// 홈 상단: 누적 저축 티어 + 주간 저축률 티어를 나란히 두 블럭으로.
  Widget _buildTierCard(WidgetRef ref) {
    final tierScore = ref.watch(summaryProvider(child.id)).valueOrNull?['tierScore'] ?? 0;
    final savingsTiers = ref.watch(savingsTiersProvider).valueOrNull ?? const [];
    final weeklyTiers = ref.watch(weeklyTiersProvider).valueOrNull ?? const [];
    if (savingsTiers.isEmpty) return const SizedBox.shrink();

    // 이번 주 저축률 = (주간 용돈 - 이번 주 지출) / 주간 용돈
    final txs = ref.watch(transactionsProvider(child.id)).valueOrNull ?? const [];
    final now = DateTime.now();
    final weekStart =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final budget = child.weeklyAllowanceDefault;
    final spent = txs
        .where((t) =>
            t.flow == 'expense' && !t.date.isBefore(weekStart) && t.date.isBefore(weekEnd))
        .fold<int>(0, (a, b) => a + b.amount);
    final savePct = budget == 0 ? 0 : (((budget - spent) / budget) * 100).clamp(0, 100).round();

    // 카드 자체에 상하 5px 마진이 있으므로 추가 패딩을 두지 않는다.
    // (예전엔 bottom 8이 더 붙어 아래 카드와 간격이 18px로 벌어져 보였음)
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TierSummaryCard(
                label: '부자 등급', tiers: savingsTiers, value: tierScore),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TierSummaryCard(
                label: '주간 저축률',
                tiers: weeklyTiers,
                value: savePct,
                isPercent: true),
          ),
        ],
      ),
    );
  }

  /// 새 티어 도달 시 축하 배너. 마지막으로 축하한 순서보다 높아졌을 때만 1회 표시.
  Widget _buildLevelUpBanner(BuildContext context, WidgetRef ref) {
    final tierScore = ref.watch(summaryProvider(child.id)).valueOrNull?['tierScore'] ?? 0;
    final tiers = ref.watch(savingsTiersProvider).valueOrNull ?? const [];
    if (tiers.isEmpty) return const SizedBox.shrink();
    final pos = tierFor(tiers, tierScore);
    final cur = pos.current;
    final lastCelebrated = ref.watch(settingsProvider).lastCelebratedTierOrder;
    // 기본 티어(흙, order 1)는 축하하지 않는다.
    if (cur == null || cur.sortOrder <= 1 || cur.sortOrder <= lastCelebrated) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [scheme.tertiaryContainer, scheme.primaryContainer]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(cur.icon, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎉 "${cur.title}" 티어 달성!',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: scheme.onPrimaryContainer)),
                  if (cur.reward != null && cur.reward!.isNotEmpty)
                    Text('보상: ${cur.reward}',
                        style: TextStyle(
                            fontSize: 12.5, color: scheme.onPrimaryContainer.withValues(alpha: 0.9))),
                ],
              ),
            ),
            TextButton(
              onPressed: () =>
                  ref.read(settingsProvider.notifier).setLastCelebratedTierOrder(cur.sortOrder),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
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

/// 홈 상단 좌측: 잔액 미니 카드(그라데이션). 오른쪽 주간예산 카드와 나란히.
class _BalanceMiniCard extends StatelessWidget {
  final String childName;
  final int balance;
  final double rate;
  const _BalanceMiniCard(
      {required this.childName, required this.balance, required this.rate});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [palette.heroFrom, palette.heroTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  size: 15, color: palette.heroText.withValues(alpha: 0.85)),
              const SizedBox(width: 5),
              Flexible(
                child: Text('$childName의 잔액',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: palette.heroText.withValues(alpha: 0.78),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatWon(balance),
                style: TextStyle(
                    color: palette.heroText,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.1)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: palette.heroText.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, size: 13, color: palette.heroText),
                const SizedBox(width: 5),
                Text('저축비율 ${rate.toStringAsFixed(0)}%',
                    style: TextStyle(
                        color: palette.heroText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 홈 상단 우측: 이번 주 남은 예산 미니 카드. 왼쪽 잔액 카드와 나란히.
class _WeeklyBudgetMiniCard extends StatelessWidget {
  final List<TransactionEntry> txs;
  final int weeklyBudget;
  final List<Tier> weeklyTiers;
  const _WeeklyBudgetMiniCard(
      {required this.txs, required this.weeklyBudget, this.weeklyTiers = const []});

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
    final savePct =
        weeklyBudget == 0 ? 0 : ((remaining / weeklyBudget) * 100).clamp(0, 100).round();
    final weeklyTier = tierFor(weeklyTiers, savePct).current;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Flexible(
                child: Text(over ? '이번 주 예산 초과' : '이번 주 남은 예산',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('${over ? '-' : ''}${formatWon(remaining.abs())}',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.1,
                    color: over ? palette.expense.fg : scheme.onSurface)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: 7),
          if (weeklyTier != null && !over)
            Text('${weeklyTier.icon} ${weeklyTier.title} · 저축 $savePct%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant))
          else
            Text('용돈 ${formatWon(weeklyBudget)} · 지출 ${formatWon(spent)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// 상세 통계 펼치기/접기 버튼. 홈 요약 바로 아래에 크게 배치해 접근성 ↑.
class _DetailsToggleButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _DetailsToggleButton({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(Icons.insights_rounded, size: 20, color: scheme.onSecondaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(expanded ? '상세 통계 접기' : '상세 통계 보기',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: scheme.onSecondaryContainer)),
              ),
              Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  color: scheme.onSecondaryContainer),
            ],
          ),
        ),
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

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final int balance;
  final VoidCallback? onEdit;
  const _GoalCard({required this.goal, required this.balance, this.onEdit});

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

/// 월별 항목별 요약 (올해 요약과 같은 구성, 달 단위로 넘겨보기).
class _MonthlyBreakdownCard extends StatefulWidget {
  final Map<String, Map<String, int>> byMonth;
  const _MonthlyBreakdownCard({required this.byMonth});

  @override
  State<_MonthlyBreakdownCard> createState() => _MonthlyBreakdownCardState();
}

class _MonthlyBreakdownCardState extends State<_MonthlyBreakdownCard> {
  String? _month;

  @override
  Widget build(BuildContext context) {
    final months = widget.byMonth.keys.toList()..sort();
    if (months.isEmpty) return const _MutedCard(text: '아직 월별 데이터가 없어요.');
    var month = _month;
    if (month == null || !widget.byMonth.containsKey(month)) month = months.last;
    final d = widget.byMonth[month]!;
    final palette = appPalette(context);
    final regular = d['regular'] ?? 0;
    final special = d['special'] ?? 0;
    final bonus = d['bonus'] ?? 0;
    final interest = d['interest'] ?? 0;
    final quiz = d['quiz'] ?? 0;
    final expense = d['expense'] ?? 0;
    final transfer = d['transfer'] ?? 0;
    final income = regular + special + bonus + interest + quiz;
    final idx = months.indexOf(month);
    final parts = month.split('-');
    final label = '${parts[0]}년 ${int.parse(parts[1])}월';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      idx > 0 ? () => setState(() => _month = months[idx - 1]) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: idx < months.length - 1
                      ? () => setState(() => _month = months[idx + 1])
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _row('총 수입', formatWon(income), palette.income.fg, true),
            const Divider(height: 18),
            _row('정기 용돈', formatWon(regular), null, false),
            _row('특별 수입', formatWon(special), null, false),
            if (bonus > 0) _row('절약 보너스', formatWon(bonus), null, false),
            if (interest > 0) _row('저축 이자', formatWon(interest), null, false),
            if (quiz > 0) _row('퀴즈 보상', formatWon(quiz), null, false),
            const Divider(height: 18),
            _row('총 소비', formatWon(expense), palette.expense.fg, true),
            _row('주식계좌 저축', formatWon(transfer), palette.savings.fg, true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color? color, bool big) => Padding(
        padding: EdgeInsets.symmetric(vertical: big ? 3 : 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: big ? 14 : 13,
                    fontWeight: big ? FontWeight.w600 : FontWeight.normal,
                    color: big ? null : Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value,
                style: TextStyle(
                    fontSize: big ? 15 : 13,
                    fontWeight: big ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: big ? -0.4 : 0,
                    color: color)),
          ],
        ),
      );
}

class _YearSummaryCard extends StatefulWidget {
  final Map<int, Map<String, int>> byYear;
  const _YearSummaryCard({required this.byYear});

  @override
  State<_YearSummaryCard> createState() => _YearSummaryCardState();
}

class _YearSummaryCardState extends State<_YearSummaryCard> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final years = widget.byYear.keys.toList()..sort();
    if (years.isEmpty) {
      return const _MutedCard(text: '아직 올해 데이터가 없어요.');
    }
    if (!widget.byYear.containsKey(_year)) _year = years.last;
    final d = widget.byYear[_year]!;
    final palette = appPalette(context);
    final regular = d['regular'] ?? 0;
    final special = d['special'] ?? 0;
    final bonus = d['bonus'] ?? 0;
    final interest = d['interest'] ?? 0;
    final quiz = d['quiz'] ?? 0;
    final expense = d['expense'] ?? 0;
    final transfer = d['transfer'] ?? 0;
    final income = regular + special + bonus + interest + quiz;
    final saved = transfer; // 주식계좌로 보낸 저축액

    final idx = years.indexOf(_year);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: idx > 0 ? () => setState(() => _year = years[idx - 1]) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$_year년',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed:
                      idx < years.length - 1 ? () => setState(() => _year = years[idx + 1]) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _bigRow(context, '총 수입', formatWon(income), palette.income.fg),
            const Divider(height: 18),
            _sub(context, '정기 용돈', formatWon(regular)),
            _sub(context, '특별 수입', formatWon(special)),
            if (bonus > 0) _sub(context, '절약 보너스', formatWon(bonus)),
            if (interest > 0) _sub(context, '저축 이자', formatWon(interest)),
            if (quiz > 0) _sub(context, '퀴즈 보상', formatWon(quiz)),
            const Divider(height: 18),
            _bigRow(context, '총 소비', formatWon(expense), palette.expense.fg),
            _bigRow(context, '주식계좌 저축', formatWon(saved), palette.savings.fg),
          ],
        ),
      ),
    );
  }

  Widget _bigRow(BuildContext context, String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w800, letterSpacing: -0.4, color: color, fontSize: 15)),
          ],
        ),
      );

  Widget _sub(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );
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

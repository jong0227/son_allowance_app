import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

enum _Range { all, thisYear, thisMonth, last3Months }

final _rangeProvider = StateProvider.autoDispose<_Range>((ref) => _Range.all);

/// 정기 용돈 지급 이력 화면.
/// - "받은 정기용돈"은 실제 정기용돈 수입 내역(거래) 기준이라, 일정 기록이 없던
///   과거 지급분까지 전부 보인다.
/// - 아직 안 준 일정(밀린/예정)은 이 화면에서 바로 "지급"할 수 있다.
class AllowanceHistoryScreen extends ConsumerWidget {
  final Child child;
  const AllowanceHistoryScreen({super.key, required this.child});

  bool _inRange(DateTime d, _Range r) {
    final now = DateTime.now();
    switch (r) {
      case _Range.all:
        return true;
      case _Range.thisYear:
        return d.year == now.year;
      case _Range.thisMonth:
        return d.year == now.year && d.month == now.month;
      case _Range.last3Months:
        final from = DateTime(now.year, now.month - 2, 1);
        return !d.isBefore(from);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider(child.id));
    final txsAsync = ref.watch(transactionsProvider(child.id));
    final range = ref.watch(_rangeProvider);
    final isChild = ref.watch(settingsProvider).isChild;
    final palette = appPalette(context);

    return Scaffold(
      appBar: AppBar(title: const Text('정기 용돈 지급 이력')),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (schedules) {
          final txs = txsAsync.valueOrNull ?? const [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // 예정일 조회용: scheduleId -> scheduledDate
          final schedById = {for (final s in schedules) s.id: s};

          // 실제 받은 정기용돈 = 정기용돈 카테고리 수입 내역 (일정 유무와 무관하게 전부)
          final received = txs
              .where((t) => t.flow == 'income' && t.category == AppDatabase.kRegularAllowance)
              .where((t) => _inRange(t.date, range))
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final totalReceived = received.fold<int>(0, (a, b) => a + b.amount);

          // 아직 안 준 일정(밀린 + 예정)은 기간 필터와 무관하게 항상 보여 지급 가능하게 함
          final unpaid = schedules.where((s) => !s.isPaid).toList()
            ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // 기간 선택 칩
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final e in const [
                      (_Range.all, '전체'),
                      (_Range.thisMonth, '이번 달'),
                      (_Range.last3Months, '최근 3개월'),
                      (_Range.thisYear, '올해'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(e.$2),
                          selected: range == e.$1,
                          onSelected: (_) => ref.read(_rangeProvider.notifier).state = e.$1,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 요약 카드
              Card(
                color: palette.allowance.bg,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이 기간 받은 정기용돈',
                          style: TextStyle(
                              fontSize: 13, color: palette.allowance.fg.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text(formatWon(totalReceived),
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: palette.allowance.fg)),
                      const SizedBox(height: 8),
                      Text('받은 횟수 ${received.length}회 · 안 준 용돈 ${unpaid.length}건',
                          style: TextStyle(
                              fontSize: 13, color: palette.allowance.fg.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 아직 안 준 용돈 — 여기서 바로 지급 (부모만)
              if (unpaid.isNotEmpty && !isChild) ...[
                const SectionHeader('아직 안 준 용돈'),
                for (final s in unpaid)
                  _UnpaidRow(
                    schedule: s,
                    palette: palette,
                    overdue: DateTime(s.scheduledDate.year, s.scheduledDate.month,
                            s.scheduledDate.day)
                        .isBefore(today),
                    onPay: () async {
                      final owner = ref.read(settingsProvider).deviceOwner ?? '';
                      await ref.read(databaseProvider).markSchedulePaid(s, owner, child);
                    },
                  ),
                const SizedBox(height: 8),
              ],

              // 받은 정기용돈 이력 (과거 전부)
              SectionHeader('받은 정기용돈 이력 ${received.length}건'),
              if (received.isEmpty)
                const _Muted('이 기간에 받은 정기용돈이 없어요.')
              else
                for (final t in received)
                  _ReceivedRow(
                    tx: t,
                    palette: palette,
                    scheduledDate: t.linkedScheduleId != null
                        ? schedById[t.linkedScheduleId!]?.scheduledDate
                        : null,
                  ),
            ],
          );
        },
      ),
    );
  }
}

/// 아직 안 준 일정 한 줄 + 지급 버튼.
class _UnpaidRow extends StatelessWidget {
  final AllowanceSchedule schedule;
  final AppPalette palette;
  final bool overdue;
  final Future<void> Function() onPay;
  const _UnpaidRow({
    required this.schedule,
    required this.palette,
    required this.overdue,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final s = schedule;
    final pair = overdue ? palette.expense : palette.allowance;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 4, 10, 4),
        leading: CircleAvatar(
            backgroundColor: pair.bg,
            child: Icon(overdue ? Icons.history : Icons.schedule, color: pair.fg)),
        title: Text('${formatDate(s.scheduledDate)} (${weekdayName(s.scheduledDate.weekday)})',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(overdue ? '밀린 용돈 · ${formatWon(s.amount)}' : '지급 예정 · ${formatWon(s.amount)}'),
        trailing: FilledButton(onPressed: onPay, child: const Text('지급')),
      ),
    );
  }
}

/// 실제 받은 정기용돈 한 줄. 예정일(있으면)과 실제 받은 날을 함께 표시.
class _ReceivedRow extends StatelessWidget {
  final TransactionEntry tx;
  final AppPalette palette;
  final DateTime? scheduledDate;
  const _ReceivedRow({required this.tx, required this.palette, this.scheduledDate});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pair = palette.income;
    final sameDay = scheduledDate != null &&
        scheduledDate!.year == tx.date.year &&
        scheduledDate!.month == tx.date.month &&
        scheduledDate!.day == tx.date.day;
    final sub = scheduledDate == null
        ? '받은 날: ${formatDate(tx.date)}'
        : (sameDay
            ? '예정일에 지급 · ${formatDate(tx.date)}'
            : '예정일 ${formatDateShort(scheduledDate!)} → 실제 ${formatDateShort(tx.date)}');
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(backgroundColor: pair.bg, child: Icon(Icons.check_circle, color: pair.fg)),
        title: Text(formatWon(tx.amount),
            style: TextStyle(fontWeight: FontWeight.w800, color: pair.fg, letterSpacing: -0.3)),
        subtitle: Text(sub, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
      ),
    );
  }
}

class _Muted extends StatelessWidget {
  final String text;
  const _Muted(this.text);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

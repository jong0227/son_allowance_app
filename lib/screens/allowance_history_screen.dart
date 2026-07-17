import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

enum _Range { all, thisYear, thisMonth, last3Months }

final _rangeProvider = StateProvider.autoDispose<_Range>((ref) => _Range.all);

/// 정기 용돈 지급 이력 화면.
/// 정규 지급일마다 실제로 지급됐는지/안 됐는지, 기간별 총 지급액을 보여준다.
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
    final range = ref.watch(_rangeProvider);
    final palette = appPalette(context);

    return Scaffold(
      appBar: AppBar(title: const Text('정기 용돈 지급 이력')),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (all) {
          // 지급 이력은 "정규 지급일"이 기준이므로 scheduledDate로 필터/정렬.
          final filtered = all.where((s) => _inRange(s.scheduledDate, range)).toList()
            ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
          final paid = filtered.where((s) => s.isPaid).toList();
          final unpaid = filtered.where((s) => !s.isPaid).toList();
          final totalPaid = paid.fold<int>(0, (a, b) => a + b.amount);
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

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
                          onSelected: (_) =>
                              ref.read(_rangeProvider.notifier).state = e.$1,
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
                      Text('이 기간 지급 합계',
                          style: TextStyle(
                              fontSize: 13, color: palette.allowance.fg.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text(formatWon(totalPaid),
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: palette.allowance.fg)),
                      const SizedBox(height: 8),
                      Text('지급 완료 ${paid.length}회 · 미지급 ${unpaid.length}회',
                          style: TextStyle(
                              fontSize: 13, color: palette.allowance.fg.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SectionHeader('지급일별 상세'),
              if (filtered.isEmpty)
                const _Muted('이 기간에는 지급 일정이 없어요.')
              else
                for (final s in filtered)
                  _PaymentRow(
                    schedule: s,
                    palette: palette,
                    isFutureUnpaid: !s.isPaid &&
                        !DateTime(s.scheduledDate.year, s.scheduledDate.month,
                                s.scheduledDate.day)
                            .isBefore(today),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final AllowanceSchedule schedule;
  final AppPalette palette;
  final bool isFutureUnpaid;
  const _PaymentRow({
    required this.schedule,
    required this.palette,
    required this.isFutureUnpaid,
  });

  @override
  Widget build(BuildContext context) {
    final s = schedule;
    // 상태: 지급완료 / 지급예정(오늘 이후) / 미지급(지났는데 안 줌)
    final PastelPair pair;
    final IconData icon;
    final String status;
    if (s.isPaid) {
      pair = palette.income;
      icon = Icons.check_circle;
      status = s.paidDate != null ? '지급 완료 · ${formatDateShort(s.paidDate!)} 지급' : '지급 완료';
    } else if (isFutureUnpaid) {
      pair = palette.allowance;
      icon = Icons.schedule;
      status = '지급 예정';
    } else {
      pair = palette.expense;
      icon = Icons.cancel_outlined;
      status = '미지급';
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(backgroundColor: pair.bg, child: Icon(icon, color: pair.fg)),
        title: Text('${formatDate(s.scheduledDate)} 예정',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(status),
        trailing: Text(formatWon(s.amount),
            style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: s.isPaid ? pair.fg : Theme.of(context).colorScheme.onSurfaceVariant)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/allowance_history_screen.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'ui_kit.dart';

/// 홈의 "이번 주 용돈" 카드. 절약보너스·이자 카드와 같은 형태로 맞춰,
/// 홈 상단에 따로 섹션을 두지 않고 카드 묶음 안에서 함께 흐르게 한다.
///
/// - 오늘이 지급일인데 아직 안 줬으면: 큰 카드 + 지급 버튼(부모만).
/// - 이미 지급했으면: 작은 한 줄로 접히고, 누르면 펼쳐진다.
/// - 밀린 용돈(지난 미지급)이 있으면 접힌 줄에도 건수를 알려주고,
///   펼치면 날짜까지 보여준다.
///
/// 지급 "취소" 버튼은 두지 않는다. 홈에 있으면 실수로 누르기 쉬워서,
/// 되돌릴 일이 있으면 내역 탭에서 그 내역을 삭제하게 했다
/// (내역 삭제 = 지급 취소. deleteTransaction이 일정까지 되돌린다).
class AllowanceHomeCard extends ConsumerStatefulWidget {
  final Child child;
  final bool isChild;
  const AllowanceHomeCard({super.key, required this.child, required this.isChild});

  @override
  ConsumerState<AllowanceHomeCard> createState() => _AllowanceHomeCardState();
}

class _AllowanceHomeCardState extends ConsumerState<AllowanceHomeCard> {
  bool _open = false;

  Child get child => widget.child;
  bool get isChild => widget.isChild;

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(schedulesProvider(child.id)).valueOrNull;
    if (schedules == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

    // 밀린 용돈: 지급일이 지났는데 아직 안 준 일정. 오래된 것부터.
    final overdue =
        schedules.where((s) => !s.isPaid && dayOf(s.scheduledDate).isBefore(today)).toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final overdueSum = overdue.fold<int>(0, (a, b) => a + b.amount);

    // 오늘이 지급일인 미지급만 "지금 줄 수 있는 것"으로 본다. 지급일 전날부터
    // 다음 주 예정이 미리 만들어져 있어도 그 주가 되기 전엔 지급 버튼을 안 띄운다.
    final dueToday =
        schedules.where((s) => !s.isPaid && dayOf(s.scheduledDate) == today).toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    final recentPaid = schedules
        .where((s) => s.isPaid && s.scheduledDate.difference(now).inDays.abs() <= 7)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

    final s = dueToday.isNotEmpty
        ? dueToday.first
        : (recentPaid.isNotEmpty ? recentPaid.first : null);

    // 이번 주 것도 밀린 것도 없으면 카드를 숨긴다(다른 홈 카드와 같은 규칙).
    if (s == null && overdue.isEmpty) return const SizedBox.shrink();

    final palette = appPalette(context);
    final paid = s != null && s.isPaid;

    // 지급 완료 + 접힘: 한 줄 미니바. 밀린 게 있으면 건수를 함께 알려준다.
    if (paid && !_open) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: MiniBar(
          pair: palette.income,
          text: overdue.isEmpty
              ? '이번 주 용돈 ${formatWon(s.amount)} 받음'
              : '이번 주 용돈 ${formatWon(s.amount)} 받음 · 밀린 용돈 ${overdue.length}건',
          onTap: () => setState(() => _open = true),
        ),
      );
    }

    late final PastelPair pair;
    late final IconData icon;
    late final String title;
    late final String sub;
    Widget? trailing;

    if (paid) {
      pair = palette.income;
      icon = Icons.check_circle;
      title = '이번 주 용돈 받음';
      sub = '${formatDate(s.scheduledDate)} · ${formatWon(s.amount)} 지급 완료';
      trailing = InkWell(
        onTap: () => setState(() => _open = false),
        child: Icon(Icons.expand_less, color: pair.fg.withValues(alpha: 0.8), size: 20),
      );
    } else if (s != null) {
      pair = palette.allowance;
      icon = Icons.schedule;
      title = isChild ? '오늘은 용돈 받는 날' : '이번 주 용돈 지급일';
      sub = '${formatDate(s.scheduledDate)} · ${formatWon(s.amount)} 지급 예정';
      if (!isChild) {
        trailing = FilledButton(onPressed: () => _pay(s), child: const Text('지급'));
      }
    } else {
      pair = palette.expense;
      icon = Icons.history;
      title = '밀린 용돈 ${overdue.length}건';
      sub = '아직 지급하지 않은 용돈이 있어요.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(AppGap.lg),
        decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: pair.fg, size: 22),
                const SizedBox(width: AppGap.sm),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: pair.fg, fontWeight: FontWeight.w800, fontSize: AppText.title)),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: AppGap.sm),
            Text(sub, style: TextStyle(color: pair.fg, fontSize: AppText.body, height: 1.5)),
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: AppGap.cozy),
              _OverdueBlock(overdue: overdue, sum: overdueSum, pair: pair),
            ],
            const SizedBox(height: AppGap.cozy),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _openHistory(context),
                child: Text('용돈 이력 보기',
                    style: TextStyle(
                        color: pair.fg,
                        fontSize: AppText.caption,
                        decoration: TextDecoration.underline)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay(AllowanceSchedule s) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).markSchedulePaid(s, owner, child);
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AllowanceHistoryScreen(child: child)),
    );
  }
}

/// 카드 안에 덧붙는 밀린 용돈 요약. 실제 지급/건너뛰기는 내역 탭에서 한다.
class _OverdueBlock extends StatelessWidget {
  final List<AllowanceSchedule> overdue;
  final int sum;
  final PastelPair pair;

  const _OverdueBlock({required this.overdue, required this.sum, required this.pair});

  @override
  Widget build(BuildContext context) {
    final dates = overdue.map((o) => formatDateShort(o.scheduledDate)).join(', ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: pair.fg.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 16, color: pair.fg),
              const SizedBox(width: AppGap.snug),
              Expanded(
                child: Text('밀린 용돈 ${overdue.length}건 · ${formatWon(sum)}',
                    style: TextStyle(
                        color: pair.fg, fontSize: AppText.label, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppGap.xs),
          Text(dates,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: pair.fg.withValues(alpha: 0.85), fontSize: AppText.caption)),
          Text('내역 탭에서 지급하거나 건너뛸 수 있어요',
              style: TextStyle(color: pair.fg.withValues(alpha: 0.85), fontSize: AppText.caption)),
        ],
      ),
    );
  }
}

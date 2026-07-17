import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

enum _Filter { all, income, expense }

enum _Period { all, thisMonth, lastMonth, thisYear }

final _filterProvider = StateProvider<_Filter>((ref) => _Filter.all);
final _periodProvider = StateProvider<_Period>((ref) => _Period.all);
final _queryProvider = StateProvider<String>((ref) => '');

bool _inPeriod(DateTime d, _Period p) {
  final now = DateTime.now();
  switch (p) {
    case _Period.all:
      return true;
    case _Period.thisMonth:
      return d.year == now.year && d.month == now.month;
    case _Period.lastMonth:
      final lm = DateTime(now.year, now.month - 1, 1);
      return d.year == lm.year && d.month == lm.month;
    case _Period.thisYear:
      return d.year == now.year;
  }
}

/// 용돈일정 + 사용내역을 합친 통합 장부 화면.
class LedgerScreen extends ConsumerStatefulWidget {
  final Child child;
  const LedgerScreen({super.key, required this.child});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncSchedule();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LedgerScreen old) {
    super.didUpdateWidget(old);
    // 지급요일/기본금액이 바뀌면 예정 일정을 다시 맞춘다.
    if (old.child.payDayOfWeek != widget.child.payDayOfWeek ||
        old.child.weeklyAllowanceDefault != widget.child.weeklyAllowanceDefault) {
      _syncSchedule();
    }
  }

  void _syncSchedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final owner = ref.read(settingsProvider).deviceOwner ?? '';
      ref.read(databaseProvider).ensureUpcomingSchedule(widget.child, owner);
    });
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider(widget.child.id));
    final txsAsync = ref.watch(transactionsProvider(widget.child.id));
    final filter = ref.watch(_filterProvider);
    final period = ref.watch(_periodProvider);
    final query = ref.watch(_queryProvider).trim();
    final palette = appPalette(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // 밀린 용돈(지난 미지급) + 지급할 용돈(예정)
          schedulesAsync.maybeWhen(
            orElse: () => const SizedBox.shrink(),
            data: (schedules) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              bool isOverdue(AllowanceSchedule s) => DateTime(s.scheduledDate.year,
                      s.scheduledDate.month, s.scheduledDate.day)
                  .isBefore(today);
              final pending = schedules.where((s) => !s.isPaid).toList()
                ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
              final overdue = pending.where(isOverdue).toList();
              final upcoming = pending.where((s) => !isOverdue(s)).toList();
              if (pending.isEmpty) return const SizedBox.shrink();
              final overdueSum = overdue.fold<int>(0, (a, b) => a + b.amount);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (overdue.isNotEmpty) ...[
                    SectionHeader(
                      '밀린 용돈 ${overdue.length}건 · ${formatWon(overdueSum)}',
                      trailing: overdue.length >= 2
                          ? TextButton(
                              onPressed: () => _payAllOverdue(overdue),
                              child: const Text('모두 지급'),
                            )
                          : null,
                    ),
                    for (final s in overdue)
                      _PendingScheduleCard(
                        s: s,
                        overdue: true,
                        onPay: () => _payNow(s),
                        onEditAmount: () => _editAmount(s),
                        onSkip: () => _confirmSkip(s),
                      ),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    const SectionHeader('지급할 용돈'),
                    for (final s in upcoming)
                      _PendingScheduleCard(
                        s: s,
                        overdue: false,
                        onPay: () => _payNow(s),
                        onEditAmount: () => _editAmount(s),
                      ),
                  ],
                ],
              );
            },
          ),
          const SectionHeader('전체 내역'),
          // 검색창
          TextField(
            controller: _searchController,
            onChanged: (v) => ref.read(_queryProvider.notifier).state = v,
            decoration: InputDecoration(
              hintText: '카테고리·메모·받은사람 검색',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(_queryProvider.notifier).state = '';
                      },
                    ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          // 기간 칩
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final e in const [
                  (_Period.all, '전체 기간'),
                  (_Period.thisMonth, '이번 달'),
                  (_Period.lastMonth, '지난 달'),
                  (_Period.thisYear, '올해'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(e.$2),
                      selected: period == e.$1,
                      onSelected: (_) => ref.read(_periodProvider.notifier).state = e.$1,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SegmentedButton<_Filter>(
              segments: const [
                ButtonSegment(value: _Filter.all, label: Text('전체')),
                ButtonSegment(value: _Filter.income, label: Text('수입')),
                ButtonSegment(value: _Filter.expense, label: Text('지출')),
              ],
              selected: {filter},
              showSelectedIcon: false,
              onSelectionChanged: (s) => ref.read(_filterProvider.notifier).state = s.first,
            ),
          ),
          const SizedBox(height: 6),
          txsAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('오류: $e'),
            data: (txs) {
              var filtered = switch (filter) {
                _Filter.all => txs,
                _Filter.income => txs.where((t) => t.flow == 'income').toList(),
                _Filter.expense => txs.where((t) => t.flow == 'expense').toList(),
              };
              filtered = filtered.where((t) => _inPeriod(t.date, period)).toList();
              if (query.isNotEmpty) {
                filtered = filtered
                    .where((t) =>
                        t.category.contains(query) ||
                        (t.memo?.contains(query) ?? false) ||
                        (t.giver?.contains(query) ?? false))
                    .toList();
              }
              if (filtered.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                        (query.isNotEmpty || period != _Period.all)
                            ? '조건에 맞는 내역이 없어요.'
                            : '내역이 없어요. 오른쪽 아래 + 버튼으로 추가해보세요.',
                        style: TextStyle(color: palette.savings.fg.withValues(alpha: 0.8))),
                  ),
                );
              }
              final incomeSum = filtered
                  .where((t) => t.flow == 'income')
                  .fold<int>(0, (a, b) => a + b.amount);
              final expenseSum = filtered
                  .where((t) => t.flow == 'expense')
                  .fold<int>(0, (a, b) => a + b.amount);
              return Column(
                children: [
                  _FilterSummary(
                      count: filtered.length, income: incomeSum, expense: expenseSum),
                  for (final t in filtered) _LedgerTxRow(t: t, onTap: () => _openEdit(t)),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('추가'),
      ),
    );
  }

  // ---------- 지급 ----------
  Future<void> _payNow(AllowanceSchedule s) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).markSchedulePaid(s, owner, widget.child);
  }

  // 밀린 용돈 한꺼번에 지급
  Future<void> _payAllOverdue(List<AllowanceSchedule> overdue) async {
    final sum = overdue.fold<int>(0, (a, b) => a + b.amount);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('밀린 용돈 모두 지급'),
        content: Text('${overdue.length}건, 총 ${formatWon(sum)}을 지급 처리할까요?\n'
            '각 주의 내역이 오늘 날짜로 기록됩니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true), child: const Text('모두 지급')),
        ],
      ),
    );
    if (ok != true) return;
    final db = ref.read(databaseProvider);
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    for (final s in overdue) {
      await db.markSchedulePaid(s, owner, widget.child);
    }
  }

  // 밀린 용돈 건너뛰기 (그 주는 안 준 것으로 확정)
  Future<void> _confirmSkip(AllowanceSchedule s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 주 용돈 건너뛰기'),
        content: Text('${formatDate(s.scheduledDate)} 용돈 ${formatWon(s.amount)}을 '
            '주지 않은 것으로 확정하고 목록에서 지웁니다.\n나중에 다시 생기지 않아요.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true), child: const Text('건너뛰기')),
        ],
      ),
    );
    if (ok != true) return;
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    await ref.read(databaseProvider).skipSchedule(s, owner);
  }

  // 특정 주의 용돈 금액만 수정 (기본 금액과 별개)
  void _editAmount(AllowanceSchedule s) {
    final controller = TextEditingController(text: '${s.amount}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${formatDate(s.scheduledDate)} 용돈 금액'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: '금액(원)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final amount = int.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              final owner = ref.read(settingsProvider).deviceOwner ?? '';
              await ref.read(databaseProvider).updateScheduleAmount(s.id, amount, owner);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // ---------- 추가/수정 시트 ----------
  void _showAddSheet() {
    final palette = appPalette(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: palette.expense.bg,
                  child: Icon(Icons.remove_rounded, color: palette.expense.fg)),
              title: const Text('사용 내역 추가'),
              subtitle: const Text('간식, 문구 등 지출'),
              onTap: () {
                Navigator.pop(context);
                _showExpenseSheet();
              },
            ),
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: palette.special.bg,
                  child: Icon(Icons.card_giftcard, color: palette.special.fg)),
              title: const Text('특별 용돈 추가'),
              subtitle: const Text('설날, 생일 등 받은 용돈'),
              onTap: () {
                Navigator.pop(context);
                _showSpecialIncomeSheet();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showExpenseSheet() {
    _showEntrySheet(
      flow: 'expense',
      categories: ref.read(settingsProvider).expenseCategories,
    );
  }

  void _showSpecialIncomeSheet() {
    final settings = ref.read(settingsProvider);
    _showEntrySheet(
      flow: 'income',
      categories: settings.incomeCategories,
      givers: [...settings.givers, '기타'],
    );
  }

  // 기존 내역을 탭하면 열리는 수정 시트
  void _openEdit(TransactionEntry t) {
    final settings = ref.read(settingsProvider);
    final isIncome = t.flow == 'income';
    final base = isIncome ? settings.incomeCategories : settings.expenseCategories;
    // 현재 카테고리(정기용돈/절약보너스 등 목록에 없는 것 포함)를 선택지에 넣어준다.
    final cats = base.contains(t.category) ? base : [t.category, ...base];
    _showEntrySheet(
      flow: t.flow,
      categories: cats,
      givers: isIncome ? [...settings.givers, '기타'] : null,
      existing: t,
    );
  }

  void _showEntrySheet({
    required String flow,
    required List<String> categories,
    List<String>? givers,
    TransactionEntry? existing,
  }) {
    final isEdit = existing != null;
    final title =
        isEdit ? '내역 수정' : (flow == 'income' ? '특별 용돈 추가' : '사용 내역 추가');
    final withGiver = givers != null;
    final giverOptions = givers ?? const <String>[];
    final amountController =
        TextEditingController(text: isEdit ? '${existing.amount}' : '');
    final memoController = TextEditingController(text: existing?.memo ?? '');
    final customGiverController = TextEditingController();
    String category =
        (isEdit && categories.contains(existing.category)) ? existing.category : categories.first;
    String giver;
    if (withGiver) {
      final eg = existing?.giver;
      if (eg != null && eg.isNotEmpty) {
        if (giverOptions.contains(eg)) {
          giver = eg;
        } else {
          giver = '기타';
          customGiverController.text = eg;
        }
      } else {
        giver = giverOptions.isNotEmpty ? giverOptions.first : '';
      }
    } else {
      giver = '';
    }
    DateTime date = existing?.date ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setState) {
            final palette = appPalette(context);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 20),
                    _FieldLabel(flow == 'income' ? '종류' : '카테고리'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          _SelectChip(
                            label: c,
                            selected: category == c,
                            pair: palette.tagFor(c),
                            onTap: () => setState(() => category = c),
                          ),
                      ],
                    ),
                    if (withGiver) ...[
                      const SizedBox(height: 18),
                      _FieldLabel('누가 줬어요?'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final g in giverOptions)
                            _SelectChip(
                              label: g,
                              selected: giver == g,
                              pair: palette.special,
                              onTap: () => setState(() => giver = g),
                            ),
                        ],
                      ),
                      if (giver == '기타') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: customGiverController,
                          decoration: const InputDecoration(labelText: '직접 입력'),
                        ),
                      ],
                    ],
                    const SizedBox(height: 18),
                    _FieldLabel('금액'),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                      decoration: const InputDecoration(
                        hintText: '0',
                        suffixText: '원',
                        suffixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldLabel('날짜'),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Text(formatDate(date),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FieldLabel('메모 (선택)'),
                    TextField(
                      controller: memoController,
                      decoration: const InputDecoration(hintText: '예: 학교 앞 문방구'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final amount = int.tryParse(amountController.text);
                          if (amount == null || amount <= 0) return;
                          final resolvedGiverRaw = !withGiver
                              ? null
                              : (giver == '기타'
                                  ? customGiverController.text.trim()
                                  : giver);
                          final resolvedGiver =
                              (resolvedGiverRaw == null || resolvedGiverRaw.isEmpty)
                                  ? null
                                  : resolvedGiverRaw;
                          final db = ref.read(databaseProvider);
                          final owner = ref.read(settingsProvider).deviceOwner ?? '';
                          if (isEdit) {
                            await db.updateTransactionFields(
                              existing.id,
                              date: date,
                              amount: amount,
                              category: category,
                              memo: memoController.text.trim(),
                              giver: resolvedGiver,
                              editedBy: owner,
                            );
                          } else {
                            await db.upsertTransaction(TransactionEntriesCompanion.insert(
                              id: const Uuid().v4(),
                              childId: widget.child.id,
                              date: date,
                              flow: flow,
                              category: category,
                              amount: amount,
                              memo: Value(memoController.text.trim()),
                              giver: Value(resolvedGiver),
                              editedBy: Value(owner),
                              updatedAt: Value(DateTime.now()),
                            ));
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(isEdit ? '수정 저장' : '저장'),
                        ),
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _confirmDeleteFromSheet(context, existing),
                          icon: Icon(Icons.delete_outline,
                              color: appPalette(context).expense.fg),
                          label: Text(
                              existing.linkedScheduleId != null ? '삭제 (지급 취소)' : '삭제',
                              style: TextStyle(color: appPalette(context).expense.fg)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteFromSheet(BuildContext sheetContext, TransactionEntry t) {
    final linked = t.linkedScheduleId != null;
    showDialog(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(linked ? '지급을 취소할까요?' : '삭제할까요?'),
        content: Text(linked
            ? '이 정기용돈 지급 내역을 삭제하면 해당 주 용돈이 다시 "미지급" 상태로 돌아갑니다.'
            : '${formatDate(t.date)} · ${t.category} · ${formatWon(t.amount)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final owner = ref.read(settingsProvider).deviceOwner ?? '';
              await ref.read(databaseProvider).deleteTransaction(t, owner, widget.child);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (sheetContext.mounted) Navigator.pop(sheetContext);
            },
            child: Text(linked ? '지급 취소' : '삭제'),
          ),
        ],
      ),
    );
  }
}

class _PendingScheduleCard extends StatelessWidget {
  final AllowanceSchedule s;
  final bool overdue;
  final VoidCallback onPay;
  final VoidCallback onEditAmount;
  final VoidCallback? onSkip;
  const _PendingScheduleCard(
      {required this.s,
      required this.overdue,
      required this.onPay,
      required this.onEditAmount,
      this.onSkip});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final pair = overdue ? palette.expense : palette.allowance;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        leading: CircleAvatar(
            backgroundColor: pair.bg,
            child: Icon(overdue ? Icons.history : Icons.schedule, color: pair.fg)),
        title: Text(formatWon(s.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle:
            Text('${formatDate(s.scheduledDate)} · ${overdue ? '밀린 용돈' : '지급 예정'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(onPressed: onPay, child: const Text('지급')),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) {
                if (v == 'edit') onEditAmount();
                if (v == 'skip') onSkip?.call();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('금액 수정')),
                if (onSkip != null)
                  const PopupMenuItem(value: 'skip', child: Text('건너뛰기 (안 준 것으로)')),
              ],
            ),
          ],
        ),
        onLongPress: onEditAmount,
      ),
    );
  }
}

class _LedgerTxRow extends StatelessWidget {
  final TransactionEntry t;
  final VoidCallback onTap;
  const _LedgerTxRow({required this.t, required this.onTap});

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
            Flexible(child: TagChip(label: t.category, pair: palette.tagFor(t.category))),
            const Spacer(),
            Text('${isIncome ? '+' : '-'}${formatWon(t.amount)}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isIncome ? palette.income.fg : palette.expense.fg)),
          ],
        ),
        subtitle: Padding(padding: const EdgeInsets.only(top: 3), child: Text(txSubtitle(t))),
        trailing: Icon(Icons.chevron_right,
            size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}

class _FilterSummary extends StatelessWidget {
  final int count;
  final int income;
  final int expense;
  const _FilterSummary({required this.count, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
      child: Row(
        children: [
          Text('$count건',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          const Spacer(),
          if (income > 0) ...[
            Text('수입 +${formatWon(income)}',
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: palette.income.fg)),
            const SizedBox(width: 10),
          ],
          if (expense > 0)
            Text('지출 -${formatWon(expense)}',
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: palette.expense.fg)),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9, left: 2),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final PastelPair pair;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label,
      required this.selected,
      required this.pair,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outline;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? pair.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: selected ? pair.fg.withValues(alpha: 0.5) : border),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
                color: selected
                    ? pair.fg
                    : Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

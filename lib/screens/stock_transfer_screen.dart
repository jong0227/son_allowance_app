import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';

class StockTransferScreen extends ConsumerWidget {
  final Child child;
  const StockTransferScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(stockTransfersProvider(child.id));
    final summaryAsync = ref.watch(summaryProvider(child.id));
    final isChild = ref.watch(settingsProvider).isChild;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          summaryAsync.when(
            data: (s) => Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${child.stockAccountLabel ?? '${child.name} 주식계좌'} 누적 이체액',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(formatWon(s['totalTransfer'] ?? 0),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('현재 잔액: ${formatWon(s['balance'] ?? 0)}'),
                  ],
                ),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('오류: $e'),
          ),
          const SizedBox(height: 16),
          const Text('이체 이력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          transfersAsync.when(
            data: (list) {
              if (list.isEmpty) return const Text('아직 이체 기록이 없습니다.');
              return Column(
                children: list
                    .map((t) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.savings),
                            title: Text(formatWon(t.amount)),
                            subtitle: Text(
                                '${formatDate(t.date)}${t.memo != null && t.memo!.isNotEmpty ? ' · ${t.memo}' : ''}'),
                          ),
                        ))
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('오류: $e'),
          ),
        ],
      ),
      // 주식계좌 이체 기록은 부모만 추가할 수 있다(자녀 모드에선 이력만 조회).
      floatingActionButton: isChild
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddTransferDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('이체 기록 추가'),
            ),
    );
  }

  void _showAddTransferDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final memoController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('주식계좌 이체 기록'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('실제 이체는 증권 앱에서 직접 진행한 뒤,\n완료된 내용을 여기에 기록해주세요.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('날짜: ${formatDate(selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '이체 금액(원)'),
              ),
              TextField(
                controller: memoController,
                decoration: const InputDecoration(labelText: '메모(선택)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final amount = int.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;
                final db = ref.read(databaseProvider);
                final owner = ref.read(settingsProvider).deviceOwner ?? '';
                await db.upsertStockTransfer(StockTransfersCompanion.insert(
                  id: const Uuid().v4(),
                  childId: child.id,
                  date: selectedDate,
                  amount: amount,
                  memo: Value(memoController.text.trim()),
                  editedBy: Value(owner),
                  updatedAt: Value(DateTime.now()),
                ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}

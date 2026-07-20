import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/stock_search_service.dart';
import '../utils/formatters.dart';
import '../widgets/market_index_strip.dart';
import '../widgets/stock_search.dart';
import '../widgets/ui_kit.dart';

class StockTransferScreen extends ConsumerWidget {
  final Child child;
  const StockTransferScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(stockTransfersProvider(child.id));
    final summaryAsync = ref.watch(summaryProvider(child.id));
    final requestsAsync = ref.watch(requestsProvider(child.id));
    final isChild = ref.watch(settingsProvider).isChild;
    final palette = appPalette(context);

    final pendingStock = (requestsAsync.valueOrNull ?? const [])
        .where((r) => r.type == 'stock' && r.status == 'pending')
        .toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MarketIndexStrip(),
          const SizedBox(height: 12),
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

          // 자녀: 주식 사달라고 요청하는 버튼
          if (isChild) ...[
            FilledButton.icon(
              onPressed: () => _showRequestStockDialog(context, ref),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('주식 사달라고 요청하기'),
            ),
            const SizedBox(height: 16),
          ],

          // 주식 매수 요청 (자녀: 내 요청 상태 / 부모: 승인+구매결과 입력)
          if (pendingStock.isNotEmpty) ...[
            Text(isChild ? '내 주식 요청' : '${child.name}의 주식 요청',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final r in pendingStock)
              Card(
                color: palette.special.bg,
                child: ListTile(
                  leading: Icon(Icons.request_quote, color: palette.special.fg),
                  title: Text('${r.title ?? ''} ${formatWon(r.amount)}어치',
                      style: TextStyle(fontWeight: FontWeight.w700, color: palette.special.fg)),
                  subtitle: Text(r.memo ?? '',
                      style: TextStyle(color: palette.special.fg.withValues(alpha: 0.85))),
                  trailing: isChild
                      ? TextButton(
                          onPressed: () =>
                              ref.read(databaseProvider).cancelRequest(r.id, '아들'),
                          child: const Text('취소'),
                        )
                      : FilledButton(
                          onPressed: () => _showFulfillDialog(context, ref, r),
                          child: const Text('구매 입력'),
                        ),
                ),
              ),
            const SizedBox(height: 16),
          ],

          const Text('이체 이력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          transfersAsync.when(
            data: (list) {
              if (list.isEmpty) return const Text('아직 이체 기록이 없습니다.');
              return Column(
                children: [
                  for (final t in list)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.savings),
                        title: Text(
                          t.companyName != null && t.companyName!.isNotEmpty
                              ? '${t.companyName} · ${formatWon(t.amount)}'
                              : formatWon(t.amount),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(_transferSubtitle(t)),
                      ),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('오류: $e'),
          ),
        ],
      ),
      // 주식계좌 이체 기록은 부모만 추가할 수 있다(자녀 모드에선 이력만 조회/요청).
      floatingActionButton: isChild
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddTransferDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('이체 기록 추가'),
            ),
    );
  }

  String _transferSubtitle(StockTransfer t) {
    final parts = <String>[formatDate(t.date)];
    if (t.shares != null) parts.add('${_trimShares(t.shares!)}주');
    if (t.ticker != null && t.ticker!.isNotEmpty) parts.add(t.ticker!);
    if (t.memo != null && t.memo!.isNotEmpty) parts.add(t.memo!);
    return parts.join(' · ');
  }

  String _trimShares(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  // ---------- 자녀: 주식 사달라고 요청 (현재가 기반) ----------
  Future<void> _showRequestStockDialog(BuildContext context, WidgetRef ref) async {
    final quote = await showStockSearch(context);
    if (quote == null || !context.mounted) return;
    final price = await _fetchPriceWithLoading(context, quote.symbol);
    if (!context.mounted) return;

    final amountController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final amount = int.tryParse(amountController.text) ?? 0;
          final krw = price?.krw;
          final approxShares = (krw != null && krw > 0) ? amount / krw : null;
          return AlertDialog(
            title: Text('${quote.name} 요청'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${quote.symbol}${quote.exchange.isNotEmpty ? ' · ${quote.exchange}' : ''}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  _priceLine(context, price),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: '얼마치 사달라고 할까요? (원)'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final add in const [10000, 50000, 100000])
                        ActionChip(
                          label: Text('+${add ~/ 10000}만'),
                          onPressed: () {
                            final cur = int.tryParse(amountController.text) ?? 0;
                            amountController.text = '${cur + add}';
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                  if (approxShares != null && amount > 0) ...[
                    const SizedBox(height: 10),
                    Text('이 금액이면 약 ${approxShares.toStringAsFixed(approxShares >= 10 ? 0 : 2)}주',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              FilledButton(
                onPressed: () async {
                  if (amount <= 0) return;
                  await ref
                      .read(databaseProvider)
                      .requestStock(child, quote.name, quote.symbol, amount, '아들');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('부모님께 요청했어요.')));
                  }
                },
                child: const Text('요청'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- 부모: 구매 결과 입력 후 승인 (현재가 기반) ----------
  Future<void> _showFulfillDialog(BuildContext context, WidgetRef ref, Request r) async {
    final ticker = r.memo ?? '';
    final price = ticker.isEmpty ? null : await _fetchPriceWithLoading(context, ticker);
    if (!context.mounted) return;

    final amountController = TextEditingController(text: '${r.amount}');
    final sharesController = TextEditingController();
    final memoController = TextEditingController();
    final krw = price?.krw;
    final maxShares = (krw != null && krw > 0) ? (r.amount / krw).floor() : null;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${r.title ?? '주식'} 구매 입력'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('요청: ${formatWon(r.amount)}어치 · $ticker',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                _priceLine(context, price),
                if (maxShares != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('요청 금액으로 최대 $maxShares주 살 수 있어요',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: sharesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) {
                    // 수량을 입력하면 현재가로 실제 금액 자동 계산
                    final sh = double.tryParse(v.trim());
                    if (sh != null && krw != null) {
                      amountController.text = '${(sh * krw).round()}';
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      labelText: '매수 수량(주)',
                      helperText: maxShares != null ? '탭: 최대 $maxShares주 채우기' : null),
                ),
                if (maxShares != null && maxShares > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        sharesController.text = '$maxShares';
                        if (krw != null) amountController.text = '${(maxShares * krw).round()}';
                        setState(() {});
                      },
                      child: Text('최대 $maxShares주'),
                    ),
                  ),
                const SizedBox(height: 4),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '실제 매수 금액(원)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: memoController,
                  decoration: const InputDecoration(labelText: '메모(선택)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final amount = int.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;
                final shares = double.tryParse(sharesController.text.trim());
                final owner = ref.read(settingsProvider).deviceOwner ?? '';
                await ref.read(databaseProvider).fulfillStockRequest(
                      r,
                      actualAmount: amount,
                      shares: shares,
                      memo: memoController.text.trim().isEmpty ? null : memoController.text.trim(),
                      resolvedBy: owner,
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('구매 내역을 기록했어요.')));
                }
              },
              child: const Text('구매 완료'),
            ),
          ],
        ),
      ),
    );
  }

  /// 현재가 조회(짧은 로딩 표시). 실패하면 null.
  Future<StockPrice?> _fetchPriceWithLoading(BuildContext context, String symbol) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    StockPrice? price;
    try {
      price = await const StockSearchService().quotePrice(symbol);
    } catch (_) {}
    if (context.mounted) Navigator.pop(context); // 로딩 닫기
    return price;
  }

  Widget _priceLine(BuildContext context, StockPrice? price) {
    if (price == null) {
      return Text('현재가를 불러오지 못했어요(수동 입력 가능)',
          style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant));
    }
    final native = price.currency == 'KRW'
        ? formatWon(price.native.round())
        : '${price.native.toStringAsFixed(2)} ${price.currency}';
    final krwPart =
        price.currency == 'KRW' ? '' : ' (≈ ${formatWon(price.krw.round())})';
    return Text('현재가 1주: $native$krwPart',
        style: const TextStyle(fontWeight: FontWeight.w700));
  }

  // ---------- 부모: 수동 이체 기록(종목 선택 가능) ----------
  void _showAddTransferDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final memoController = TextEditingController();
    final sharesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    StockQuote? picked;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('주식계좌 이체 기록'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('실제 이체/매수는 증권 앱에서 진행한 뒤, 완료된 내용을 여기에 기록해주세요.',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                // 종목 선택(선택 사항)
                OutlinedButton.icon(
                  onPressed: () async {
                    final q = await showStockSearch(context);
                    if (q != null) setState(() => picked = q);
                  },
                  icon: const Icon(Icons.search),
                  label: Text(picked == null ? '종목 선택 (선택)' : '${picked!.name} (${picked!.symbol})'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('날짜: ${formatDate(selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (p != null) setState(() => selectedDate = p);
                  },
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '이체/매수 금액(원)'),
                ),
                TextField(
                  controller: sharesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '수량(주) · 선택'),
                ),
                TextField(
                  controller: memoController,
                  decoration: const InputDecoration(labelText: '메모(선택)'),
                ),
              ],
            ),
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
                  ticker: Value(picked?.symbol),
                  companyName: Value(picked?.name),
                  shares: Value(double.tryParse(sharesController.text.trim())),
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final childrenListProvider = StreamProvider<List<Child>>((ref) {
  return ref.watch(databaseProvider).watchChildren();
});

/// 지금 화면에서 선택된 자녀 id. 자녀가 1명이면 자동으로 그 아이가 선택됨.
final selectedChildIdProvider = StateProvider<String?>((ref) => null);

final schedulesProvider = StreamProvider.family<List<AllowanceSchedule>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchSchedules(childId);
});

final transactionsProvider = StreamProvider.family<List<TransactionEntry>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchTransactions(childId);
});

final stockTransfersProvider = StreamProvider.family<List<StockTransfer>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchStockTransfers(childId);
});

final summaryProvider = FutureProvider.family<Map<String, int>, String>((ref, childId) async {
  // 거래/이체가 바뀔 때마다 재계산되도록 스트림들을 watch 한다.
  ref.watch(transactionsProvider(childId));
  ref.watch(stockTransfersProvider(childId));
  return ref.watch(databaseProvider).computeSummary(childId);
});

final expenseByCategoryProvider = FutureProvider.family<Map<String, int>, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  return ref.watch(databaseProvider).expenseByCategory(childId);
});

final monthlyStatsProvider =
    FutureProvider.family<Map<String, Map<String, int>>, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  return ref.watch(databaseProvider).monthlyIncomeExpense(childId);
});

final incomeByGiverProvider =
    FutureProvider.family<Map<String, int>, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  return ref.watch(databaseProvider).incomeByGiver(childId);
});

final bonusGivenThisWeekProvider =
    FutureProvider.family<bool, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  return ref.watch(databaseProvider).bonusGivenThisWeek(childId);
});

final goalsProvider = StreamProvider.family<List<Goal>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchGoals(childId);
});

final allowanceRatesProvider =
    StreamProvider.family<List<AllowanceRate>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchAllowanceRates(childId);
});

/// 자녀가 보낸 모든 요청(대기/승인/거절 포함).
final requestsProvider =
    StreamProvider.family<List<Request>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchRequests(childId);
});

/// 대기 중 요청만 (부모 홈 "요청함").
final pendingRequestsProvider =
    StreamProvider.family<List<Request>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchPendingRequests(childId);
});

/// 이번 주기 이자 지급 여부 (childId, period=0주간/1월간)
final interestGivenProvider =
    FutureProvider.family<bool, ({String childId, int period})>((ref, args) async {
  ref.watch(transactionsProvider(args.childId));
  return ref.watch(databaseProvider).interestGivenThisPeriod(args.childId, args.period);
});

final yearlyStatsProvider =
    FutureProvider.family<Map<int, Map<String, int>>, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  ref.watch(stockTransfersProvider(childId));
  return ref.watch(databaseProvider).yearlyBreakdown(childId);
});

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

/// 부모-자녀 약속 목록(삭제 안 된 것, 정렬됨).
final promisesProvider =
    StreamProvider.family<List<Promise>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchPromises(childId);
});

/// 켜진(ON) 약속들의 이자 보너스 합계 %. 약속 목록이 바뀌면 자동 재계산.
final promiseBonusProvider =
    FutureProvider.family<double, String>((ref, childId) async {
  final promises = await ref.watch(promisesProvider(childId).future);
  return promises
      .where((p) => p.enabled)
      .fold<double>(0, (sum, p) => sum + p.bonusPercent);
});

/// 한 약속의 댓글/상태기록 (오래된 것부터).
final promiseCommentsProvider =
    StreamProvider.family<List<PromiseComment>, String>((ref, promiseId) {
  return ref.watch(databaseProvider).watchPromiseComments(promiseId);
});

/// 자녀의 모든 약속 댓글 (홈 카드에서 약속별 개수 표시용).
final allPromiseCommentsProvider =
    StreamProvider.family<List<PromiseComment>, String>((ref, childId) {
  return ref.watch(databaseProvider).watchAllPromiseComments(childId);
});

/// 이번 주기 이자 지급 여부 (childId, period=0주간/1월간)
final interestGivenProvider =
    FutureProvider.family<bool, ({String childId, int period})>((ref, args) async {
  ref.watch(transactionsProvider(args.childId));
  return ref.watch(databaseProvider).interestGivenThisPeriod(args.childId, args.period);
});

/// 과거 정기용돈 "일괄" 한 건을 주 단위 지급 목록으로 복원.
/// key: (자녀 id, 일괄 시작일, 일괄 총액)
final pastAllowancePaymentsProvider = FutureProvider.family<List<PastAllowancePayment>,
    ({String childId, DateTime startDate, int amount})>((ref, args) async {
  final children = await ref.watch(childrenListProvider.future);
  Child? child;
  for (final c in children) {
    if (c.id == args.childId) {
      child = c;
      break;
    }
  }
  if (child == null) return const [];
  return ref
      .watch(databaseProvider)
      .expandPastAllowancePayments(child, args.startDate, args.amount);
});

final yearlyStatsProvider =
    FutureProvider.family<Map<int, Map<String, int>>, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  ref.watch(stockTransfersProvider(childId));
  return ref.watch(databaseProvider).yearlyBreakdown(childId);
});

/// 월별 항목별 집계 (key: 'YYYY-MM').
final monthlyBreakdownProvider =
    FutureProvider.family<Map<String, Map<String, int>>, String>((ref, childId) async {
  ref.watch(transactionsProvider(childId));
  ref.watch(stockTransfersProvider(childId));
  return ref.watch(databaseProvider).monthlyBreakdown(childId);
});

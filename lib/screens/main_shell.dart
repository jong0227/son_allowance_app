import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/tier_provider.dart';
import '../services/backup_service.dart';
import '../widgets/child_avatar.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/tier_widgets.dart';
import 'ledger_screen.dart';
import 'overview_screen.dart';
import 'settings_screen.dart';
import 'stock_transfer_screen.dart';

/// 현재 선택된 하단 탭. 다른 화면에서 특정 탭으로 이동시킬 때 사용.
final mainTabIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerStatefulWidget {
  final Child child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = ref.read(databaseProvider);
      final owner = ref.read(settingsProvider).deviceOwner ?? '';
      // 티어 기본값이 없으면 시드(첫 실행/신규 기기)
      await db.seedTiersIfEmpty();
      // 티어 기본값 버전이 올라갔으면 기존 티어를 새 기본값으로 재구성
      final prefs = ref.read(sharedPreferencesProvider);
      if ((prefs.getInt('tierSeedVersion') ?? 1) < AppDatabase.tierSeedVersion) {
        await db.reseedTiers();
        await prefs.setInt('tierSeedVersion', AppDatabase.tierSeedVersion);
      }
      // 앱 시작 시 중복 프로필 정리 + 데이터 있는 프로필 자동 선택(동기화 후 self-heal)
      final primary = await db.reconcileToSingleChild(owner);
      if (primary != null && primary != widget.child.id) {
        ref.read(selectedChildIdProvider.notifier).state = primary;
      }
      const BackupService().autoBackupIfNeeded(db, editedBy: owner);
      // 가족 동기화가 이미 설정되어 있으면 앱을 켤 때마다 조용히 재연결
      final code = ref.read(settingsProvider).familyCode;
      if (code != null) {
        try {
          await ref.read(familySyncServiceProvider).resume(code, owner);
        } catch (_) {
          // 오프라인 등으로 실패해도 앱 사용에는 지장 없음. 재시도는 다음 실행 때.
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(mainTabIndexProvider);
    final child = widget.child;
    // 상단 티어 배지: 누적 저축 티어 + 이번 주 저축률 티어
    final savings = ref.watch(summaryProvider(child.id)).valueOrNull?['totalSavings'] ?? 0;
    final savingsTiers = ref.watch(savingsTiersProvider).valueOrNull ?? const [];
    final savingsTier = tierFor(savingsTiers, savings).current;

    final weeklyTiers = ref.watch(weeklyTiersProvider).valueOrNull ?? const [];
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
    final weeklyTier = tierFor(weeklyTiers, savePct).current;

    return ResponsiveScaffold(
      titleWidget: Row(
        children: [
          ChildAvatar(child: child, size: 36),
          const SizedBox(width: 9),
          Flexible(
            child: Text('${child.name}의 용돈',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          ),
          if (savingsTier != null) ...[
            const SizedBox(width: 6),
            TierEasterEggTap(tier: savingsTier, child: TierBadge(tier: savingsTier)),
          ],
          if (weeklyTier != null) ...[
            const SizedBox(width: 4),
            TierEasterEggTap(tier: weeklyTier, child: TierBadge(tier: weeklyTier)),
          ],
        ],
      ),
      selectedIndex: index,
      onSelect: (i) => ref.read(mainTabIndexProvider.notifier).state = i,
      pages: [
        OverviewScreen(child: child),
        LedgerScreen(child: child),
        StockTransferScreen(child: child),
        SettingsScreen(child: child),
      ],
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: '홈'),
        NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: '내역'),
        NavigationDestination(
            icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: '주식이체'),
        NavigationDestination(
            icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '설정'),
      ],
    );
  }
}

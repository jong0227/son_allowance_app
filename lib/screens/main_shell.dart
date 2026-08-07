import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_database.dart';
import '../data/changelog.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/tier_provider.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../widgets/child_avatar.dart';
import '../widgets/release_notes_sheet.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/tier_widgets.dart';
import 'economy_screen.dart';
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
  /// 뒤로가기를 마지막으로 누른 시각. 2초 안에 한 번 더 눌러야 앱이 꺼진다.
  /// (주머니 속에서 실수로 눌러 앱이 바로 꺼지던 문제)
  DateTime? _lastBackAt;

  void _handleBack() {
    // 홈이 아니면 먼저 홈 탭으로 돌아간다(일반적인 안드로이드 동작).
    if (ref.read(mainTabIndexProvider) != 0) {
      ref.read(mainTabIndexProvider.notifier).state = 0;
      _lastBackAt = null;
      return;
    }
    final now = DateTime.now();
    final last = _lastBackAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      // 두 번째 뒤로가기 → 실제로 종료
      Navigator.of(context).maybePop();
      SystemNavigator.pop();
      return;
    }
    _lastBackAt = now;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(
        content: Text('한 번 더 누르면 앱이 꺼져요'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

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
      // '기타'로 들어가 있던 과거 지출 일괄을 전용 카테고리로 1회 이관
      if (!(prefs.getBool('pastExpenseReclassified') ?? false)) {
        await db.reclassifyPastExpense(owner);
        await prefs.setBool('pastExpenseReclassified', true);
      }
      // 이자율을 현실적인 수준(은행 = 배수 1, 약속 연 +0.3%p)으로 1회 정규화
      if (!(prefs.getBool('interestNormalizedV1') ?? false)) {
        await db.normalizeInterestRates(owner);
        await prefs.setBool('interestNormalizedV1', true);
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
      // 정기 용돈 예정 일정 확보. 앱을 켤 때마다 항상 최신 상태로 맞춘다.
      await db.ensureUpcomingSchedule(widget.child, owner);
      // 업데이트 후 처음 켠 것이면 "새로운 소식"을 한 번 띄운다.
      // (아들 폰엔 브라우저가 없어 GitHub 릴리즈 노트를 볼 수 없다)
      await _showReleaseNotesIfUpdated(prefs);
    });
  }

  /// 설치된 버전이 마지막으로 소식을 본 버전과 다르면 한 번만 띄운다.
  /// 첫 설치(기록 없음)일 때는 띄우지 않는다 — 처음 쓰는 아이에게 변경 이력은
  /// 의미가 없고, 온보딩 흐름만 방해한다.
  Future<void> _showReleaseNotesIfUpdated(SharedPreferences prefs) async {
    const key = 'lastSeenReleaseNotesVersion';
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final seen = prefs.getString(key);
      await prefs.setString(key, current);
      if (seen == null || seen == current) return;
      // 이번 버전의 소식이 실제로 있을 때만 띄운다.
      if (!kReleaseNotes.any((n) => n.version == current)) return;
      if (!mounted) return;
      showReleaseNotes(context, highlightVersion: current);
    } catch (_) {
      // 버전을 못 읽어도 앱 사용에는 지장 없다.
    }
  }

  @override
  void didUpdateWidget(covariant MainShell old) {
    super.didUpdateWidget(old);
    // _RootGate가 온보딩 직후의 임시 프로필 → 가족 동기화로 받아온 진짜 프로필로
    // child를 바꿔치기할 때, MainShell은 State가 재사용되어 initState가 다시
    // 실행되지 않는다(같은 위젯 트리 위치, key 없음). 그 결과 initState에서 한 번
    // 계산됐던 예정 일정이 "진짜" 프로필 기준으로는 한 번도 재계산되지 않는
    // 문제가 있었다. child가 바뀌면 여기서 다시 맞춰준다.
    if (old.child.id != widget.child.id) {
      final db = ref.read(databaseProvider);
      final owner = ref.read(settingsProvider).deviceOwner ?? '';
      db.ensureUpcomingSchedule(widget.child, owner);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(mainTabIndexProvider);
    final child = widget.child;
    // 상단 티어 배지: 누적 저축 티어(저축 점수 기준) + 이번 주 저축률 티어
    final tierScore = ref.watch(summaryProvider(child.id)).valueOrNull?['tierScore'] ?? 0;
    final savingsTiers = ref.watch(savingsTiersProvider).valueOrNull ?? const [];
    final savingsTier = tierFor(savingsTiers, tierScore).current;

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

    return PopScope(
      // 시스템 뒤로가기를 우리가 직접 처리한다(바로 종료 방지).
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: ResponsiveScaffold(
      titleWidget: Row(
        children: [
          ChildAvatar(child: child, size: 36),
          const SizedBox(width: AppGap.sm),
          Flexible(
            child: Text('${child.name}의 용돈',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          ),
          if (savingsTier != null) ...[
            const SizedBox(width: AppGap.snug),
            TierEasterEggTap(tier: savingsTier, child: TierBadge(tier: savingsTier)),
          ],
          if (weeklyTier != null) ...[
            const SizedBox(width: AppGap.xs),
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
        EconomyScreen(child: child),
        SettingsScreen(child: child),
      ],
      // 탭이 5개라 라벨을 짧게 유지한다(폴드/플립에서 잘리지 않도록).
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: '홈'),
        NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: '내역'),
        NavigationDestination(
            icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: '주식'),
        NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: '경제왕'),
        NavigationDestination(
            icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '설정'),
      ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import '../widgets/child_avatar.dart';
import '../widgets/responsive_scaffold.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const BackupService().autoBackupIfNeeded(
        ref.read(databaseProvider),
        editedBy: ref.read(settingsProvider).deviceOwner ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(mainTabIndexProvider);
    final child = widget.child;

    return ResponsiveScaffold(
      titleWidget: Row(
        children: [
          ChildAvatar(child: child, size: 36),
          const SizedBox(width: 11),
          Flexible(
            child: Text('${child.name}의 용돈',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4)),
          ),
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

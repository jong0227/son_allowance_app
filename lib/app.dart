import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/lock_screen.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

final _unlockedProvider = StateProvider<bool>((ref) => false);

class AllowanceApp extends ConsumerWidget {
  const AllowanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Allowance Manager',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: const _RootGate(),
    );
  }
}

class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider);
    final settings = ref.watch(settingsProvider);
    final unlocked = ref.watch(_unlockedProvider);

    return childrenAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('오류: $e'))),
      data: (children) {
        if (children.isEmpty || settings.deviceOwner == null) {
          return const OnboardingScreen();
        }

        if (settings.lockEnabled && !unlocked) {
          return LockScreen(onUnlocked: () => ref.read(_unlockedProvider.notifier).state = true);
        }

        final selectedId = ref.watch(selectedChildIdProvider);
        final child = children.firstWhere(
          (c) => c.id == selectedId,
          orElse: () => children.first,
        );
        if (selectedId != child.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedChildIdProvider.notifier).state = child.id;
          });
        }

        return MainShell(child: child);
      },
    );
  }
}

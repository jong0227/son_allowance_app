import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../services/export_import_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/child_avatar.dart';
import '../widgets/ui_kit.dart';

const _exportImportService = ExportImportService();

class SettingsScreen extends ConsumerWidget {
  final Child child;
  const SettingsScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // 프로필 헤더
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                ChildAvatar(child: child, size: 60),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                      const SizedBox(height: 2),
                      Text('기본 용돈 ${formatWon(child.weeklyAllowanceDefault)} · ${weekdayName(child.payDayOfWeek)}요일',
                          style: TextStyle(
                              fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditChildDialog(context, ref),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),

        const SectionHeader('카테고리 관리'),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _CategoryExpansion(
                title: '지출 카테고리',
                subtitle: '간식, 문구 등 사용 내역 종류',
                icon: Icons.shopping_bag_outlined,
                kind: 'expense',
                items: settings.expenseCategories,
                ref: ref,
              ),
              const Divider(height: 1),
              _CategoryExpansion(
                title: '수입 종류',
                subtitle: '설날, 생일 등 특별 용돈 종류',
                icon: Icons.card_giftcard,
                kind: 'income',
                items: settings.incomeCategories,
                ref: ref,
              ),
              const Divider(height: 1),
              _CategoryExpansion(
                title: '받은 사람',
                subtitle: '용돈을 준 사람 (엄마, 할머니 등)',
                icon: Icons.people_alt_outlined,
                kind: 'giver',
                items: settings.givers,
                ref: ref,
              ),
            ],
          ),
        ),

        const SectionHeader('절약 보너스 규칙'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('절약 보너스 사용'),
                subtitle: const Text('정해진 요일까지 목표 금액 이상 남기면 보너스 지급'),
                value: child.bonusEnabled,
                onChanged: (v) => ref.read(databaseProvider).upsertChild(ChildrenCompanion(
                      id: Value(child.id),
                      bonusEnabled: Value(v),
                      updatedAt: Value(DateTime.now()),
                    )),
              ),
              if (child.bonusEnabled)
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: Text(
                      '매주 ${weekdayName(child.bonusDayOfWeek)}요일까지 ${formatWon(child.bonusThreshold)} 유지 시'),
                  subtitle: Text('${formatWon(child.bonusAmount)} 추가 지급'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _showBonusDialog(context, ref),
                ),
            ],
          ),
        ),

        const SectionHeader('동기화 (가족과 공유)'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('내보내기 (Export)'),
                subtitle: Text(settings.lastExportedAt != null
                    ? '마지막 내보내기: ${formatDate(settings.lastExportedAt!)}'
                    : '아직 내보낸 적 없음'),
                onTap: () => _handleExport(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('가져오기 (Import)'),
                subtitle: Text(settings.lastImportedAt != null
                    ? '마지막 가져오기: ${formatDate(settings.lastImportedAt!)}'
                    : '아직 가져온 적 없음'),
                onTap: () => _handleImport(context, ref),
              ),
            ],
          ),
        ),

        const SectionHeader('알림'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('용돈 지급일 / 이체 권장 알림'),
                value: settings.notificationsEnabled,
                onChanged: (v) async {
                  await ref.read(settingsProvider.notifier).setNotificationsEnabled(v);
                  if (v) {
                    await NotificationService.instance.scheduleWeeklyAllowanceReminder(
                      childName: child.name,
                      isoWeekday: child.payDayOfWeek,
                    );
                  } else {
                    await NotificationService.instance.cancelAllowanceReminder();
                  }
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('주간 리포트 알림'),
                subtitle: const Text('매주 일요일 저녁, 이번 주 요약 리마인더'),
                value: settings.weeklyReportEnabled,
                onChanged: (v) async {
                  await ref.read(settingsProvider.notifier).setWeeklyReportEnabled(v);
                  if (v) {
                    await NotificationService.instance.scheduleWeeklyReport();
                  } else {
                    await NotificationService.instance.cancelWeeklyReport();
                  }
                },
              ),
            ],
          ),
        ),

        const SectionHeader('용돈 변경 이력'),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('기본 용돈 변경 이력 보기'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRateHistory(context, ref),
          ),
        ),

        const SectionHeader('앱 잠금'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('PIN 잠금 사용'),
                value: settings.lockEnabled,
                onChanged: (v) async {
                  if (v) {
                    _showSetPinDialog(context, ref);
                  } else {
                    await ref.read(settingsProvider.notifier).disableLock();
                  }
                },
              ),
              if (settings.lockEnabled)
                ListTile(
                  title: const Text('PIN 변경'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSetPinDialog(context, ref),
                ),
            ],
          ),
        ),

        const SectionHeader('화면 테마'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('시스템'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('밝게'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('어둡게'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {settings.themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => ref.read(settingsProvider.notifier).setThemeMode(s.first),
            ),
          ),
        ),

        const SectionHeader('현재 기기 사용자'),
        Card(
          child: ListTile(
            title: Text(settings.deviceOwner ?? '미설정'),
            subtitle: const Text('내역 기록 시 "누가 입력했는지" 표시에 사용돼요.'),
            trailing: DropdownButton<String>(
              value: settings.deviceOwner,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: '아빠', child: Text('아빠')),
                DropdownMenuItem(value: '엄마', child: Text('엄마')),
              ],
              onChanged: (v) {
                if (v != null) ref.read(settingsProvider.notifier).setDeviceOwner(v);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showEditChildDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: child.name);
    final amountController = TextEditingController(text: '${child.weeklyAllowanceDefault}');
    final thresholdController = TextEditingController(text: '${child.autoTransferThreshold}');
    final stockLabelController = TextEditingController(text: child.stockAccountLabel ?? '');
    int payDay = child.payDayOfWeek;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('자녀 정보 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '이름')),
                const SizedBox(height: 10),
                TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '기본 주간 용돈(원)')),
                const SizedBox(height: 10),
                TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '이체 권장 기준 금액(원)')),
                const SizedBox(height: 10),
                TextField(
                    controller: stockLabelController,
                    decoration: const InputDecoration(labelText: '주식계좌 별칭')),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: payDay,
                  decoration: const InputDecoration(labelText: '지급 요일'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('월요일')),
                    DropdownMenuItem(value: 2, child: Text('화요일')),
                    DropdownMenuItem(value: 3, child: Text('수요일')),
                    DropdownMenuItem(value: 4, child: Text('목요일')),
                    DropdownMenuItem(value: 5, child: Text('금요일')),
                    DropdownMenuItem(value: 6, child: Text('토요일')),
                    DropdownMenuItem(value: 7, child: Text('일요일')),
                  ],
                  onChanged: (v) => setState(() => payDay = v ?? payDay),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final db = ref.read(databaseProvider);
                final owner = ref.read(settingsProvider).deviceOwner ?? '';
                final newAmount =
                    int.tryParse(amountController.text) ?? child.weeklyAllowanceDefault;
                await db.upsertChild(ChildrenCompanion(
                  id: Value(child.id),
                  name: Value(nameController.text.trim()),
                  stockAccountLabel: Value(stockLabelController.text.trim()),
                  weeklyAllowanceDefault: Value(newAmount),
                  autoTransferThreshold: Value(
                      int.tryParse(thresholdController.text) ?? child.autoTransferThreshold),
                  payDayOfWeek: Value(payDay),
                  updatedAt: Value(DateTime.now()),
                ));
                // 기본 용돈이 실제로 바뀌었으면 변경 이력 기록
                if (newAmount != child.weeklyAllowanceDefault) {
                  await db.addAllowanceRate(child.id, newAmount, owner);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateHistory(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final ratesAsync = ref.watch(allowanceRatesProvider(child.id));
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('기본 용돈 변경 이력',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  const SizedBox(height: 4),
                  Text('현재 ${formatWon(child.weeklyAllowanceDefault)}',
                      style: TextStyle(
                          fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  ratesAsync.when(
                    loading: () => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('오류: $e'),
                    data: (rates) {
                      if (rates.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('아직 변경 이력이 없어요. 자녀 정보에서 기본 용돈을 바꾸면 여기에 기록돼요.',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        );
                      }
                      return Column(
                        children: [
                          for (final r in rates)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.trending_up),
                              title: Text(formatWon(r.amount),
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                  '${formatDate(r.changedAt)}${r.editedBy.isNotEmpty ? ' · ${r.editedBy}' : ''}'),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBonusDialog(BuildContext context, WidgetRef ref) {
    final thresholdController = TextEditingController(text: '${child.bonusThreshold}');
    final amountController = TextEditingController(text: '${child.bonusAmount}');
    int day = child.bonusDayOfWeek;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('절약 보너스 규칙'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: day,
                  decoration: const InputDecoration(labelText: '기준 요일'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('월요일')),
                    DropdownMenuItem(value: 2, child: Text('화요일')),
                    DropdownMenuItem(value: 3, child: Text('수요일')),
                    DropdownMenuItem(value: 4, child: Text('목요일')),
                    DropdownMenuItem(value: 5, child: Text('금요일')),
                    DropdownMenuItem(value: 6, child: Text('토요일')),
                    DropdownMenuItem(value: 7, child: Text('일요일')),
                  ],
                  onChanged: (v) => setState(() => day = v ?? day),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '유지 목표 금액(원)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '보너스 금액(원)'),
                ),
                const SizedBox(height: 8),
                Text('예: 매주 목요일까지 1,000원 이상 남아있으면 500원 지급',
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                await ref.read(databaseProvider).upsertChild(ChildrenCompanion(
                      id: Value(child.id),
                      bonusDayOfWeek: Value(day),
                      bonusThreshold:
                          Value(int.tryParse(thresholdController.text) ?? child.bonusThreshold),
                      bonusAmount:
                          Value(int.tryParse(amountController.text) ?? child.bonusAmount),
                      updatedAt: Value(DateTime.now()),
                    ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetPinDialog(BuildContext context, WidgetRef ref) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN 설정'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: '4~6자리 숫자'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              if (pinController.text.length < 4) return;
              await ref.read(settingsProvider.notifier).setPin(pinController.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final settings = ref.read(settingsProvider);
    final owner = settings.deviceOwner ?? '';
    final children = await db.allChildrenRaw();
    final (jsonFile, summaryFile) = await _exportImportService.buildExportFiles(
      db,
      exportedBy: owner,
      childrenForSummary: children.where((c) => c.deletedAt == null).toList(),
      settings: {
        'expenseCategories': settings.expenseCategories,
        'incomeCategories': settings.incomeCategories,
        'givers': settings.givers,
      },
    );
    await ref.read(settingsProvider.notifier).recordExport();
    await Share.shareXFiles(
      [XFile(jsonFile.path), XFile(summaryFile.path)],
      text: '아이 용돈 관리 백업 파일입니다. (.json 파일을 앱에서 Import 해주세요)',
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    final db = ref.read(databaseProvider);
    final preview = await _exportImportService.previewImport(file, db);

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('가져오기 미리보기'),
        content: Text(
            '신규 항목: ${preview.newCount}건\n갱신될 항목: ${preview.updatedCount}건\n변경 없음: ${preview.unchangedCount}건\n\n적용하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('적용')),
        ],
      ),
    );

    if (confirmed == true) {
      await _exportImportService.applyImport(preview, db);
      // 상대방 기기의 카테고리/받은사람 목록도 합집합으로 병합
      final s = preview.rawJson['settings'];
      if (s is Map) {
        List<String>? toList(dynamic v) =>
            v is List ? v.whereType<String>().toList() : null;
        await ref.read(settingsProvider.notifier).mergeCategoryLists(
              expense: toList(s['expenseCategories']),
              income: toList(s['incomeCategories']),
              givers: toList(s['givers']),
            );
      }
      await ref.read(settingsProvider.notifier).recordImport();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('가져오기가 완료되었습니다.')));
      }
    }
  }
}

class _CategoryExpansion extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String kind; // 'expense' | 'income' | 'giver'
  final List<String> items;
  final WidgetRef ref;

  const _CategoryExpansion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.kind,
    required this.items,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    return ExpansionTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      shape: const Border(),
      collapsedShape: const Border(),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in items)
                _RemovableChip(
                  label: c,
                  pair: palette.tagFor(c),
                  onRemove: items.length > 1
                      ? () => ref.read(settingsProvider.notifier).removeCategory(kind, c)
                      : null,
                ),
              _AddCategoryChip(
                  onAdd: (name) =>
                      ref.read(settingsProvider.notifier).addCategory(kind, name)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final PastelPair pair;
  final VoidCallback? onRemove;
  const _RemovableChip({required this.label, required this.pair, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 7, bottom: 7),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  color: pair.fg, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 16, color: pair.fg.withValues(alpha: 0.8)),
              ),
            )
          else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _AddCategoryChip extends StatelessWidget {
  final ValueChanged<String> onAdd;
  const _AddCategoryChip({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final controller = TextEditingController();
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('카테고리 추가'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '예: 교통, 저금통'),
              onSubmitted: (v) => Navigator.pop(context, v),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('추가')),
            ],
          ),
        );
        if (result != null && result.trim().isNotEmpty) onAdd(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('추가',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

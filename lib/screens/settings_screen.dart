import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../data/app_database.dart';
import '../providers/cofix_provider.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/sync_provider.dart';
import '../services/export_import_service.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/child_avatar.dart';
import '../widgets/ui_kit.dart';
import 'allowance_history_screen.dart';
import 'tier_settings_screen.dart';

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
                if (!settings.isChild)
                  IconButton(
                    onPressed: () => _showEditChildDialog(context, ref),
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
          ),
        ),

        if (!settings.isChild) ...[
          const SectionHeader('과거 용돈 설정'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: const Text('시작 날짜 + 지금까지 모은 돈'),
              subtitle: const Text('두 개만 넣으면 그동안 받은 용돈·쓴 돈을 자동 계산해 내역에 넣어요'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog(
                context: context,
                builder: (_) => _PastAllowanceDialog(child: child),
              ),
            ),
          ),
        ],

        // 카테고리 관리는 부모만 (아이가 지출/수입 종류를 지우면 통계가 깨짐)
        if (!settings.isChild) ...[
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
        ],

        if (!settings.isChild) ...[
          const SectionHeader('절약 보너스 규칙'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('절약 보너스 사용'),
                  subtitle: const Text('정해진 요일까지 목표 금액 이상 남기면 보너스 지급'),
                  value: child.bonusEnabled,
                  onChanged: (v) =>
                      ref.read(databaseProvider).updateChildPartial(child.id, ChildrenCompanion(
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
          const SectionHeader('저축 이자 규칙'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('저축 이자 사용'),
                  subtitle: const Text('잔액에 주기적으로 이자를 붙여 저축을 장려해요'),
                  value: child.interestEnabled,
                  onChanged: (v) =>
                      ref.read(databaseProvider).updateChildPartial(child.id, ChildrenCompanion(
                        interestEnabled: Value(v),
                        updatedAt: Value(DateTime.now()),
                      )),
                ),
                if (child.interestEnabled)
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: Text(
                        '${child.interestPeriod == 0 ? '매주' : '매월'} 잔액의 ${child.interestPercent}% 이자'),
                    subtitle: const Text('홈에서 원버튼으로 지급'),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _showInterestDialog(context, ref),
                  ),
              ],
            ),
          ),
          if (child.interestEnabled) ...[
            const SectionHeader('부모님과 약속'),
            _buildPromises(context, ref),
            const SectionHeader('금리 표시 (COFIX·기준금리·예금)'),
            _buildCofixSettings(context, ref),
          ],
        ],

        const SectionHeader('실시간 자동 동기화'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSyncPanel(context, ref, settings),
          ),
        ),

        // 백업/복원은 부모만. 특히 가져오기(Import)는 전체 데이터를 덮어쓴다.
        if (!settings.isChild) ...[
          const SectionHeader('수동 백업 (파일로 주고받기)'),
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
        ],

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

        const SectionHeader('용돈 이력'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('정기 용돈 지급 이력'),
                subtitle: const Text('지급일별 지급/미지급 + 기간별 합계'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AllowanceHistoryScreen(child: child),
                )),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('기본 용돈 변경 이력'),
                subtitle: const Text('기본 용돈 금액을 언제 얼마로 바꿨는지'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRateHistory(context, ref),
              ),
            ],
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

        if (!settings.isChild) ...[
          const SectionHeader('티어 / 칭호'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('티어 / 칭호 설정'),
              subtitle: const Text('칭호·도달 금액·아이콘·보상 수정 (동기화됨)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TierSettingsScreen(),
                ));
                // 수정 후 즉시 가족 문서로 전파
                final sync = ref.read(familySyncServiceProvider);
                if (sync.isActive) await sync.pushNow();
              },
            ),
          ),
          const SectionHeader('부모 암호'),
          Card(
            // 암호가 없으면 아이가 설정에서 그냥 부모 모드로 바꿔 모든 제한을 우회할 수 있다.
            color: settings.hasParentPasscode
                ? null
                : appPalette(context).expense.bg,
            child: ListTile(
              leading: Icon(
                  settings.hasParentPasscode
                      ? Icons.shield_outlined
                      : Icons.gpp_maybe_outlined,
                  color: settings.hasParentPasscode
                      ? null
                      : appPalette(context).expense.fg),
              title: Text(settings.hasParentPasscode ? '부모 암호 변경' : '부모 암호를 설정해주세요',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: settings.hasParentPasscode
                          ? null
                          : appPalette(context).expense.fg)),
              subtitle: Text(settings.hasParentPasscode
                  ? '아이 폰에서 부모 모드로 못 들어가게 막아요'
                  : '지금은 아이가 설정에서 부모 모드로 바꿔 모든 제한을 풀 수 있어요.',
                  style: TextStyle(
                      color: settings.hasParentPasscode
                          ? null
                          : appPalette(context).expense.fg)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSetParentPasscodeDialog(context, ref),
            ),
          ),
        ],

        const SectionHeader('현재 기기 사용자'),
        Card(
          child: ListTile(
            title: Text(settings.deviceOwner ?? '미설정'),
            subtitle: Text(settings.isChild
                ? '자녀 모드예요. 부모 모드로 바꾸려면 부모 암호가 필요해요.'
                : '내역 기록 시 "누가 입력했는지" 표시에 사용돼요.'),
            trailing: DropdownButton<String>(
              value: settings.deviceOwner,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: '아빠', child: Text('아빠')),
                DropdownMenuItem(value: '엄마', child: Text('엄마')),
                DropdownMenuItem(value: '아들', child: Text('아들')),
              ],
              onChanged: (v) => _handleRoleChange(context, ref, settings, v),
            ),
          ),
        ),

        const SectionHeader('앱 정보'),
        const Card(child: _AppVersionTile()),
      ],
    );
  }

  /// 역할 전환. 자녀→부모(아빠/엄마)로 갈 때만 부모 암호를 요구한다.
  /// 암호가 설정돼 있지 않으면(초기) 부모가 아직 안 정한 것이므로 통과시키되 안내한다.
  Future<void> _handleRoleChange(
      BuildContext context, WidgetRef ref, AppSettings settings, String? v) async {
    if (v == null || v == settings.deviceOwner) return;
    final toParent = v == '아빠' || v == '엄마';
    if (toParent && settings.isChild && settings.hasParentPasscode) {
      final ok = await _promptParentPasscode(context, ref);
      if (!ok) return;
    }
    await ref.read(settingsProvider.notifier).setDeviceOwner(v);
  }

  /// 부모 암호 입력을 받아 검증. 맞으면 true.
  Future<bool> _promptParentPasscode(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('부모 암호 입력'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          autofocus: true,
          maxLength: 6,
          decoration: const InputDecoration(labelText: '부모 암호'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              final ok = ref.read(settingsProvider.notifier).verifyParentPasscode(controller.text);
              Navigator.pop(context, ok);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('암호가 맞지 않아요.')));
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSetParentPasscodeDialog(BuildContext context, WidgetRef ref) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('부모 암호 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('아이 폰에서 부모 모드로 전환하려면 이 암호가 필요해요. '
                '가족 동기화로 다른 부모 폰에도 자동 적용됩니다.'),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: '4~6자리 숫자'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              if (pinController.text.length < 4) return;
              await ref.read(settingsProvider.notifier).setParentPasscode(pinController.text);
              // 즉시 가족 문서로 전파(다른 폰/아이 폰에 반영)
              final sync = ref.read(familySyncServiceProvider);
              if (sync.isActive) await sync.pushNow();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('부모 암호를 설정했어요.')));
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // 앱 사용 전부터 모아둔 용돈을 한 번만 입력/수정하는 다이얼로그.
  // 저장 시 category='이월잔액'인 특별 수입 내역 1건으로 기록되어 잔액 계산에 자동 합산된다.
  void _showEditChildDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: child.name);
    final amountController = TextEditingController(text: '${child.weeklyAllowanceDefault}');
    final thresholdController = TextEditingController(text: '${child.autoTransferThreshold}');
    final stockLabelController = TextEditingController(text: child.stockAccountLabel ?? '');
    final reasonController = TextEditingController();
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
                // 용돈을 바꾸는 경우에만 사유를 남길 수 있게 안내
                TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                        labelText: '용돈 변경 사유 (선택)', hintText: '예: 초등학교 입학, 심부름 잘함')),
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
                // 기본 용돈이 실제로 바뀌었으면 변경 이력 기록(사유 포함)
                if (newAmount != child.weeklyAllowanceDefault) {
                  final reason = reasonController.text.trim();
                  await db.addAllowanceRate(child.id, newAmount, owner,
                      note: reason.isEmpty ? null : reason);
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${formatDate(r.changedAt)}${r.editedBy.isNotEmpty ? ' · ${r.editedBy}' : ''}'),
                                  if (r.note != null && r.note!.isNotEmpty)
                                    Text('사유: ${r.note}',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                ],
                              ),
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

  void _showInterestDialog(BuildContext context, WidgetRef ref) {
    final percentController = TextEditingController(text: '${child.interestPercent}');
    int period = child.interestPeriod;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('저축 이자 규칙'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('매주')),
                  ButtonSegment(value: 1, label: Text('매월')),
                ],
                selected: {period},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => period = s.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: percentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: '이율(%)', hintText: '예: 1 또는 0.5'),
              ),
              const SizedBox(height: 8),
              Text('예: 매월 잔액의 1% 이자 → 잔액 10,000원이면 100원 지급',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                final pct = double.tryParse(percentController.text) ?? child.interestPercent;
                await ref.read(databaseProvider).updateChildPartial(child.id, ChildrenCompanion(
                      interestPercent: Value(pct),
                      interestPeriod: Value(period),
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

  // ---------------- 부모-자녀 약속 ----------------
  Widget _buildPromises(BuildContext context, WidgetRef ref) {
    final promisesAsync = ref.watch(promisesProvider(child.id));
    final db = ref.read(databaseProvider);
    return Card(
      child: Column(
        children: [
          promisesAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
            error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('오류: $e')),
            data: (promises) {
              if (promises.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '약속을 추가하면, 켜진(ON) 약속마다 이자율이 올라가요.\n'
                    '약속 안 지킨 주엔 OFF로 바꿔 낮은 이자를 적용하세요.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                );
              }
              return Column(
                children: [
                  for (final p in promises)
                    SwitchListTile(
                      value: p.enabled,
                      onChanged: (v) => db.updatePromiseFields(p.id, enabled: v),
                      title: Text(p.title),
                      subtitle: Text('지키면 +${formatPercent(p.bonusPercent)}%'),
                      secondary: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        tooltip: '수정/삭제',
                        onPressed: () => _showPromiseDialog(context, ref, existing: p),
                      ),
                    ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('약속 추가'),
            onTap: () => _showPromiseDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showPromiseDialog(BuildContext context, WidgetRef ref, {Promise? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final bonusController =
        TextEditingController(text: formatPercent(existing?.bonusPercent ?? 0.1));
    final db = ref.read(databaseProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? '약속 추가' : '약속 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration:
                  const InputDecoration(labelText: '약속 내용', hintText: '예: 매일 이 닦기'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bonusController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: '지키면 올려줄 이자율(%)', hintText: '예: 0.1'),
            ),
          ],
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () async {
                await db.softDeletePromise(existing.id);
                if (context.mounted) Navigator.pop(context);
              },
              child:
                  Text('삭제', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              final bonus = double.tryParse(bonusController.text.trim()) ?? 0.1;
              if (existing == null) {
                await db.upsertPromise(PromisesCompanion.insert(
                  id: const Uuid().v4(),
                  childId: child.id,
                  title: title,
                  bonusPercent: Value(bonus),
                  updatedAt: Value(DateTime.now()),
                ));
              } else {
                await db.updatePromiseFields(existing.id, title: title, bonusPercent: bonus);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  // ---------------- COFIX 금리 설정 ----------------
  Widget _buildCofixSettings(BuildContext context, WidgetRef ref) {
    final config = ref.watch(cofixConfigProvider);
    final shown = ref.watch(cofixProvider).valueOrNull;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: Text(shown != null
                ? '현재 표시: ${formatPercent(shown.rate)}% (${shown.isAuto ? '자동' : '수동'})'
                : 'COFIX 값이 아직 없어요'),
            subtitle: const Text('이자 카드와 "COFIX 금리란?" 설명에 함께 보여줘요'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('COFIX 금리 직접 입력'),
            subtitle: Text(config.hasManual
                ? '${formatPercent(config.manualRate!)}%'
                    '${config.manualDate != null ? ' · ${formatDate(config.manualDate!)} 갱신' : ''}'
                : '매월 한 번 입력 (은행연합회 발표값)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCofixManualDialog(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('기준금리·정기예금 자동조회 (ECOS)'),
            subtitle: Text(config.hasCustomKey
                ? '내 인증키 사용 중'
                : '기본 인증키로 자동 표시 중 · 필요하면 내 키로 교체'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEcosKeyDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showCofixManualDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(cofixConfigProvider);
    final controller =
        TextEditingController(text: config.manualRate == null ? '' : formatPercent(config.manualRate!));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('COFIX 금리 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'COFIX 금리(%)', hintText: '예: 3.05'),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('은행연합회 공식 COFIX 확인'),
                onPressed: () => launchUrl(
                  Uri.parse('https://portal.kfb.or.kr/fingood/cofix.php'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final rate = double.tryParse(controller.text.trim());
              if (rate == null) return;
              await ref.read(cofixConfigProvider.notifier).setManualRate(rate);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showEcosKeyDialog(BuildContext context, WidgetRef ref) {
    final config = ref.read(cofixConfigProvider);
    final controller = TextEditingController(text: config.ecosApiKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ECOS 자동조회 (선택)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('기준금리·정기예금은 기본 인증키로 이미 자동 표시돼요. '
                '내 인증키로 바꾸고 싶을 때만 넣으면 돼요. (COFIX는 키 없이 자동)',
                style: TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration:
                  const InputDecoration(labelText: 'ECOS 인증키(선택)', hintText: '비우면 기본키 사용'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('무료 인증키 발급받기'),
                onPressed: () => launchUrl(
                  Uri.parse('https://ecos.bok.or.kr/api/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              await ref.read(cofixConfigProvider.notifier).setEcosApiKey(controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
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
                await ref.read(databaseProvider).updateChildPartial(child.id, ChildrenCompanion(
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

  // ---------- 실시간 자동 동기화 (Firebase) ----------
  Widget _buildSyncPanel(BuildContext context, WidgetRef ref, AppSettings settings) {
    final code = settings.familyCode;
    final isChild = settings.isChild;

    if (code == null) {
      // 자녀 모드에서는 가족 연결을 새로 만들거나 갈아끼울 수 없다.
      if (isChild) {
        return Text('아직 가족 연결이 안 돼 있어요. 부모님께 말씀드리면 연결해 주실 거예요.',
            style: TextStyle(
                fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('앱을 켜두면 아내/남편 폰과 자동으로 동기화돼요. 파일을 주고받을 필요 없어요.',
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => _handleCreateFamily(context, ref),
            icon: const Icon(Icons.add_link),
            label: const Text('동기화 시작하기 (코드 발급)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _handleJoinFamily(context, ref),
            icon: const Icon(Icons.link),
            label: const Text('상대방 코드로 참여하기'),
          ),
        ],
      );
    }

    final statusAsync = ref.watch(syncStatusProvider);
    final service = ref.watch(familySyncServiceProvider);
    final statusText = statusAsync.when(
      data: (s) => switch (s) {
        SyncStatus.syncing => '동기화 중...',
        SyncStatus.error => '동기화 오류 (인터넷 연결을 확인해주세요)',
        SyncStatus.idle => service.lastSyncedAt != null
            ? '마지막 동기화: ${formatDate(service.lastSyncedAt!)}'
            : '연결됨',
      },
      loading: () => '연결하는 중...',
      error: (_, __) => '상태 확인 불가',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.sync, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 자녀 모드에선 코드를 노출하지 않는다(코드를 알면 다른 기기에서 참여 가능)
                  Text(isChild ? '가족과 연결됨' : '가족 코드: $code',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15.5, letterSpacing: 1)),
                  Text(statusText,
                      style: TextStyle(
                          fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (!isChild)
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: '코드 공유',
                onPressed: () => Share.share(
                    '용돈관리 앱 동기화 코드: $code\n앱 설정 > 실시간 자동 동기화 > "상대방 코드로 참여하기"에 입력해주세요.'),
              ),
          ],
        ),
        // 동기화 끊기는 부모만 (아이가 끊으면 기록이 부모 폰과 어긋남)
        if (!isChild) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _handleLeaveFamily(context, ref),
              icon: const Icon(Icons.link_off, size: 18),
              label: const Text('동기화 끊기'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleCreateFamily(BuildContext context, WidgetRef ref) async {
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    try {
      final code = await ref.read(familySyncServiceProvider).createFamily(owner);
      await ref.read(settingsProvider.notifier).setFamilyCode(code);
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('동기화 코드가 발급됐어요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(code,
                  style:
                      const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3)),
              const SizedBox(height: 10),
              const Text('이 코드를 상대방에게 알려주고, 상대방 폰의 설정 > 실시간 자동 동기화 > '
                  '"상대방 코드로 참여하기"에 입력하면 자동으로 연결돼요.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Share.share('용돈관리 앱 동기화 코드: $code'),
              child: const Text('카톡으로 공유'),
            ),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('동기화 시작 실패: $e')));
    }
  }

  Future<void> _handleJoinFamily(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상대방 코드로 참여'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: '6자리 코드'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('참여'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty) return;
    if (!context.mounted) return;
    final owner = ref.read(settingsProvider).deviceOwner ?? '';
    try {
      await ref.read(familySyncServiceProvider).joinFamily(code, owner);
      await ref.read(settingsProvider.notifier).setFamilyCode(code.trim().toUpperCase());
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('동기화에 연결됐어요.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _handleLeaveFamily(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('동기화를 끊을까요?'),
        content: const Text('이 기기에서만 자동 동기화가 중단됩니다. 지금까지의 데이터는 그대로 남아있어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('끊기')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(familySyncServiceProvider).leaveFamily();
    await ref.read(settingsProvider.notifier).clearFamilyCode();
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
      // 서로 다른 기기에서 온보딩해 생긴 중복 프로필을 하나로 정리하고,
      // 데이터가 들어있는 프로필을 화면에 선택해준다.
      final owner = ref.read(settingsProvider).deviceOwner ?? '';
      final primary = await db.reconcileToSingleChild(owner);
      if (primary != null) {
        ref.read(selectedChildIdProvider.notifier).state = primary;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('가져오기가 완료되었습니다.')));
      }
    }
  }
}

/// 시작 날짜만 넣으면 그동안 받은 정기용돈을 변경이력 반영해 계산해 일괄 반영.
class _PastAllowanceDialog extends ConsumerStatefulWidget {
  final Child child;
  const _PastAllowanceDialog({required this.child});
  @override
  ConsumerState<_PastAllowanceDialog> createState() => _PastAllowanceDialogState();
}

class _PastAllowanceDialogState extends ConsumerState<_PastAllowanceDialog> {
  DateTime _start = DateTime.now().subtract(const Duration(days: 365));
  final _savedController = TextEditingController();
  int? _total; // 계산된 총 정기용돈

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void dispose() {
    _savedController.dispose();
    super.dispose();
  }

  Future<void> _recompute() async {
    setState(() => _total = null);
    final t = await ref.read(databaseProvider).estimatePastAllowance(widget.child, _start);
    if (mounted) setState(() => _total = t);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final saved = int.tryParse(_savedController.text) ?? 0;
    final total = _total ?? 0;
    final spent = (total - saved).clamp(0, total); // 자동 계산된 소비
    return AlertDialog(
      title: const Text('과거 용돈 설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('① 용돈을 처음 주기 시작한 날짜와 ② 지금까지 모아둔 돈만 넣으면, '
                '그동안 받은 정기용돈을 자동 계산하고 쓴 돈을 뭉텅이로 내역에 넣어드려요.'),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: _start,
                  firstDate: DateTime(2015),
                  lastDate: DateTime.now(),
                );
                if (p != null) {
                  _start = p;
                  _recompute();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 10),
                    Text('① 시작 날짜: ${formatDate(_start)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _savedController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: '② 지금까지 모은 돈 (원)'),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _total == null
                        ? '계산 중...'
                        : '받은 정기용돈 ≈ ${formatWon(total)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: scheme.onSecondaryContainer),
                  ),
                  const SizedBox(height: 2),
                  Text('자동 계산된 소비 ≈ ${formatWon(spent)}',
                      style: TextStyle(
                          fontSize: 12.5, color: scheme.onSecondaryContainer)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('적용하면 기존 시작 잔액은 대체돼요.',
                style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: _total == null
              ? null
              : () async {
                  final owner = ref.read(settingsProvider).deviceOwner ?? '';
                  await ref
                      .read(databaseProvider)
                      .applyPastAllowance(widget.child, _start, saved, owner);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('과거 용돈을 반영했어요.')));
                  }
                },
          child: const Text('적용'),
        ),
      ],
    );
  }
}

/// 앱 버전 + 업데이트 확인. GitHub 최신 릴리즈와 비교해 새 버전이 있으면 안내.
class _AppVersionTile extends StatefulWidget {
  const _AppVersionTile();
  @override
  State<_AppVersionTile> createState() => _AppVersionTileState();
}

class _AppVersionTileState extends State<_AppVersionTile> {
  String _version = '확인 중...';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version} (빌드 ${info.buildNumber})');
    }).catchError((_) {
      if (mounted) setState(() => _version = '버전 정보를 읽을 수 없어요');
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('링크를 열 수 없어요.')));
      }
    }
  }

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    UpdateInfo? info;
    try {
      info = await const UpdateService().check();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _checking = false);
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업데이트 확인 실패 (인터넷 연결을 확인해주세요)')));
      return;
    }
    if (!info.hasUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('최신 버전이에요 (v${info.currentVersion})')));
      return;
    }
    final u = info;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('새 버전 v${u.latestVersion} 있어요!'),
        content: Text('현재 v${u.currentVersion} → 최신 v${u.latestVersion}\n\n'
            '아래 "지금 받기"를 누르면 새 버전 파일을 내려받아요. 다운로드한 파일을 열면 설치됩니다.\n'
            '(플레이스토어 앱이 아니라서 "출처를 알 수 없는 앱 허용"이 필요할 수 있어요)'),
        actions: [
          TextButton(
              onPressed: () => _open(u.releaseUrl), child: const Text('릴리즈 페이지')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('나중에')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _open(u.apkUrl ?? u.releaseUrl);
            },
            child: const Text('지금 받기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('앱 버전'),
          subtitle: Text(_version),
        ),
        const Divider(height: 1),
        ListTile(
          leading: _checking
              ? const SizedBox(
                  width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.system_update),
          title: const Text('업데이트 확인'),
          subtitle: const Text('새 버전이 있으면 받을 수 있어요'),
          onTap: _checking ? null : _checkUpdate,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('최신 릴리즈 페이지 열기'),
          subtitle: const Text('GitHub에서 직접 받기'),
          onTap: () => _open(UpdateService.releasesPage),
        ),
      ],
    );
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

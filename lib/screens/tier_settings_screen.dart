import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/tier_provider.dart';
import '../utils/formatters.dart';
import '../widgets/tier_widgets.dart';

/// 부모가 저축 티어(칭호/금액/아이콘/보상)를 수정하는 화면. 수정 내용은 동기화됨.
class TierSettingsScreen extends ConsumerWidget {
  const TierSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savings = ref.watch(savingsTiersProvider);
    final weekly = ref.watch(weeklyTiersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('티어 / 칭호 설정')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text('아이에게 보이는 칭호·금액·아이콘·보상을 바꿀 수 있어요. 바꾸면 가족 폰에 자동 반영됩니다.',
              style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          const Text('누적 저축 티어', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          savings.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('오류: $e'),
            data: (tiers) => Column(
              children: [
                for (final t in tiers)
                  _TierRow(tier: t, isPercent: false, onEdit: () => _editTier(context, ref, t, false)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('주간 저축률 티어', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          weekly.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('오류: $e'),
            data: (tiers) => Column(
              children: [
                for (final t in tiers)
                  _TierRow(tier: t, isPercent: true, onEdit: () => _editTier(context, ref, t, true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 갤러리에서 이미지를 골라 이 티어의 아이콘으로 저장(앱 문서 폴더에 복사).
  Future<void> _pickIcon(BuildContext context, WidgetRef ref, Tier t) async {
    try {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
      if (x == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final iconsDir = Directory('${dir.path}/tier_icons');
      if (!await iconsDir.exists()) await iconsDir.create(recursive: true);
      final dest = '${iconsDir.path}/${t.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(x.path).copy(dest);
      await ref.read(tierIconPathsProvider.notifier).setPath(t.id, dest);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('아이콘 이미지를 넣었어요.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('이미지를 넣지 못했어요: $e')));
      }
    }
  }

  void _editTier(BuildContext context, WidgetRef ref, Tier t, bool isPercent) {
    final titleController = TextEditingController(text: t.title);
    final iconController = TextEditingController(text: t.icon);
    final thresholdController = TextEditingController(text: '${t.threshold}');
    final rewardController = TextEditingController(text: t.reward ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          TierIcon(tier: t, size: 22),
          const SizedBox(width: 8),
          Flexible(child: Text('${t.title} 수정', overflow: TextOverflow.ellipsis)),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPercent) ...[
                // 내 이미지로 아이콘 바꾸기 (기기 로컬, 동기화 안 됨)
                Row(
                  children: [
                    TierIcon(tier: t, size: 34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _pickIcon(context, ref, t),
                            icon: const Icon(Icons.image_outlined, size: 18),
                            label: const Text('내 이미지 넣기'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref.read(tierIconPathsProvider.notifier).clearPath(t.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('기본 아이콘으로 되돌렸어요.')));
                              }
                            },
                            child: const Text('기본 아이콘으로'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text('내 이미지는 이 기기에만 저장돼요(동기화 안 됨).',
                    style: TextStyle(
                        fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const Divider(height: 20),
              ],
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '칭호'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: iconController,
                decoration: InputDecoration(
                    labelText: '아이콘(이모지)',
                    helperText: isPercent ? null : '블럭 이미지가 있으면 이미지가 먼저 표시돼요',
                    helperMaxLines: 2),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: thresholdController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: isPercent ? '도달 저축률(%)' : '도달 금액(원)'),
              ),
              if (!isPercent) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: rewardController,
                  decoration: const InputDecoration(labelText: '보상', hintText: '예: 치킨 한 마리'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final threshold = int.tryParse(thresholdController.text) ?? t.threshold;
              final title = titleController.text.trim().isEmpty ? t.title : titleController.text.trim();
              final icon = iconController.text.trim().isEmpty ? t.icon : iconController.text.trim();
              final reward = isPercent
                  ? t.reward
                  : (rewardController.text.trim().isEmpty ? null : rewardController.text.trim());
              await ref
                  .read(databaseProvider)
                  .updateTierFields(t.id, threshold: threshold, title: title, icon: icon, reward: reward);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  final Tier tier;
  final bool isPercent;
  final VoidCallback onEdit;
  const _TierRow({required this.tier, required this.isPercent, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: TierIcon(tier: tier, size: 24),
        title: Text(tier.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(isPercent
            ? '${tier.threshold}% 이상'
            : '${formatWon(tier.threshold)}${tier.reward != null && tier.reward!.isNotEmpty ? ' · 🎁 ${tier.reward}' : ''}'),
        trailing: const Icon(Icons.edit_outlined),
        onTap: onEdit,
      ),
    );
  }
}

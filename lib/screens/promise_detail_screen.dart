import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/ui_kit.dart';

/// 약속 하나의 상세 + 댓글 타임라인.
/// - 아이: "이렇게 지키고 있어요" 댓글을 남길 수 있다(ON/OFF는 못 바꿈).
/// - 부모: 댓글(답글)을 달고, ON/OFF를 이유와 함께 바꿀 수 있다.
class PromiseDetailScreen extends ConsumerStatefulWidget {
  final Promise promise;
  const PromiseDetailScreen({super.key, required this.promise});

  @override
  ConsumerState<PromiseDetailScreen> createState() => _PromiseDetailScreenState();
}

class _PromiseDetailScreenState extends ConsumerState<PromiseDetailScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _me => ref.read(settingsProvider).deviceOwner ?? '';

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await ref.read(databaseProvider).addPromiseComment(
          promiseId: widget.promise.id,
          childId: widget.promise.childId,
          author: _me,
          text: text,
        );
    _controller.clear();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    // 목록이 갱신되면 최신 약속 상태를 반영한다(다른 기기에서 ON/OFF가 바뀔 수 있음).
    final promises = ref.watch(promisesProvider(widget.promise.childId)).valueOrNull;
    final promise = promises?.firstWhere(
          (p) => p.id == widget.promise.id,
          orElse: () => widget.promise,
        ) ??
        widget.promise;
    final commentsAsync = ref.watch(promiseCommentsProvider(promise.id));
    final isChild = ref.watch(settingsProvider).isChild;
    final palette = appPalette(context);
    final pair = promise.enabled ? palette.income : palette.expense;

    return Scaffold(
      appBar: AppBar(title: const Text('약속')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration:
                BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promise.title,
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800, color: pair.fg)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: pair.fg.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(promise.enabled ? 'ON · 지키는 중' : 'OFF · 잠시 멈춤',
                          style: TextStyle(
                              color: pair.fg, fontSize: 12, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Text('이자 +${formatPercent(promise.bonusPercent)}%',
                        style: TextStyle(color: pair.fg, fontSize: 12.5)),
                  ],
                ),
                if (!isChild) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showToggleDialog(promise, true),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('ON으로'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showToggleDialog(promise, false),
                          icon: const Icon(Icons.pause_circle_outline, size: 18),
                          label: const Text('OFF로'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: commentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        isChild
                            ? '약속을 어떻게 지키고 있는지\n적어보면 부모님이 볼 수 있어요!'
                            : '아직 댓글이 없어요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: comments.length,
                  itemBuilder: (_, i) =>
                      _CommentTile(comment: comments[i], me: _me),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: isChild ? '어떻게 지키고 있는지 적어보기' : '답글 남기기',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 부모가 ON/OFF를 바꾸며 이유를 남기는 다이얼로그.
  void _showToggleDialog(Promise promise, bool enable) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(enable ? 'ON으로 바꾸기' : 'OFF로 바꾸기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              enable
                  ? '약속을 잘 지켰다는 뜻이에요. 이자율이 +${formatPercent(promise.bonusPercent)}% 올라가요.'
                  : '이번엔 약속을 못 지켰다는 뜻이에요. 그만큼 이자가 낮아져요.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '이유 (아이가 볼 수 있어요)',
                hintText: '예: 이번 주 내내 잘 지켰어!',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              await ref.read(databaseProvider).setPromiseEnabled(
                    promise,
                    enabled: enable,
                    author: _me,
                    reason: reasonController.text,
                  );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}

/// 댓글 한 줄. kind='status'면 ON/OFF 변경 기록으로 다르게 그린다.
class _CommentTile extends StatelessWidget {
  final PromiseComment comment;
  final String me;
  const _CommentTile({required this.comment, required this.me});

  @override
  Widget build(BuildContext context) {
    final palette = appPalette(context);
    final theme = Theme.of(context);
    final isStatus = comment.kind == 'status';
    final author = comment.author.isEmpty ? '가족' : comment.author;
    final when = formatDateShort(comment.createdAt);

    if (isStatus) {
      final on = comment.statusEnabled == true;
      final pair = on ? palette.income : palette.expense;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pair.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(on ? Icons.check_circle : Icons.pause_circle,
                      size: 16, color: pair.fg),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('$author님이 ${on ? 'ON으로 했어요' : 'OFF로 했어요'}',
                        style: TextStyle(
                            color: pair.fg, fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                  Text(when, style: TextStyle(fontSize: 11, color: pair.fg)),
                ],
              ),
              if (comment.message != null && comment.message!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(comment.message!,
                    style: TextStyle(color: pair.fg, fontSize: 13, height: 1.4)),
              ],
            ],
          ),
        ),
      );
    }

    final mine = comment.author == me;
    final pair = palette.tagFor(author);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: mine ? pair.bg : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(author,
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: mine ? pair.fg : theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Text(when,
                          style: TextStyle(
                              fontSize: 10.5,
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(comment.message ?? '',
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: mine ? pair.fg : theme.colorScheme.onSurface)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

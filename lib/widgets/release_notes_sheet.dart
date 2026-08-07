import 'package:flutter/material.dart';
import '../data/changelog.dart';
import '../theme/app_theme.dart';
import 'ui_kit.dart';

/// 업데이트 소식을 보여주는 시트.
///
/// 아들 폰에는 브라우저가 없어서 GitHub 릴리즈 노트를 볼 수 없다. 그래서 앱 안에
/// 넣어두고 여기서 보여준다(인터넷 없이도 열린다).
void showReleaseNotes(BuildContext context, {String? highlightVersion}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, controller) => _ReleaseNotesBody(
        controller: controller,
        highlightVersion: highlightVersion,
      ),
    ),
  );
}

class _ReleaseNotesBody extends StatelessWidget {
  final ScrollController controller;

  /// 방금 업데이트된 버전. 그 칸만 펼쳐서 강조해 보여준다.
  final String? highlightVersion;

  const _ReleaseNotesBody({required this.controller, this.highlightVersion});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isJustUpdated = highlightVersion != null;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Text(isJustUpdated ? '앱이 새로워졌어요! 🎉' : '새로운 소식',
            style: const TextStyle(
                fontSize: AppText.heading,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5)),
        const SizedBox(height: AppGap.xxs),
        Text(
            isJustUpdated
                ? '이번에 뭐가 바뀌었는지 알려줄게요.'
                : '지금까지 바뀐 것들이에요.',
            style: TextStyle(
                fontSize: AppText.label, color: scheme.onSurfaceVariant)),
        const SizedBox(height: AppGap.md),
        if (kReleaseNotes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppGap.xxl),
            child: Text('아직 소식이 없어요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
        for (var i = 0; i < kReleaseNotes.length; i++)
          _NoteCard(
            note: kReleaseNotes[i],
            // 방금 업데이트된 버전이 있으면 그것만, 없으면 맨 위 것만 펼친다.
            expanded: highlightVersion != null
                ? kReleaseNotes[i].version == highlightVersion
                : i == 0,
            isNew: kReleaseNotes[i].version == highlightVersion,
          ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final ReleaseNote note;
  final bool expanded;
  final bool isNew;

  const _NoteCard({
    required this.note,
    required this.expanded,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = appPalette(context);

    return Card(
      color: isNew ? scheme.primaryContainer : null,
      child: Theme(
        // ExpansionTile 기본 구분선 제거(카드 안에서 지저분해 보인다).
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: AppGap.lg, vertical: 2),
          childrenPadding:
              const EdgeInsets.fromLTRB(AppGap.lg, 0, AppGap.lg, AppGap.lg),
          title: Row(
            children: [
              Flexible(
                child: Text(note.headline,
                    style: TextStyle(
                        fontSize: AppText.body,
                        fontWeight: FontWeight.w800,
                        color: isNew ? scheme.onPrimaryContainer : null)),
              ),
              if (isNew) ...[
                const SizedBox(width: AppGap.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.income.bg,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Text('NEW',
                      style: TextStyle(
                          fontSize: AppText.micro,
                          fontWeight: FontWeight.w900,
                          color: palette.income.fg)),
                ),
              ],
            ],
          ),
          subtitle: Text('v${note.version} · ${note.date}',
              style: TextStyle(
                  fontSize: AppText.micro,
                  color: (isNew
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant)
                      .withValues(alpha: 0.8))),
          children: [
            for (final c in note.changes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppGap.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•',
                        style: TextStyle(
                            fontSize: AppText.body,
                            height: 1.5,
                            color: isNew
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant)),
                    const SizedBox(width: AppGap.sm),
                    Expanded(
                      child: Text(c,
                          style: TextStyle(
                              fontSize: AppText.label,
                              height: 1.6,
                              color: isNew
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

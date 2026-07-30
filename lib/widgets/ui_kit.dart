import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

AppPalette appPalette(BuildContext context) => Theme.of(context).extension<AppPalette>()!;

/// 파스텔 배경의 작은 태그(카테고리/증여자 등).
class TagChip extends StatelessWidget {
  final String label;
  final PastelPair? pair;
  final IconData? icon;

  const TagChip({super.key, required this.label, this.pair, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = pair ?? appPalette(context).tagFor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(AppRadius.sm)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: p.fg), const SizedBox(width: AppGap.xs)],
          Text(label,
              style: TextStyle(
                  color: p.fg, fontSize: AppText.label, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
        ],
      ),
    );
  }
}

/// 섹션 제목 (좌측 정렬, 살짝 작은 굵은 글씨).
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 홈 카드가 "이미 끝난 일"이 되었을 때 접히는 작은 한 줄 카드.
/// 절약보너스·이자·용돈 카드가 공유한다(예전엔 파일마다 같은 걸 따로 갖고 있었음).
class MiniBar extends StatelessWidget {
  final PastelPair pair;
  final String text;
  final VoidCallback onTap;
  final IconData icon;

  const MiniBar({
    super.key,
    required this.pair,
    required this.text,
    required this.onTap,
    this.icon = Icons.check_circle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: pair.bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 19, color: pair.fg),
              const SizedBox(width: AppGap.cozy),
              Expanded(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: AppText.body, fontWeight: FontWeight.w600, color: pair.fg)),
              ),
              Icon(Icons.expand_more, size: 18, color: pair.fg.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 파스텔 배경의 통계 타일 (총수입/총소비/저축 등).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final PastelPair pair;
  final IconData icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.pair,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppGap.md),
      decoration: BoxDecoration(color: pair.bg, borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: pair.fg),
          const SizedBox(height: AppGap.cozy),
          Text(label,
              style: TextStyle(fontSize: AppText.label, fontWeight: FontWeight.w600, color: pair.fg)),
          const SizedBox(height: AppGap.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    fontSize: AppText.titleLg,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: pair.fg)),
          ),
        ],
      ),
    );
  }
}

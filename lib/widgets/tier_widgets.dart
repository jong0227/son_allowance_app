import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_database.dart';
import '../providers/tier_provider.dart';
import '../utils/formatters.dart';

/// 이스터에그: 등급 아이콘을 연속 10번 누르면 블럭이 터지는 애니메이션.
class TierEasterEggIcon extends StatefulWidget {
  final Tier tier;
  final double size;
  const TierEasterEggIcon({super.key, required this.tier, this.size = 26});

  @override
  State<TierEasterEggIcon> createState() => _TierEasterEggIconState();
}

class _TierEasterEggIconState extends State<TierEasterEggIcon> {
  int _count = 0;
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  void _onTap() {
    final now = DateTime.now();
    // 이전 탭 후 2초 안에 다음 탭이면 카운트 유지(천천히 눌러도 됨). 넘으면 리셋.
    if (now.difference(_last) > const Duration(seconds: 2)) _count = 0;
    _last = now;
    _count++;
    if (_count >= 3) HapticFeedback.selectionClick();
    if (_count >= 10) {
      _count = 0;
      HapticFeedback.heavyImpact();
      showTierCelebration(context, widget.tier);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: TierIcon(tier: widget.tier, size: widget.size),
    );
  }
}

/// 블럭 터짐 축하 애니메이션(풀스크린 오버레이). 탭하거나 끝나면 닫힘.
void showTierCelebration(BuildContext context, Tier tier) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'tier-celebrate',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (_, __, ___) => _TierBurst(tier: tier),
  );
}

class _Particle {
  final double angle;
  final double speed;
  final double spin;
  final double size;
  _Particle(this.angle, this.speed, this.spin, this.size);
}

class _TierBurst extends StatefulWidget {
  final Tier tier;
  const _TierBurst({required this.tier});
  @override
  State<_TierBurst> createState() => _TierBurstState();
}

class _TierBurstState extends State<_TierBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _parts;
  late final List<_Particle> _sparks;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _parts = List.generate(30, (_) {
      final ang = rnd.nextDouble() * 2 * pi;
      final speed = 150 + rnd.nextDouble() * 220;
      final spin = rnd.nextDouble() * 5 - 2.5;
      final size = 14 + rnd.nextDouble() * 20;
      return _Particle(ang, speed, spin, size);
    });
    _sparks = List.generate(14, (_) {
      final ang = rnd.nextDouble() * 2 * pi;
      final speed = 90 + rnd.nextDouble() * 240;
      final size = 6 + rnd.nextDouble() * 8;
      return _Particle(ang, speed, 0, size);
    });
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..forward();
    // 터질 때 진동 몇 번
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 90), () => HapticFeedback.mediumImpact());
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.lightImpact());
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final en = tierEnglishName(widget.tier.id);
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final pop = Curves.elasticOut.transform((t / 0.5).clamp(0.0, 1.0));
            final scale = 0.15 + pop * 1.05;
            // 팝 이후 은은한 맥동
            final pulse = 1 + sin(t * pi * 6) * 0.05 * (t > 0.5 ? 1 : 0);
            final spin = Curves.easeOut.transform(t) * 2 * pi; // 한 바퀴 회전
            final ringT = Curves.easeOut.transform((t / 0.6).clamp(0.0, 1.0));
            final flash = (1 - (t / 0.25)).clamp(0.0, 1.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 320,
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 빛 번짐(플래시)
                      Opacity(
                        opacity: flash * 0.9,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                                colors: [Colors.white, Colors.transparent]),
                          ),
                        ),
                      ),
                      // 충격파 링
                      Opacity(
                        opacity: (1 - ringT) * 0.7,
                        child: Container(
                          width: 60 + ringT * 250,
                          height: 60 + ringT * 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 4 * (1 - ringT) + 1),
                          ),
                        ),
                      ),
                      // 반짝이 스파크
                      for (final p in _sparks)
                        Transform.translate(
                          offset: Offset(cos(p.angle) * p.speed * t,
                              sin(p.angle) * p.speed * t),
                          child: Opacity(
                            opacity: (1 - t).clamp(0.0, 1.0),
                            child: Icon(Icons.star,
                                size: p.size, color: Colors.amberAccent),
                          ),
                        ),
                      // 튀는 블럭 파티클
                      for (final p in _parts)
                        Transform.translate(
                          offset: Offset(cos(p.angle) * p.speed * t,
                              sin(p.angle) * p.speed * t + 240 * t * t),
                          child: Opacity(
                            opacity: (1 - t).clamp(0.0, 1.0),
                            child: Transform.rotate(
                              angle: p.spin * t * pi,
                              child: TierIcon(tier: widget.tier, size: p.size),
                            ),
                          ),
                        ),
                      // 가운데 큰 블럭 (팝 + 회전 + 맥동)
                      Transform.rotate(
                        angle: spin,
                        child: Transform.scale(
                          scale: scale * pulse,
                          child: TierIcon(tier: widget.tier, size: 96),
                        ),
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: pop.clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      Text('🎉 ${widget.tier.title}! 🎉',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5)),
                      if (en != null)
                        Text(en,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 티어 아이콘. 우선순위: 내가 넣은 이미지 → 기본 번들 이미지 → 이모지.
class TierIcon extends ConsumerWidget {
  final Tier tier;
  final double size;
  const TierIcon({super.key, required this.tier, this.size = 28});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom = ref.watch(tierIconPathsProvider)[tier.id];
    final dim = size * 1.15;
    Widget emoji() => Text(tier.icon, style: TextStyle(fontSize: size));
    Widget bundled() {
      final path = tierAssetPath(tier.id);
      if (path == null) return emoji();
      return Image.asset(path,
          width: dim,
          height: dim,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, __, ___) => emoji());
    }

    if (custom != null && custom.isNotEmpty) {
      return Image.file(File(custom),
          width: dim,
          height: dim,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, __, ___) => bundled());
    }
    return bundled();
  }
}

/// 앱 상단 제목 옆에 붙는 컴팩트 티어 배지 (아이콘 + 칭호).
class TierBadge extends StatelessWidget {
  final Tier tier;
  final String? label; // 위에 붙는 작은 라벨(부자 등급 / 주간 저축률 등)
  const TierBadge({super.key, required this.tier, this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TierIcon(tier: tier, size: 13),
          const SizedBox(width: 4),
          Text(tier.title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: scheme.onPrimaryContainer)),
        ],
      ),
    );
    if (label == null) return badge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label!,
            style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant)),
        const SizedBox(height: 1),
        badge,
      ],
    );
  }
}

/// 홈 상단 큰 티어 카드: 현재 칭호 + 다음 티어까지 진행바 + 티어표(?) 버튼.
/// 홈 상단에 나란히 놓는 컴팩트 티어 카드(누적/주간 공용).
/// - 위에 작은 라벨(부자 등급 / 주간 저축률)
/// - 아이콘 + 칭호(+영문) + 진행바 + 다음까지 안내
/// - 오른쪽 위 ? 버튼 → 해당 종류 티어표
class TierSummaryCard extends StatelessWidget {
  final String label;
  final List<Tier> tiers;
  final int value; // 누적: 원, 주간: 저축률%
  final bool isPercent;
  const TierSummaryCard({
    super.key,
    required this.label,
    required this.tiers,
    required this.value,
    this.isPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pos = tierFor(tiers, value);
    final cur = pos.current;
    final en = cur != null ? tierEnglishName(cur.id) : null;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8))),
                const Spacer(),
                InkWell(
                  onTap: () => showTierTable(context, tiers, value, isPercent: isPercent),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.help_outline,
                        size: 17, color: scheme.onPrimaryContainer.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (cur != null)
                  TierEasterEggIcon(tier: cur, size: 26)
                else
                  const Text('🟫'),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cur?.title ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: scheme.onPrimaryContainer)),
                      if (en != null)
                        Text(en,
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: scheme.onPrimaryContainer.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pos.progress,
                minHeight: 7,
                backgroundColor: scheme.onPrimaryContainer.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _footer(pos),
              maxLines: 2,
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.95)),
            ),
          ],
        ),
      ),
    );
  }

  String _footer(TierPosition pos) {
    if (isPercent) {
      final pct = value;
      if (pos.next == null) return '이번 주 저축률 $pct% · 최고!';
      return '이번 주 $pct% · 다음 ${pos.next!.threshold}%';
    }
    if (pos.next == null) return '최고 티어! 🎉';
    return '다음까지 ${formatWon(pos.remaining ?? 0)}';
  }
}

/// 전체 티어표 모달. 현재 티어 하이라이트 + (누적)보상 표시.
void showTierTable(BuildContext context, List<Tier> tiers, int value,
    {bool isPercent = false}) {
  final pos = tierFor(tiers, value);
  final currentId = pos.current?.id;
  String threshText(Tier t) => isPercent ? '${t.threshold}% 이상' : formatWon(t.threshold);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Text(isPercent ? '주간 저축률 티어표' : '누적 저축 티어표',
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(
                isPercent
                    ? '이번 주 저축률 $value% · 현재 "${pos.current?.title ?? '-'}"'
                    : '총 저축 ${formatWon(value)} · 현재 "${pos.current?.title ?? '흙'}"',
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            for (final t in tiers)
              Card(
                color: t.id == currentId ? scheme.primaryContainer : null,
                child: ListTile(
                  leading: TierIcon(tier: t, size: 26),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(t.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: t.id == currentId ? scheme.onPrimaryContainer : null)),
                      ),
                      if (tierEnglishName(t.id) != null) ...[
                        const SizedBox(width: 6),
                        Text(tierEnglishName(t.id)!,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (t.id == currentId
                                        ? scheme.onPrimaryContainer
                                        : scheme.onSurfaceVariant)
                                    .withValues(alpha: 0.7))),
                      ],
                      if (t.id == currentId) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle, size: 16, color: scheme.primary),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${threshText(t)}${t.reward != null && t.reward!.isNotEmpty ? '\n🎁 ${t.reward}' : ''}',
                    style: TextStyle(
                        color: t.id == currentId
                            ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
                            : scheme.onSurfaceVariant),
                  ),
                  isThreeLine: t.reward != null && t.reward!.isNotEmpty,
                ),
              ),
          ],
        ),
      );
    },
  );
}

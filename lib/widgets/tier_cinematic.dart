import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/app_database.dart';
import '../providers/tier_provider.dart';

/// 티어 축하 시네마틱(풀스크린).
/// 블럭 낙하 → 채굴 → 파괴 → 아이템 등장 → 칭호 + 폭죽 5단계로 이어지는 연출.
/// 마인크래프트 느낌을 살리려고 전부 픽셀 블럭(사각형)으로 그린다.
void showTierCinematic(BuildContext context, Tier tier) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'tier-cinematic',
    barrierColor: Colors.black.withValues(alpha: 0.86),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => _TierCinematic(tier: tier),
  );
}

/// 티어별 대표 색. 마인크래프트 블럭 느낌으로 순서에 따라 흙→돌→금속→보석→네더 계열.
({Color base, Color light, Color dark, bool shimmer}) tierPalette(Tier tier) {
  const map = <String, (int, int, int)>{
    'sav_01': (0x8B5A2B, 0xA9713C, 0x5E3C1C), // 흙
    'sav_02': (0x9C6B3F, 0xB98352, 0x6B4728), // 나무
    'sav_03': (0x8FBF5A, 0xAAD673, 0x5F8A38), // 씨앗
    'sav_04': (0xD9B84C, 0xEBCF6B, 0x9C8130), // 밀
    'sav_05': (0xBFE3EA, 0xE0F3F7, 0x86AEB6), // 유리
    'sav_06': (0x3A3A3A, 0x555555, 0x1E1E1E), // 석탄
    'sav_07': (0x3D7FD1, 0x5EA0EC, 0x27548C), // 물
    'sav_08': (0xCFCFCF, 0xE8E8E8, 0x9A9A9A), // 안산암
    'sav_09': (0x9A9A9A, 0xB6B6B6, 0x6E6E6E), // 돌
    'sav_10': (0xC5713F, 0xE08C57, 0x8C4C29), // 구리
    'sav_11': (0xD8D8D8, 0xF0F0F0, 0xA0A0A0), // 철
    'sav_12': (0xF2C13C, 0xFFDA6B, 0xB08A1E), // 금
    'sav_13': (0x2A5BC4, 0x4A7FE8, 0x1A3C88), // 청금석
    'sav_14': (0xD2352C, 0xEE5A50, 0x8F211B), // 레드스톤
    'sav_15': (0x35C77B, 0x5CE79C, 0x1F8A52), // 에메랄드
    'sav_16': (0x4FE3E0, 0x86F2F0, 0x2AA3A1), // 다이아
    'sav_17': (0x4A4048, 0x6A5D68, 0x2C252A), // 네더라이트
    'sav_18': (0x2B2438, 0x453A57, 0x171223), // 흑요석
    'sav_19': (0x7B3FBF, 0x9E63E0, 0x51267E), // 네더 포탈
    'sav_20': (0x7FE8DA, 0xB4F5EC, 0x49A99C), // 신호기
    'sav_21': (0xC9B98A, 0xE3D6AF, 0x8E815C), // 엔더 유적
    'sav_22': (0x2E7D5B, 0x49A87C, 0x1B4E38), // 엔더 포탈
    'sav_23': (0x1A1A22, 0x3A3A48, 0x0C0C11), // 엔더 드래곤
    'sav_24': (0xF7F0C8, 0xFFFBE6, 0xBFB790), // 네더의 별
    'sav_25': (0xE8B7F0, 0xF6D8FA, 0xAE7FB6), // 엔드 수정
    'sav_26': (0x6E4B2A, 0x8E6640, 0x452D18), // 히로빈
    'sav_27': (0xE04A2F, 0xF57150, 0x9C3220), // 모장
  };
  final v = map[tier.id];
  final base = Color(0xFF000000 | (v?.$1 ?? 0x7FA8D0));
  final light = Color(0xFF000000 | (v?.$2 ?? 0xA9C9E8));
  final dark = Color(0xFF000000 | (v?.$3 ?? 0x52708C));
  // 상위 티어(다이아 이상)는 무지갯빛 반짝임을 더한다.
  return (base: base, light: light, dark: dark, shimmer: tier.sortOrder >= 16);
}

class _TierCinematic extends StatefulWidget {
  final Tier tier;
  const _TierCinematic({required this.tier});

  @override
  State<_TierCinematic> createState() => _TierCinematicState();
}

class _TierCinematicState extends State<_TierCinematic>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 6200);
  late final AnimationController _c;
  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _total)..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) Navigator.of(context).maybePop();
    });
    // 단계별 진동 — 착지, 곡괭이 타격 3회, 파괴, 아이템 등장
    _haptic(900, HapticFeedback.mediumImpact);
    _haptic(1500, HapticFeedback.lightImpact);
    _haptic(1900, HapticFeedback.lightImpact);
    _haptic(2300, HapticFeedback.lightImpact);
    _haptic(2750, HapticFeedback.heavyImpact);
    _haptic(3500, HapticFeedback.mediumImpact);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _canDismiss = true);
    });
  }

  void _haptic(int ms, VoidCallback f) {
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) f();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;
    final en = tierEnglishName(tier.id);
    final pal = tierPalette(tier);

    return GestureDetector(
      onTap: () {
        if (_canDismiss) Navigator.of(context).maybePop();
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // 파괴 순간 화면 흔들림
          final shake = _shakeOffset(t);
          return Transform.translate(
            offset: shake,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CinematicPainter(t: t, pal: pal, tier: tier),
                  ),
                ),
                // 아이템(이모지)은 텍스트라 페인터 위에 따로 얹는다.
                if (t > 0.45)
                  Positioned.fill(child: Center(child: _buildItem(t, pal))),
                if (t > 0.60)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).size.height * 0.18,
                    child: _buildTitle(t, en, pal),
                  ),
                if (_canDismiss)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 28,
                    child: Opacity(
                      opacity: 0.5,
                      child: Text('화면을 누르면 닫혀요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Offset _shakeOffset(double t) {
    // 2.6~3.0초 구간(파괴)에서 짧게 흔들림
    const from = 2600 / 6200, to = 3000 / 6200;
    if (t < from || t > to) return Offset.zero;
    final k = (t - from) / (to - from);
    final decay = (1 - k);
    return Offset(sin(k * pi * 14) * 9 * decay, cos(k * pi * 11) * 6 * decay);
  }

  Widget _buildItem(double t, ({Color base, Color light, Color dark, bool shimmer}) pal) {
    // 0.45~0.62: 솟아오르며 커짐 → 이후 부드럽게 회전 느낌으로 살짝 흔들림
    final k = ((t - 0.45) / 0.17).clamp(0.0, 1.0);
    final rise = Curves.easeOutBack.transform(k);
    final float = sin((t - 0.62) * 2 * pi * 1.1) * 6;
    return Transform.translate(
      offset: Offset(0, (1 - rise) * 90 + (t > 0.62 ? float : 0)),
      child: Transform.scale(
        scale: 0.4 + rise * 0.6,
        child: Text(widget.tier.icon, style: const TextStyle(fontSize: 96)),
      ),
    );
  }

  Widget _buildTitle(
      double t, String? en, ({Color base, Color light, Color dark, bool shimmer}) pal) {
    final k = ((t - 0.60) / 0.12).clamp(0.0, 1.0);
    final eased = Curves.easeOutBack.transform(k);
    return Opacity(
      opacity: k.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 0.7 + eased * 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.tier.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: pal.light,
                  shadows: [
                    Shadow(color: pal.dark, offset: const Offset(0, 3), blurRadius: 0),
                    Shadow(
                        color: pal.base.withValues(alpha: 0.9),
                        blurRadius: 24),
                  ],
                )),
            if (en != null) ...[
              const SizedBox(height: 4),
              Text(en.toUpperCase(),
                  style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.75))),
            ],
            if (widget.tier.reward != null && widget.tier.reward!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: pal.base.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pal.light.withValues(alpha: 0.55), width: 1.5),
                ),
                child: Text('🎁 ${widget.tier.reward}',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: pal.light)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 5단계 연출을 한 캔버스에 그린다.
/// 0.00~0.15 블럭 낙하 / 0.15~0.42 채굴(금 가기) / 0.42~0.50 파괴
/// 0.45~0.65 광선+아이템 등장 / 0.60~1.00 폭죽
class _CinematicPainter extends CustomPainter {
  final double t;
  final ({Color base, Color light, Color dark, bool shimmer}) pal;
  final Tier tier;
  _CinematicPainter({required this.t, required this.pal, required this.tier});

  static final _rnd = Random(11);
  static final _falling = List.generate(
      18,
      (i) => (
            x: _rnd.nextDouble(),
            delay: _rnd.nextDouble() * 0.09,
            size: 16 + _rnd.nextDouble() * 22,
            spin: _rnd.nextDouble() * 2 - 1,
          ));
  static final _shards = List.generate(
      44,
      (i) => (
            angle: _rnd.nextDouble() * 2 * pi,
            speed: 120 + _rnd.nextDouble() * 340,
            size: 6 + _rnd.nextDouble() * 16,
            spin: _rnd.nextDouble() * 6 - 3,
          ));
  static final _fireworks = List.generate(
      5,
      (i) => (
            cx: 0.15 + _rnd.nextDouble() * 0.7,
            cy: 0.18 + _rnd.nextDouble() * 0.35,
            delay: 0.60 + i * 0.07,
            n: 10 + _rnd.nextInt(8),
            r: 60 + _rnd.nextDouble() * 70,
          ));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);

    _paintBackglow(canvas, size, center);
    if (t < 0.50) _paintFalling(canvas, size);
    if (t >= 0.10 && t < 0.50) _paintBlock(canvas, center);
    if (t >= 0.42) _paintShards(canvas, center);
    if (t >= 0.42 && t < 0.72) _paintBeam(canvas, size, center);
    if (t >= 0.50) _paintSparkles(canvas, center);
    if (t >= 0.60) _paintFireworks(canvas, size);
  }

  /// 뒤에서 은은하게 번지는 티어 색 발광.
  void _paintBackglow(Canvas canvas, Size size, Offset center) {
    final k = ((t - 0.40) / 0.25).clamp(0.0, 1.0);
    if (k <= 0) return;
    final radius = size.shortestSide * (0.35 + 0.35 * k);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          pal.base.withValues(alpha: 0.55 * k),
          pal.base.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  /// 1단계: 픽셀 블럭들이 위에서 떨어진다.
  void _paintFalling(Canvas canvas, Size size) {
    for (final b in _falling) {
      final k = ((t - b.delay) / 0.16).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final fade = t > 0.42 ? (1 - ((t - 0.42) / 0.08)).clamp(0.0, 1.0) : 1.0;
      final y = Curves.easeInQuad.transform(k) * (size.height * 0.46) - 60;
      _pixelBlock(
        canvas,
        Offset(b.x * size.width, y),
        b.size,
        opacity: 0.55 * fade,
        rotation: b.spin * k * 1.2,
      );
    }
  }

  /// 2단계: 가운데 큰 블럭 + 채굴 균열.
  void _paintBlock(Canvas canvas, Offset center) {
    final appear = ((t - 0.10) / 0.06).clamp(0.0, 1.0);
    final vanish = t > 0.42 ? ((t - 0.42) / 0.06).clamp(0.0, 1.0) : 0.0;
    if (vanish >= 1) return;
    final s = 110.0 * appear * (1 - vanish * 0.35);
    // 타격할 때마다 살짝 눌리는 느낌
    final hit = _hitSquash();
    _pixelBlock(canvas, center, s,
        opacity: 1 - vanish, squashY: hit, big: true);

    // 균열: 채굴이 진행될수록 늘어난다
    final crack = ((t - 0.18) / 0.24).clamp(0.0, 1.0);
    if (crack <= 0) return;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55 * (1 - vanish))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    final half = s / 2;
    final lines = <List<Offset>>[
      [const Offset(-0.4, -0.5), const Offset(-0.1, 0.0), const Offset(-0.35, 0.45)],
      [const Offset(0.35, -0.45), const Offset(0.05, 0.05), const Offset(0.4, 0.5)],
      [const Offset(-0.5, 0.15), const Offset(0.0, 0.2), const Offset(0.45, 0.05)],
    ];
    for (var i = 0; i < lines.length; i++) {
      final show = ((crack - i * 0.25) / 0.3).clamp(0.0, 1.0);
      if (show <= 0) continue;
      final pts = lines[i];
      for (var j = 0; j < pts.length - 1; j++) {
        final a = center + Offset(pts[j].dx * half, pts[j].dy * half);
        final bpt = center + Offset(pts[j + 1].dx * half, pts[j + 1].dy * half);
        canvas.drawLine(a, Offset.lerp(a, bpt, show)!, paint);
      }
    }
  }

  /// 곡괭이 타격 3번에 맞춰 블럭이 눌렸다 펴진다.
  double _hitSquash() {
    const hits = [0.24, 0.30, 0.36];
    for (final h in hits) {
      final d = (t - h).abs();
      if (d < 0.02) return 1 - (0.02 - d) / 0.02 * 0.18;
    }
    return 1.0;
  }

  /// 3단계: 블럭이 부서져 파편이 사방으로.
  void _paintShards(Canvas canvas, Offset center) {
    final k = ((t - 0.42) / 0.34).clamp(0.0, 1.0);
    if (k <= 0 || k >= 1) return;
    final ease = Curves.easeOutCubic.transform(k);
    for (final s in _shards) {
      final d = s.speed * ease;
      final gravity = 220 * ease * ease;
      final p = center + Offset(cos(s.angle) * d, sin(s.angle) * d + gravity);
      _pixelBlock(canvas, p, s.size * (1 - k * 0.45),
          opacity: (1 - k), rotation: s.spin * ease);
    }
  }

  /// 4단계: 아이템을 비추는 빛기둥.
  void _paintBeam(Canvas canvas, Size size, Offset center) {
    final k = ((t - 0.42) / 0.12).clamp(0.0, 1.0);
    final fade = t > 0.64 ? (1 - (t - 0.64) / 0.08).clamp(0.0, 1.0) : 1.0;
    if (k <= 0 || fade <= 0) return;
    final w = 120.0 * k;
    final rect = Rect.fromLTRB(center.dx - w / 2, 0, center.dx + w / 2, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          pal.light.withValues(alpha: 0.0),
          pal.light.withValues(alpha: 0.30 * fade),
          pal.light.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  /// 아이템 주변을 도는 반짝임.
  void _paintSparkles(Canvas canvas, Offset center) {
    final k = ((t - 0.50) / 0.12).clamp(0.0, 1.0);
    if (k <= 0) return;
    final n = pal.shimmer ? 14 : 9;
    for (var i = 0; i < n; i++) {
      final a = (t * 1.4 + i / n) * 2 * pi;
      final r = 92 + sin(t * 6 + i) * 14;
      final p = center + Offset(cos(a) * r, sin(a) * r * 0.7);
      final size = 4 + (sin(t * 9 + i * 2) + 1) * 2.5;
      final color = pal.shimmer
          ? HSVColor.fromAHSV(1, ((t * 220 + i * 40) % 360), 0.7, 1).toColor()
          : pal.light;
      canvas.drawRect(
        Rect.fromCenter(center: p, width: size, height: size),
        Paint()..color = color.withValues(alpha: 0.85 * k),
      );
    }
  }

  /// 5단계: 폭죽.
  void _paintFireworks(Canvas canvas, Size size) {
    for (final f in _fireworks) {
      final k = ((t - f.delay) / 0.30).clamp(0.0, 1.0);
      if (k <= 0 || k >= 1) continue;
      final ease = Curves.easeOutCubic.transform(k);
      final c = Offset(f.cx * size.width, f.cy * size.height);
      for (var i = 0; i < f.n; i++) {
        final a = i / f.n * 2 * pi;
        final p = c + Offset(cos(a), sin(a)) * (f.r * ease);
        final color = pal.shimmer
            ? HSVColor.fromAHSV(1, ((i / f.n) * 360 + t * 120) % 360, 0.65, 1).toColor()
            : pal.light;
        canvas.drawRect(
          Rect.fromCenter(center: p, width: 6, height: 6),
          Paint()..color = color.withValues(alpha: (1 - k) * 0.95),
        );
      }
    }
  }

  /// 마인크래프트풍 픽셀 블럭 하나(윗면 밝게, 아랫면 어둡게).
  void _pixelBlock(
    Canvas canvas,
    Offset center,
    double size, {
    double opacity = 1,
    double rotation = 0,
    double squashY = 1,
    bool big = false,
  }) {
    if (size <= 0 || opacity <= 0) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0) canvas.rotate(rotation);
    canvas.scale(1, squashY);
    final h = size / 2;
    final r = Rect.fromLTRB(-h, -h, h, h);
    canvas.drawRect(r, Paint()..color = pal.base.withValues(alpha: opacity));
    // 윗면/왼쪽 하이라이트
    final edge = size * 0.16;
    canvas.drawRect(Rect.fromLTRB(-h, -h, h, -h + edge),
        Paint()..color = pal.light.withValues(alpha: opacity));
    canvas.drawRect(Rect.fromLTRB(-h, -h, -h + edge, h),
        Paint()..color = pal.light.withValues(alpha: opacity * 0.65));
    // 아래/오른쪽 그림자
    canvas.drawRect(Rect.fromLTRB(-h, h - edge, h, h),
        Paint()..color = pal.dark.withValues(alpha: opacity));
    canvas.drawRect(Rect.fromLTRB(h - edge, -h, h, h),
        Paint()..color = pal.dark.withValues(alpha: opacity * 0.75));
    if (big) {
      // 큰 블럭엔 픽셀 질감을 살짝 넣는다
      final dot = Paint()..color = pal.dark.withValues(alpha: opacity * 0.25);
      for (var i = 0; i < 5; i++) {
        for (var j = 0; j < 5; j++) {
          if ((i * 7 + j * 3) % 4 != 0) continue;
          final cell = size / 6;
          canvas.drawRect(
            Rect.fromLTWH(-h + edge + i * cell, -h + edge + j * cell, cell * 0.7, cell * 0.7),
            dot,
          );
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CinematicPainter old) => old.t != t;
}

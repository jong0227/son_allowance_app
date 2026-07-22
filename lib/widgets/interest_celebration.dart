import 'dart:math';
import 'package:flutter/material.dart';
import '../services/interest_calc.dart';
import '../utils/formatters.dart';
import 'ui_kit.dart';

/// 이자를 받았을 때 띄우는 축하 연출.
/// 동전이 쏟아지고 금액이 0부터 올라가며, 은행 대비 몇 배인지 강조한다.
Future<void> showInterestCelebration(
  BuildContext context, {
  required InterestBreakdown breakdown,
  bool auto = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _InterestCelebrationDialog(breakdown: breakdown, auto: auto),
  );
}

class _InterestCelebrationDialog extends StatefulWidget {
  final InterestBreakdown breakdown;
  final bool auto;
  const _InterestCelebrationDialog({required this.breakdown, required this.auto});

  @override
  State<_InterestCelebrationDialog> createState() => _InterestCelebrationDialogState();
}

class _InterestCelebrationDialogState extends State<_InterestCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.breakdown;
    final pair = appPalette(context).income;
    final multiple = b.multipleOfBank;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_c.value.clamp(0.0, 1.0));
          final amountShown = (b.amount * t).round();
          return Transform.scale(
            scale: 0.85 + 0.15 * t,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              decoration: BoxDecoration(
                color: pair.bg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 92,
                    child: CustomPaint(
                      size: const Size(double.infinity, 92),
                      painter: _CoinRainPainter(progress: _c.value, color: pair.fg),
                      child: Center(
                        child: Transform.scale(
                          scale: 0.8 + 0.4 * t,
                          child: const Text('💰', style: TextStyle(fontSize: 46)),
                        ),
                      ),
                    ),
                  ),
                  Text(widget.auto ? '이자가 들어왔어요!' : '이자를 받았어요!',
                      style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w900, color: pair.fg)),
                  const SizedBox(height: 8),
                  Text('+${formatWon(amountShown)}',
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: pair.fg)),
                  if (multiple != null) ...[
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: (t - 0.4).clamp(0.0, 1.0) / 0.6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                            color: pair.fg.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('은행의 ${formatPercent(multiple)}배!',
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: pair.fg)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('은행에 맡겼다면 ${formatWon(b.bankAmount)}였어요',
                        style: TextStyle(fontSize: 12.5, color: pair.fg)),
                  ],
                  if (widget.auto) ...[
                    const SizedBox(height: 8),
                    Text('지난 주에 안 받아서 자동으로 넣어뒀어요',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, height: 1.4, color: pair.fg)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('좋아!'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 위에서 동전이 쏟아져 내리는 배경 효과.
class _CoinRainPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CoinRainPainter({required this.progress, required this.color});

  static final _rnd = Random(7);
  static final List<({double x, double delay, double size})> _coins = List.generate(
    14,
    (_) => (
      x: _rnd.nextDouble(),
      delay: _rnd.nextDouble() * 0.5,
      size: 4 + _rnd.nextDouble() * 5,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final c in _coins) {
      final t = ((progress - c.delay) / (1 - c.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final y = -10 + t * (size.height + 20);
      final fade = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2);
      paint.color = color.withValues(alpha: 0.35 * fade);
      canvas.drawCircle(Offset(c.x * size.width, y), c.size, paint);
    }
  }

  @override
  bool shouldRepaint(_CoinRainPainter old) => old.progress != progress;
}

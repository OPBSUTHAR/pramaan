import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scam_engine/scam_engine.dart';

import '../theme/app_colors.dart';
import '../l10n/l10n.dart';

/// The app mark: a shield whose tick is a rupee stroke. Drawn, not an asset,
/// so it stays crisp at every size and adds zero bytes to the bundle.
class PramaanMark extends StatelessWidget {
  const PramaanMark({super.key, this.size = 44, this.glow = false});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.saffron, AppColors.saffronDeep],
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.saffron.withValues(alpha: 0.45),
                  blurRadius: size * 0.6,
                  spreadRadius: size * 0.04,
                ),
              ]
            : null,
      ),
      child: CustomPaint(painter: _ShieldPainter()),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = Paint()
      ..color = const Color(0xFF1A1200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shield = Path()
      ..moveTo(s * 0.5, s * 0.2)
      ..lineTo(s * 0.76, s * 0.3)
      ..lineTo(s * 0.76, s * 0.52)
      ..cubicTo(s * 0.76, s * 0.68, s * 0.63, s * 0.78, s * 0.5, s * 0.84)
      ..cubicTo(s * 0.37, s * 0.78, s * 0.24, s * 0.68, s * 0.24, s * 0.52)
      ..lineTo(s * 0.24, s * 0.3)
      ..close();
    canvas.drawPath(shield, stroke);

    final tick = Path()
      ..moveTo(s * 0.37, s * 0.5)
      ..lineTo(s * 0.46, s * 0.59)
      ..lineTo(s * 0.64, s * 0.4);
    canvas.drawPath(tick, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The big verdict dial on the result screen.
class RiskGauge extends StatelessWidget {
  const RiskGauge({
    required this.score,
    required this.level,
    super.key,
    this.size = 216,
    this.animate = true,
  });

  final int score;
  final RiskLevel level;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forRisk(level);
    final target = (score / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: animate ? 0 : target, end: target),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _GaugePainter(progress: value, color: color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).round()}',
                    style: TextStyle(
                      fontSize: size * 0.29,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      color: color,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t('result.of100'),
                    style: TextStyle(
                      fontSize: size * 0.055,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - 10,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.055
      ..strokeCap = StrokeCap.round
      ..color = AppColors.inkLine;
    canvas.drawArc(rect, _start, _sweep, false, track);

    if (progress <= 0) return;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.075
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawArc(rect, _start, _sweep * progress, false, glow);

    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.055
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: _start,
        endAngle: _start + _sweep,
        colors: [color.withValues(alpha: 0.55), color],
        transform: GradientRotation(_start),
      ).createShader(rect);
    canvas.drawArc(rect, _start, _sweep * progress, false, sweep);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.color != color;
}

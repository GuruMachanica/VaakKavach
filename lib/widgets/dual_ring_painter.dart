import 'dart:math';
import 'package:flutter/material.dart';
import '../core/colors.dart';

class DualRingPainter extends CustomPainter {
  final double outerScore;
  final double innerScore;
  final Color primaryColor;

  const DualRingPainter({
    required this.outerScore,
    required this.innerScore,
    required this.primaryColor,
  });

  static const double _start = -pi / 2;
  static const double _sweep = 2 * pi;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = size.width * 0.44;
    final innerRadius = size.width * 0.36;

    final outerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), outerRadius, outerTrackPaint);

    final innerTrackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), innerRadius, innerTrackPaint);

    if (outerScore > 0) {
      final outerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * pi,
          colors: [
            accentCyan,
            outerScore >= 0.65
                ? riskRed
                : (outerScore >= 0.35 ? riskYellow : accentEmerald),
          ],
          transform: const GradientRotation(-pi / 2),
        ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: outerRadius));

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: outerRadius),
        _start,
        _sweep * outerScore,
        false,
        outerPaint,
      );
    }

    if (innerScore > 0) {
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.028
        ..strokeCap = StrokeCap.round
        ..color = innerScore >= 0.65 ? riskRed : accentCyan;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: innerRadius),
        _start,
        _sweep * innerScore,
        false,
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(DualRingPainter old) =>
      old.outerScore != outerScore ||
      old.innerScore != innerScore ||
      old.primaryColor != primaryColor;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final double rms;
  final double phase;
  final Color color;
  final bool isSpeech;
  final math.Random random;

  WaveformPainter({
    required this.rms,
    required this.phase,
    required this.color,
    required this.isSpeech,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 36;
    final barWidth = (size.width - (barCount * 3)) / barCount;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(2.0, barWidth);

    final midY = size.height / 2;
    final boost = (rms * 120).clamp(4.0, size.height * 0.95);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + 3) + barWidth / 2;
      final distFromCenter = (i - barCount / 2).abs() / (barCount / 2);
      final envelope = 1.0 - (distFromCenter * 0.65);
      final sineWave = math.sin((i / 5.0) + (phase * 2 * math.pi));
      final height = math.max(
        3.0,
        boost * envelope * (0.4 + (sineWave * 0.3).abs()),
      );

      final top = midY - (height / 2);
      final bottom = midY + (height / 2);

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        paint..color = color.withValues(alpha: 0.35 + (height / size.height) * 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.rms != rms ||
        oldDelegate.phase != phase ||
        oldDelegate.color != color;
  }
}

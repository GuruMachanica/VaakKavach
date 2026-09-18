import 'package:flutter/material.dart';
import '../../core/colors.dart';

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  const MiniBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BarChartPainter(values));
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  const _BarChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final count = values.length;
    final barW = size.width / (count * 1.8);
    final spacing = size.width / count;

    for (int i = 0; i < count; i++) {
      final h = values[i] * size.height;
      final x = i * spacing + (spacing - barW) / 2;
      final isLatest = i == count - 1;

      final paint = Paint()
        ..color = isLatest ? accentCyan : accentCyan.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, barW, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

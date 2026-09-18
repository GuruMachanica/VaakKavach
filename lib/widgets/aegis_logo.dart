import 'package:flutter/material.dart';
import '../core/colors.dart';

typedef VaakKavachLogo = AegisLogo;

class AegisLogo extends StatelessWidget {
  final double size;
  final String? assetPath;
  final bool showGlow;

  const AegisLogo({
    super.key,
    this.size = 160,
    this.assetPath,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size * 1.15,
              height: size * 1.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    accentEmerald.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _VaakKavachLogoPainter(),
          ),
        ],
      ),
    );
  }
}

class _VaakKavachLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Dark Noir Outer Halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF222222), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.52));
    canvas.drawCircle(center, w * 0.5, haloPaint);

    // 2. Chiseled Noir Kavach (Shield)
    final shieldPath = Path()
      ..moveTo(w * 0.5, h * 0.04)
      ..lineTo(w * 0.94, h * 0.18)
      ..lineTo(w * 0.94, h * 0.54)
      ..quadraticBezierTo(w * 0.94, h * 0.84, w * 0.5, h * 0.98)
      ..quadraticBezierTo(w * 0.06, h * 0.84, w * 0.06, h * 0.54)
      ..lineTo(w * 0.06, h * 0.18)
      ..close();

    final shieldFill = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF161616), Color(0xFF080808), Color(0xFF000000)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final shieldBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.032
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFF71717A), Color(0xFF18181B)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(shieldPath, shieldFill);
    canvas.drawPath(shieldPath, shieldBorder);

    // 3. Inner Razor Hairline
    final innerPath = Path()
      ..moveTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.86, h * 0.24)
      ..lineTo(w * 0.86, h * 0.52)
      ..quadraticBezierTo(w * 0.86, h * 0.78, w * 0.5, h * 0.90)
      ..quadraticBezierTo(w * 0.14, h * 0.78, w * 0.14, h * 0.52)
      ..lineTo(w * 0.14, h * 0.24)
      ..close();

    final innerBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..color = const Color(0xFF3F3F46).withValues(alpha: 0.6);
    canvas.drawPath(innerPath, innerBorder);

    // 4. Acoustic "Vaak" Soundwave Bars (Noir Titanium & Emerald)
    final barPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.038;

    final heights = [0.18, 0.32, 0.48, 0.32, 0.18];
    final barSpacing = w * 0.082;
    final startX = w * 0.5 - (barSpacing * 2);

    for (int i = 0; i < 5; i++) {
      final x = startX + (i * barSpacing);
      final barH = h * heights[i];
      final isCenter = i == 2;

      barPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isCenter
            ? [const Color(0xFFFFFFFF), accentEmerald, const Color(0xFF10B981)]
            : [const Color(0xFFE4E4E7), const Color(0xFF52525B)],
      ).createShader(Rect.fromLTWH(x, h * 0.5 - barH / 2, w * 0.04, barH));

      canvas.drawLine(
        Offset(x, h * 0.51 - barH / 2),
        Offset(x, h * 0.51 + barH / 2),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

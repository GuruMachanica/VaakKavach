import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/colors.dart';
import 'dual_ring_painter.dart';

class RiskGaugeView extends StatelessWidget {
  final double score;
  final double innerScore;
  final double size;
  final String? centerLabel;
  final String? subLabel;

  const RiskGaugeView({
    super.key,
    required this.score,
    required this.innerScore,
    required this.size,
    this.centerLabel,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDanger = score >= 0.65;
    final isWarning = score >= 0.35 && score < 0.65;
    final primaryColor =
        isDanger ? riskRed : (isWarning ? riskYellow : accentCyan);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withValues(alpha: isDanger ? 0.22 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: DualRingPainter(
              outerScore: score,
              innerScore: innerScore,
              primaryColor: primaryColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score * 100).round()}%',
                style: GoogleFonts.rajdhani(
                  color: textPrimary,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: primaryColor.withValues(alpha: 0.6),
                      blurRadius: 16,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (centerLabel != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.08),
                  child: Text(
                    centerLabel!,
                    style: GoogleFonts.rajdhani(
                      color: primaryColor,
                      fontSize: size * 0.075,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              if (subLabel != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.06),
                  child: Text(
                    subLabel!,
                    style: GoogleFonts.rajdhani(
                      color: textSecondary,
                      fontSize: size * 0.065,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

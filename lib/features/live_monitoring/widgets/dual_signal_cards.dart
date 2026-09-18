import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/call_monitor_state.dart';

class DualSignalCards extends StatelessWidget {
  final CallMonitorState state;

  const DualSignalCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SignalMetricBox(
            label: 'AASIST Synthetic',
            score: state.syntheticVoiceScore,
            tag: 'Sub-band DSP',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SignalMetricBox(
            label: 'Scam Coercion',
            score: state.scamChanceScore,
            tag: 'NLP Semantics',
          ),
        ),
      ],
    );
  }
}

class _SignalMetricBox extends StatelessWidget {
  final String label;
  final double score;
  final String tag;

  const _SignalMetricBox({
    required this.label,
    required this.score,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).round();
    final isHigh = pct >= 65;
    final color = isHigh ? riskRed : (pct >= 35 ? riskYellow : accentEmerald);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct%',
                style: GoogleFonts.plusJakartaSans(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/agent_tactical_guidance.dart';

class AgentGuidanceCard extends StatelessWidget {
  final AgentTacticalGuidance guidance;

  const AgentGuidanceCard({super.key, required this.guidance});

  @override
  Widget build(BuildContext context) {
    final isDanger = guidance.stage == AgentCallStage.extractionDanger;
    final isWarning = guidance.stage == AgentCallStage.coercionIsolation;
    final color = isDanger ? riskRed : (isWarning ? riskYellow : accentEmerald);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDanger
                    ? Icons.security_rounded
                    : Icons.lightbulb_outline_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  guidance.stageTitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            guidance.countermeasure,
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bgSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_forward_rounded, color: color, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    guidance.recommendedAction,
                    style: GoogleFonts.plusJakartaSans(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

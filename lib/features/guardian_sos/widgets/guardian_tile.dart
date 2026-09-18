import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/guardian_provider.dart';

class GuardianTile extends StatelessWidget {
  final GuardianContact guardian;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  const GuardianTile({
    super.key,
    required this.guardian,
    required this.onToggle,
    required this.onDelete,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bgSurfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentCyan.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: accentCyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guardian.name,
                  style: GoogleFonts.plusJakartaSans(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  guardian.phone,
                  style: GoogleFonts.jetBrainsMono(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Send Test SOS',
            icon: const Icon(Icons.send_outlined, size: 18, color: accentCyan),
            onPressed: onTest,
          ),
          Switch(
            value: guardian.isActive,
            onChanged: onToggle,
            activeTrackColor: accentCyan,
            inactiveTrackColor: bgSurface,
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close_rounded, size: 18, color: textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../models/call_record.dart';
import '../../models/risk_level.dart';

class RecentCallItem extends StatelessWidget {
  final CallRecord record;

  const RecentCallItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isDanger =
        record.riskLevel == RiskLevel.danger || record.riskScore >= 65;
    final isWarning = record.riskLevel == RiskLevel.suspicious ||
        (record.riskScore >= 35 && !isDanger);

    final statusColor =
        isDanger ? riskRed : (isWarning ? riskYellow : accentEmerald);
    final statusText =
        isDanger ? 'Threat' : (isWarning ? 'Suspicious' : 'Safe');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bgSurfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDanger
                  ? Icons.warning_rounded
                  : (isWarning
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded),
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.callerName.isNotEmpty
                      ? record.callerName
                      : record.phoneNumber,
                  style: GoogleFonts.plusJakartaSans(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  record.phoneNumber,
                  style: GoogleFonts.plusJakartaSans(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('h:mm a').format(record.callTime),
                style:
                    GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

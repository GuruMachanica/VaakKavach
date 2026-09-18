import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../models/call_record.dart';
import '../../models/risk_level.dart';
import 'call_record_details_sheet.dart';

class CallRecordTile extends StatelessWidget {
  final CallRecord record;

  const CallRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, hh:mm a').format(record.callTime);
    final isThreat = record.riskLevel == RiskLevel.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isThreat ? riskRed.withValues(alpha: 0.35) : bgSurfaceBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CallRecordDetailsSheet.show(context, record),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: record.riskLevel.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isThreat ? Icons.shield_outlined : Icons.call_outlined,
                    color: record.riskLevel.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.callerName,
                        style: GoogleFonts.plusJakartaSans(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.phoneNumber,
                        style: GoogleFonts.jetBrainsMono(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          color: textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: record.riskLevel.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${record.riskLevel.label.toUpperCase()} ${record.riskScore}%',
                        style: GoogleFonts.plusJakartaSans(
                          color: record.riskLevel.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (record.isSuspended) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Auto-Quarantined',
                        style: GoogleFonts.plusJakartaSans(
                          color: riskRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../models/call_record.dart';
import '../../models/risk_level.dart';

class CallRecordDetailsSheet extends StatelessWidget {
  final CallRecord record;

  const CallRecordDetailsSheet({super.key, required this.record});

  static void show(BuildContext context, CallRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CallRecordDetailsSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Call Forensic Dossier',
                      style: GoogleFonts.plusJakartaSans(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM dd, yyyy • hh:mm a')
                          .format(record.callTime),
                      style: GoogleFonts.plusJakartaSans(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _infoRow('Caller Entity', record.callerName),
            _infoRow('Telephone', record.phoneNumber),
            _infoRow(
              'Composite Threat',
              '${record.riskScore}%',
              valueColor: record.riskLevel.color,
            ),
            _infoRow(
              'AASIST Voice Synthesis',
              '${record.syntheticScore}%',
              valueColor: record.syntheticScore > 50 ? riskRed : accentEmerald,
            ),
            _infoRow(
              'Semantic Scam Intent',
              '${record.intentScore}%',
              valueColor: record.intentScore > 50 ? riskRed : accentEmerald,
            ),
            _infoRow(
              'Intervention Status',
              record.isSuspended ? 'Terminated & Quarantined' : 'Clean',
              valueColor: record.isSuspended ? riskRed : accentEmerald,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: bgSurface,
                      content: Text(
                        'Forensic audit exported to device storage.',
                        style:
                            GoogleFonts.plusJakartaSans(color: accentEmerald),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Export Audit Report',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String val, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 13),
          ),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              color: valueColor ?? textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

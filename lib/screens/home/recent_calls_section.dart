import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/call_record.dart';
import 'recent_call_item.dart';

class RecentCallsSection extends StatelessWidget {
  final List<CallRecord> calls;
  final VoidCallback onViewAll;

  const RecentCallsSection({
    super.key,
    required this.calls,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.plusJakartaSans(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.plusJakartaSans(
                  color: accentCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (calls.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bgSurfaceBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.history_rounded, color: textMuted, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'No Calls Scanned Yet',
                    style: GoogleFonts.plusJakartaSans(
                      color: textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap "Test Call" above to simulate real-time detection.',
                    style: GoogleFonts.plusJakartaSans(
                      color: textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...calls.map((record) => RecentCallItem(record: record)),
      ],
    );
  }
}


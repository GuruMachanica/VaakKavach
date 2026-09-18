import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/history_provider.dart';

class HistoryFilterDropdown extends StatelessWidget {
  final FilterPeriod current;
  final ValueChanged<FilterPeriod> onSelect;

  const HistoryFilterDropdown({
    super.key,
    required this.current,
    required this.onSelect,
  });

  String _label(FilterPeriod p) => switch (p) {
        FilterPeriod.today => 'Today',
        FilterPeriod.sevenDays => 'Past 7 Days',
      };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FilterPeriod>(
      initialValue: current,
      color: bgElevated,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: bgSurfaceBorder),
      ),
      onSelected: onSelect,
      itemBuilder: (context) => FilterPeriod.values
          .map(
            (p) => PopupMenuItem<FilterPeriod>(
              value: p,
              child: Text(
                _label(p),
                style: GoogleFonts.plusJakartaSans(
                  color: p == current ? accentCyan : textPrimary,
                  fontSize: 13,
                  fontWeight: p == current ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bgSurfaceBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(current),
              style: GoogleFonts.plusJakartaSans(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

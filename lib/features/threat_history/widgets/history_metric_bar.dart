import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/call_record.dart';
import 'mini_bar_chart.dart';

class HistoryMetricBar extends StatelessWidget {
  final List<CallRecord> records;
  final int todayScanned;
  final int threatCount;

  const HistoryMetricBar({
    super.key,
    required this.records,
    required this.todayScanned,
    required this.threatCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Scanned Calls',
            value: '${records.length}',
            caption: '$todayScanned today',
            chart: MiniBarChart(values: _computeBarRatios(records)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Threats Blocked',
            value: '$threatCount',
            caption: '100% neutralized',
            accentColor: threatCount > 0 ? riskRed : accentEmerald,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }

  List<double> _computeBarRatios(List<CallRecord> list) {
    final now = DateTime.now();
    final buckets = List<int>.filled(5, 0);
    for (final r in list) {
      final days = DateTime(now.year, now.month, now.day)
          .difference(DateTime(r.callTime.year, r.callTime.month, r.callTime.day))
          .inDays;
      if (days >= 0 && days < 5) buckets[4 - days]++;
    }
    final maxVal = buckets.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return List<double>.filled(5, 0.15);
    return buckets.map((c) => (c / maxVal).clamp(0.15, 1.0)).toList();
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color? accentColor;
  final Widget? chart;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
    this.accentColor,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bgSurfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: accentColor ?? textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (chart != null) SizedBox(width: 48, height: 28, child: chart),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}


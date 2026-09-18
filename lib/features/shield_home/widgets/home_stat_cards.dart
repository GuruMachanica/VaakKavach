import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';

class HomeStatCards extends StatelessWidget {
  final int todayScanned;
  final int blockedThreatsToday;

  const HomeStatCards({
    super.key,
    required this.todayScanned,
    required this.blockedThreatsToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Protected',
            value: '$todayScanned',
            unit: 'today',
            icon: Icons.shield_outlined,
            color: accentCyan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Intercepted',
            value: '$blockedThreatsToday',
            unit: 'threats',
            icon: Icons.block_flipped,
            color: blockedThreatsToday > 0 ? riskRed : textMuted,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _StatCard(
            label: 'Privacy',
            value: '100%',
            unit: 'on-device',
            icon: Icons.lock_outline_rounded,
            color: accentEmerald,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

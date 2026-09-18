import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';

class ShieldHero extends StatelessWidget {
  final bool isProtected;
  final VoidCallback onToggle;
  final VoidCallback onSimulate;

  const ShieldHero({
    super.key,
    required this.isProtected,
    required this.onToggle,
    required this.onSimulate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bgSurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: (isProtected ? accentEmerald : Colors.transparent)
                .withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isProtected ? accentEmerald : textMuted)
                  .withValues(alpha: 0.12),
              border: Border.all(
                color: (isProtected ? accentEmerald : textMuted)
                    .withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isProtected
                  ? Icons.verified_user_rounded
                  : Icons.shield_outlined,
              color: isProtected ? accentEmerald : textMuted,
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isProtected ? 'Calls Are Protected' : 'Protection Paused',
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isProtected
                ? 'On-device Edge AI is active. Zero audio leaves this phone.'
                : 'Tap below to resume real-time fraud & deepfake scanning.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isProtected
                      ? accentEmerald.withValues(alpha: 0.15)
                      : accentCyan,
                  foregroundColor: isProtected ? accentEmerald : Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: isProtected
                          ? accentEmerald.withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                ),
                onPressed: onToggle,
                icon: Icon(
                  isProtected ? Icons.check_circle_rounded : Icons.power_settings_new_rounded,
                  size: 18,
                ),
                label: Text(
                  isProtected ? 'Shield Active' : 'Enable Shield',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: textPrimary,
                  side: const BorderSide(color: bgSurfaceBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: onSimulate,
                icon: const Icon(Icons.play_arrow_rounded, size: 18, color: accentCyan),
                label: Text(
                  'Test Call',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

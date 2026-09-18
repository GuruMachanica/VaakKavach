import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/call_monitor_state.dart';
import '../../services/audio_watchdog_service.dart';

export 'dual_signal_cards.dart';

class WatchdogStatusChip extends StatelessWidget {
  final AudioWatchdogReport report;

  const WatchdogStatusChip({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final ok = report.status == AudioHealthStatus.healthy;
    final color = ok ? accentEmerald : riskYellow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            ok ? 'DSP Engine Healthy • Live Heartbeat' : 'Audio Self-Healing...',
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveTranscriptCard extends StatelessWidget {
  final String transcript;

  const LiveTranscriptCard({super.key, required this.transcript});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.subtitles_outlined, color: textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Live Speech Transcript',
                style: GoogleFonts.plusJakartaSans(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'On-Device VAD',
                style: GoogleFonts.plusJakartaSans(
                  color: textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            transcript.isNotEmpty
                ? transcript
                : 'Listening for audio and voice patterns on device...',
            style: GoogleFonts.plusJakartaSans(
              color: transcript.isNotEmpty ? textPrimary : textMuted,
              fontSize: 13,
              fontStyle:
                  transcript.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}


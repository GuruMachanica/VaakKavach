import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/call_monitor_state.dart';
import '../../providers/call_monitor_provider.dart';

class CallControlsBar extends ConsumerWidget {
  final CallMonitorState state;
  final VoidCallback onEndCall;
  final VoidCallback onSimulateSpeech;

  const CallControlsBar({
    super.key,
    required this.state,
    required this.onEndCall,
    required this.onSimulateSpeech,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgSurface,
        border: Border(top: BorderSide(color: bgSurfaceBorder, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: state.isMuted
                  ? accentCyan.withValues(alpha: 0.2)
                  : bgElevated,
              foregroundColor: state.isMuted ? accentCyan : textPrimary,
              padding: const EdgeInsets.all(14),
            ),
            icon: Icon(
              state.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              size: 22,
            ),
            onPressed: () =>
                ref.read(callMonitorProvider.notifier).toggleMute(),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: riskRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: onEndCall,
            icon: const Icon(Icons.call_end_rounded, size: 20),
            label: Text(
              'End Call',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: bgElevated,
              foregroundColor: textPrimary,
              padding: const EdgeInsets.all(14),
            ),
            icon: const Icon(Icons.record_voice_over_outlined, size: 22),
            onPressed: onSimulateSpeech,
          ),
        ],
      ),
    );
  }
}

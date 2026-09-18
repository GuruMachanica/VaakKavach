import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/call_monitor_provider.dart';

class SimulateSpeechSheet extends ConsumerStatefulWidget {
  const SimulateSpeechSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SimulateSpeechSheet(),
    );
  }

  @override
  ConsumerState<SimulateSpeechSheet> createState() =>
      _SimulateSpeechSheetState();
}

class _SimulateSpeechSheetState extends ConsumerState<SimulateSpeechSheet> {
  final _testSpeechCtrl = TextEditingController();

  @override
  void dispose() {
    _testSpeechCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulate Speech Input',
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Inject phrases to test live intent extraction and autonomous countermeasures.',
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _testSpeechCtrl,
            style: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'e.g. This is CBI officer Sharma, do not disconnect or share OTP',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _QuickChip('Digital Arrest Threat', () => _testSpeechCtrl.text =
                  'This is police narcotics cell. Your parcel is seized with illegal drugs, stay in your room.'),
              _QuickChip('OTP Scam', () => _testSpeechCtrl.text =
                  'Sir I am calling from your bank, tell me the 6 digit verification OTP immediately.'),
              _QuickChip('Remote AnyDesk', () => _testSpeechCtrl.text =
                  'Install AnyDesk QuickSupport to prevent immediate account block.'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final phrase = _testSpeechCtrl.text.trim();
                if (phrase.isNotEmpty) {
                  ref.read(callMonitorProvider.notifier).injectTestTranscript(phrase);
                  Navigator.pop(context);
                }
              },
              child: Text('Inject Phrase', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _QuickChip(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text, style: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 11)),
      backgroundColor: bgElevated,
      side: const BorderSide(color: bgSurfaceBorder),
      onPressed: onTap,
    );
  }
}


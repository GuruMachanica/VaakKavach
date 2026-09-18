import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/call_monitor_provider.dart';

class SimulateCallSheet extends ConsumerStatefulWidget {
  const SimulateCallSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SimulateCallSheet(),
    );
  }

  @override
  ConsumerState<SimulateCallSheet> createState() => _SimulateCallSheetState();
}

class _SimulateCallSheetState extends ConsumerState<SimulateCallSheet> {
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulate Incoming Call',
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a test phone number to launch the live on-device speech and acoustic threat monitor.',
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            style: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Enter phone number',
              prefixIcon:
                  Icon(Icons.phone_outlined, color: accentCyan, size: 20),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentEmerald,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final number = _phoneCtrl.text.trim();
                if (number.isNotEmpty) {
                  Navigator.pop(context);
                  ref.read(callMonitorProvider.notifier).startMonitoring(number);
                  context.push('/home/monitor');
                }
              },
              child: Text(
                'Start Live Monitor',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

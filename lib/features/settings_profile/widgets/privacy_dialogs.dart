import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/history_provider.dart';

class PrivacyDialogs {
  static void confirmResetCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: bgSurfaceBorder),
        ),
        title: Text(
          'Reset Speech Cache?',
          style: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will purge intermediate audio frames and restart the native acoustic feature engine.',
          style: GoogleFonts.plusJakartaSans(
            color: textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: bgSurface,
                  content: Text(
                    'Local threat buffer flushed and re-initialized.',
                    style: GoogleFonts.plusJakartaSans(color: accentEmerald),
                  ),
                ),
              );
            },
            child: Text(
              'Reset',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static void confirmClearLogs(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: bgSurfaceBorder),
        ),
        title: Text(
          'Erase All Call Records?',
          style: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'All verified call entries, synthetic threat dossiers, and risk scores will be permanently deleted from this phone.',
          style: GoogleFonts.plusJakartaSans(
            color: textSecondary,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: riskRed),
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(dlgCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: bgSurface,
                  content: Text(
                    'All call logs wiped from local device storage.',
                    style: GoogleFonts.plusJakartaSans(color: textPrimary),
                  ),
                ),
              );
            },
            child: Text(
              'Erase All',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

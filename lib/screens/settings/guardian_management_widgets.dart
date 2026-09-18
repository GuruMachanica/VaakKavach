import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/guardian_provider.dart';

export 'guardian_tile.dart';

class AddGuardianSheet extends ConsumerStatefulWidget {
  const AddGuardianSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddGuardianSheet(),
    );
  }

  @override
  ConsumerState<AddGuardianSheet> createState() => _AddGuardianSheetState();
}

class _AddGuardianSheetState extends ConsumerState<AddGuardianSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Guardian Contact',
                  style: GoogleFonts.plusJakartaSans(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              style:
                  GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Guardian Name',
                hintText: 'e.g. Mom, Brother, Sarah',
                filled: true,
                fillColor: bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: bgSurfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style:
                  GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 555 123 4567',
                filled: true,
                fillColor: bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: bgSurfaceBorder),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameCtrl.text.trim();
                  final phone = _phoneCtrl.text.trim();
                  if (name.isNotEmpty && phone.isNotEmpty) {
                    ref.read(guardianProvider.notifier).addGuardian(
                          name: name,
                          phone: phone,
                        );
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Save Guardian',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

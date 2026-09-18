import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../providers/guardian_provider.dart';
import 'guardian_management_widgets.dart';
import 'settings_card_widgets.dart';

class GuardianSosSection extends ConsumerWidget {
  const GuardianSosSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guardiansAsync = ref.watch(guardianProvider);

    return SettingsSectionCard(
      title: 'Guardian SOS Network',
      subtitle: 'Direct SIM alert dispatch when coercion is detected',
      headerAction: TextButton.icon(
        onPressed: () => AddGuardianSheet.show(context),
        icon: const Icon(Icons.add_rounded, size: 18, color: accentCyan),
        label: Text(
          'Add',
          style: GoogleFonts.plusJakartaSans(
            color: accentCyan,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      children: [
        guardiansAsync.when(
          data: (guardians) {
            if (guardians.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: bgSurfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_moon_outlined,
                        color: textMuted, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No emergency contacts configured yet. Add a family member to notify if a scam is intercepted.',
                        style: GoogleFonts.plusJakartaSans(
                          color: textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: guardians
                  .map((g) => GuardianTile(
                        guardian: g,
                        onToggle: (val) => ref
                            .read(guardianProvider.notifier)
                            .toggleGuardian(g.id, val),
                        onDelete: () => ref
                            .read(guardianProvider.notifier)
                            .deleteGuardian(g.id),
                        onTest: () async {
                          final res = await ref
                              .read(guardianProvider.notifier)
                              .sendTestAlert(g.phone);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: bgSurface,
                              content: Text(
                                res.message,
                                style: GoogleFonts.plusJakartaSans(
                                  color: res.success ? accentEmerald : riskRed,
                                ),
                              ),
                            ),
                          );
                        },
                      ))
                  .toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentCyan,
              ),
            ),
          ),
          error: (err, _) => Text(
            'Failed to load guardians: $err',
            style: GoogleFonts.plusJakartaSans(
              color: riskRed,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}

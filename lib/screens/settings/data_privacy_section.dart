import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../providers/profile_provider.dart';
import 'privacy_dialogs.dart';
import 'settings_card_widgets.dart';

class DataPrivacySection extends ConsumerWidget {
  const DataPrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Column(
      children: [
        SettingsSectionCard(
          title: 'Data & Privacy Sovereignty',
          subtitle: 'Zero cloud telemetry. 100% encrypted on your phone',
          children: [
            SettingsToggleRow(
              title: 'Auto-Purge Old Call Records',
              subtitle: 'Automatically erase call audits older than 7 days',
              value: profile.autoDeleteLogs,
              onChanged: (_) =>
                  ref.read(profileProvider.notifier).toggleAutoDeleteLogs(),
            ),
            const SettingsDivider(),
            SettingsActionTile(
              icon: Icons.refresh_rounded,
              title: 'Reset Local Threat Cache',
              subtitle: 'Flushes transient speech buffers & re-initializes DSP',
              onTap: () => PrivacyDialogs.confirmResetCache(context),
            ),
            const SettingsDivider(),
            SettingsActionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: riskRed,
              title: 'Erase All Call Records',
              subtitle:
                  'Permanently wipe all forensic logs stored on this device',
              onTap: () => PrivacyDialogs.confirmClearLogs(context, ref),
            ),
          ],
        ).animate(delay: 160.ms).fadeIn(duration: 350.ms),
        const SizedBox(height: 20),
        SettingsSectionCard(
          title: 'System Architecture',
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VaakKavach operates strictly on-device in-memory and via local SQLite. No audio, transcripts, or call data ever leave this phone.',
                    style: GoogleFonts.plusJakartaSans(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lead Architect: Mohammad Huzaifa • Upgraded from IronLogic / Ashu-1126/AEGIS.',
                    style: GoogleFonts.plusJakartaSans(
                      color: textMuted,
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Engine Build 2026.9.18-edge',
                  style: GoogleFonts.plusJakartaSans(
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _openUrl(termsOfServiceUrl),
                      child: Text(
                        'Terms',
                        style: GoogleFonts.plusJakartaSans(
                          color: accentCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => _openUrl(privacyPolicyUrl),
                      child: Text(
                        'Privacy',
                        style: GoogleFonts.plusJakartaSans(
                          color: accentCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ).animate(delay: 240.ms).fadeIn(duration: 350.ms),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

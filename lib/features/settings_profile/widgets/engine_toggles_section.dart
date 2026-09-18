import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settings_card_widgets.dart';

class EngineTogglesSection extends StatefulWidget {
  const EngineTogglesSection({super.key});

  @override
  State<EngineTogglesSection> createState() => _EngineTogglesSectionState();
}

class _EngineTogglesSectionState extends State<EngineTogglesSection> {
  bool _aasistVoice = true;
  bool _scamCoercion = true;
  bool _watchdogHealing = true;
  bool _autoQuarantine = true;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'On-Device Edge Engine',
      subtitle: 'Hardware-accelerated DSP & psychological model behavior',
      children: [
        SettingsToggleRow(
          title: 'AASIST Deepfake Voice Detection',
          subtitle: 'Analyzes sub-band spectral flatness & synthetic anomalies',
          value: _aasistVoice,
          onChanged: (v) => setState(() => _aasistVoice = v),
        ),
        const SettingsDivider(),
        SettingsToggleRow(
          title: 'Coercion & Social Engineering Shield',
          subtitle:
              'Detects psychological arrest, urgency, and extraction keywords',
          value: _scamCoercion,
          onChanged: (v) => setState(() => _scamCoercion = v),
        ),
        const SettingsDivider(),
        SettingsToggleRow(
          title: 'Audio Watchdog Self-Healing',
          subtitle: 'Restarts audio pipeline if audio stream stalls >2.4s',
          value: _watchdogHealing,
          onChanged: (v) => setState(() => _watchdogHealing = v),
        ),
        const SettingsDivider(),
        SettingsToggleRow(
          title: 'Auto-Quarantine Threats',
          subtitle:
              'Terminates and blocks calls exceeding critical threat score',
          value: _autoQuarantine,
          onChanged: (v) => setState(() => _autoQuarantine = v),
        ),
      ],
    ).animate(delay: 80.ms).fadeIn(duration: 350.ms);
  }
}

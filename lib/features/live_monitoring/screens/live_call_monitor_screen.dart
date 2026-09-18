import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/colors.dart';
import '../models/call_record.dart';
import '../models/risk_level.dart';
import '../providers/call_monitor_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/risk_gauge.dart';
import 'monitor/agent_guidance_card.dart';
import 'monitor/call_controls_bar.dart';
import 'monitor/monitor_metric_cards.dart';
import 'monitor/simulate_speech_sheet.dart';

class LiveCallMonitorScreen extends ConsumerStatefulWidget {
  const LiveCallMonitorScreen({super.key});

  @override
  ConsumerState<LiveCallMonitorScreen> createState() =>
      _LiveCallMonitorScreenState();
}

class _LiveCallMonitorScreenState extends ConsumerState<LiveCallMonitorScreen> {
  int _callSeconds = 0;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callSeconds++);
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _saveAndEndCall(CallMonitorState state) {
    final now = DateTime.now();
    final riskLevel = state.overallFraudScore >= 0.65
        ? RiskLevel.danger
        : (state.overallFraudScore >= 0.35 ? RiskLevel.suspicious : RiskLevel.safe);

    final record = CallRecord(
      id: 'call_${now.millisecondsSinceEpoch}',
      callerName: state.activeCallNumber.isNotEmpty ? state.activeCallNumber : 'Unknown Caller',
      phoneNumber: state.activeCallNumber.isNotEmpty ? state.activeCallNumber : 'Protected Line',
      callTime: now,
      riskLevel: riskLevel,
      riskScore: (state.overallFraudScore * 100).round(),
      syntheticScore: (state.syntheticVoiceScore * 100).round(),
      intentScore: (state.scamChanceScore * 100).round(),
    );

    ref.read(historyProvider.notifier).addRecord(record);
    ref.read(callMonitorProvider.notifier).endCall();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(callMonitorProvider);
    final isDanger = state.overallFraudScore >= 0.65;
    final isWarning = state.overallFraudScore >= 0.35 && !isDanger;

    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        backgroundColor: bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => _saveAndEndCall(state),
        ),
        centerTitle: true,
        title: Text(
          'Live Shield Monitor',
          style: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: CallControlsBar(
        state: state,
        onEndCall: () => _saveAndEndCall(state),
        onSimulateSpeech: () => SimulateSpeechSheet.show(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Text(
              state.activeCallNumber.isNotEmpty ? state.activeCallNumber : 'Incoming Call',
              style: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(_callSeconds),
              style: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            RiskGauge(
              score: state.overallFraudScore,
              innerScore: state.syntheticVoiceScore,
              size: 200,
              centerLabel: isDanger ? 'THREAT' : (isWarning ? 'CAUTION' : 'SAFE'),
              subLabel: 'Scam ${(state.overallFraudScore * 100).round()}% • Voice ${(state.syntheticVoiceScore * 100).round()}%',
            ),
            const SizedBox(height: 16),
            if (state.watchdogReport != null)
              WatchdogStatusChip(report: state.watchdogReport!),
            const SizedBox(height: 16),
            if (state.agentGuidance != null)
              AgentGuidanceCard(guidance: state.agentGuidance!),
            const SizedBox(height: 16),
            LiveTranscriptCard(transcript: state.safeTranscript),
            const SizedBox(height: 16),
            DualSignalCards(state: state),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

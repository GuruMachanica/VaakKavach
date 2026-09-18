import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../models/call_monitor_state.dart';
import '../services/aegis_agent_controller.dart';
import '../services/live_call_service.dart';

export '../models/call_monitor_state.dart';

class CallMonitorNotifier extends Notifier<CallMonitorState> {
  Timer? _reconnectTimer;
  Timer? _keywordAlertTimer;
  bool _vibratedForCurrentThreat = false;

  @override
  CallMonitorState build() {
    ref.onDispose(() async {
      _reconnectTimer?.cancel();
      _keywordAlertTimer?.cancel();
      await ref.read(liveCallServiceProvider).stop();
    });
    return const CallMonitorState();
  }

  Future<void> startMonitoring(String callNumber) async {
    if (state.isMonitoring || state.isConnecting) return;
    _vibratedForCurrentThreat = false;
    state = state.copyWith(
      isConnecting: true,
      activeCallNumber: callNumber,
      callEnded: false,
      clearError: true,
      agentGuidance: AgentTacticalGuidance.safe(),
    );

    try {
      await ref.read(liveCallServiceProvider).start(
        callNumber: callNumber,
        onRisk: (scores) {
          final showAlert = scores.sensitiveAlert && scores.detectedKeywords.isNotEmpty;
          state = state.copyWith(
            isMonitoring: true,
            isConnecting: false,
            overallFraudScore: scores.overall,
            syntheticVoiceScore: scores.syntheticVoice,
            scamChanceScore: scores.scamIntent,
            transcript: scores.transcript,
            detectedKeywords: scores.detectedKeywords,
            showSensitiveAlert: showAlert,
            riskLevel: scores.riskLevel,
            scamAlertType: scores.scamAlertType,
            scamAlertMessage: scores.scamAlertMessage,
            scamAlertActive: scores.scamAlertActive,
          );
          if (showAlert) {
            _keywordAlertTimer?.cancel();
            _keywordAlertTimer = Timer(const Duration(seconds: 8), () {
              if (ref.mounted) state = state.copyWith(showSensitiveAlert: false);
            });
          }
          _triggerHapticIfNeeded();
        },
        onGuidance: (g) => state = state.copyWith(agentGuidance: g),
        onWatchdogReport: (r) => state = state.copyWith(watchdogReport: r),
        onError: (message) {
          final isConnErr = message.toLowerCase().contains('closed') ||
              message.toLowerCase().contains('network');
          state = state.copyWith(
            errorMessage: message,
            isMonitoring: isConnErr ? false : state.isMonitoring,
            isConnecting: isConnErr ? false : state.isConnecting,
          );
          if (isConnErr) _scheduleReconnect();
        },
        onAudioDebug: (chunks, rate) => state = state.copyWith(
          audioChunksPerSecond: chunks,
          recorderSampleRate: rate,
        ),
      );
      state = state.copyWith(isMonitoring: true, isConnecting: false);
    } catch (e) {
      state = state.copyWith(isMonitoring: false, isConnecting: false, errorMessage: e.toString());
    }
  }

  void updateScores({required double syntheticVoice, required double scamChance}) {
    final overall = (syntheticVoice * 0.5 + scamChance * 0.5).clamp(0.0, 1.0);
    state = state.copyWith(
      syntheticVoiceScore: syntheticVoice,
      scamChanceScore: scamChance,
      overallFraudScore: overall,
    );
    _triggerHapticIfNeeded();
  }

  Future<void> _triggerHapticIfNeeded() async {
    if (!state.isHighRisk || state.isMuted || _vibratedForCurrentThreat) return;
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: [0, 250, 180, 250]);
      _vibratedForCurrentThreat = true;
    }
  }

  void muteAlert() => state = state.copyWith(isMuted: !state.isMuted);
  void toggleMute() => muteAlert();
  void flagCall() => state = state.copyWith(isFlagged: true);

  Future<void> endCall() async {
    _reconnectTimer?.cancel();
    _keywordAlertTimer?.cancel();
    await ref.read(liveCallServiceProvider).stop();
    state = state.copyWith(
      isMonitoring: false,
      isConnecting: false,
      callEnded: true,
      showSensitiveAlert: false,
      audioChunksPerSecond: 0,
      recorderSampleRate: 0,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
  void dismissScamAlert() => state = state.copyWith(clearScamAlert: true);
  void injectTestTranscript(String phrase) =>
      ref.read(liveCallServiceProvider).injectTestTranscript(phrase);

  void _scheduleReconnect() {
    if (state.activeCallNumber.isEmpty || state.callEnded) return;
    final callNumber = state.activeCallNumber;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () async {
      if (!ref.mounted || state.callEnded) return;
      state = state.copyWith(isMonitoring: false, isConnecting: false);
      await ref.read(liveCallServiceProvider).stop();
      if (ref.mounted && !state.callEnded) await startMonitoring(callNumber);
    });
  }
}


final callMonitorProvider =
    NotifierProvider<CallMonitorNotifier, CallMonitorState>(
  CallMonitorNotifier.new,
);

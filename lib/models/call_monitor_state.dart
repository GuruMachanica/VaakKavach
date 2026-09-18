import '../services/aegis_agent_controller.dart';
import '../services/audio_watchdog_service.dart';

class CallMonitorState {
  final bool isMonitoring;
  final bool isConnecting;
  final String activeCallNumber;
  final double overallFraudScore;
  final double syntheticVoiceScore;
  final double scamChanceScore;
  final bool isMuted;
  final bool isFlagged;
  final bool callEnded;
  final String? errorMessage;
  final String? transcript;
  final List<String>? detectedKeywords;
  final bool showSensitiveAlert;
  final String? riskLevel;
  final int? audioChunksPerSecond;
  final int? recorderSampleRate;
  final String? scamAlertType;
  final String? scamAlertMessage;
  final bool scamAlertActive;
  final AgentTacticalGuidance? agentGuidance;
  final AudioWatchdogReport? watchdogReport;

  const CallMonitorState({
    this.isMonitoring = false,
    this.isConnecting = false,
    this.activeCallNumber = '',
    this.overallFraudScore = 0.0,
    this.syntheticVoiceScore = 0.0,
    this.scamChanceScore = 0.0,
    this.isMuted = false,
    this.isFlagged = false,
    this.callEnded = false,
    this.errorMessage,
    this.transcript = '',
    this.detectedKeywords = const [],
    this.showSensitiveAlert = false,
    this.riskLevel = 'safe',
    this.audioChunksPerSecond = 0,
    this.recorderSampleRate = 0,
    this.scamAlertType,
    this.scamAlertMessage,
    this.scamAlertActive = false,
    this.agentGuidance,
    this.watchdogReport,
  });

  bool get isHighRisk => overallFraudScore >= 0.65;
  String get safeTranscript => transcript ?? '';
  List<String> get safeDetectedKeywords => detectedKeywords ?? const [];
  String get safeRiskLevel {
    final value = riskLevel;
    if (value == null || value.trim().isEmpty) return 'safe';
    return value;
  }

  int get safeAudioChunksPerSecond => audioChunksPerSecond ?? 0;
  int get safeRecorderSampleRate => recorderSampleRate ?? 0;

  CallMonitorState copyWith({
    bool? isMonitoring,
    bool? isConnecting,
    String? activeCallNumber,
    double? overallFraudScore,
    double? syntheticVoiceScore,
    double? scamChanceScore,
    bool? isMuted,
    bool? isFlagged,
    bool? callEnded,
    String? errorMessage,
    String? transcript,
    List<String>? detectedKeywords,
    bool? showSensitiveAlert,
    String? riskLevel,
    int? audioChunksPerSecond,
    int? recorderSampleRate,
    String? scamAlertType,
    String? scamAlertMessage,
    bool? scamAlertActive,
    AgentTacticalGuidance? agentGuidance,
    AudioWatchdogReport? watchdogReport,
    bool clearError = false,
    bool clearScamAlert = false,
  }) {
    return CallMonitorState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isConnecting: isConnecting ?? this.isConnecting,
      activeCallNumber: activeCallNumber ?? this.activeCallNumber,
      overallFraudScore: overallFraudScore ?? this.overallFraudScore,
      syntheticVoiceScore: syntheticVoiceScore ?? this.syntheticVoiceScore,
      scamChanceScore: scamChanceScore ?? this.scamChanceScore,
      isMuted: isMuted ?? this.isMuted,
      isFlagged: isFlagged ?? this.isFlagged,
      callEnded: callEnded ?? this.callEnded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      transcript: transcript ?? this.transcript ?? '',
      detectedKeywords: detectedKeywords ?? this.detectedKeywords ?? const [],
      showSensitiveAlert: showSensitiveAlert ?? this.showSensitiveAlert,
      riskLevel: riskLevel ?? this.riskLevel ?? 'safe',
      audioChunksPerSecond:
          audioChunksPerSecond ?? this.audioChunksPerSecond ?? 0,
      recorderSampleRate: recorderSampleRate ?? this.recorderSampleRate ?? 0,
      scamAlertType:
          clearScamAlert ? null : (scamAlertType ?? this.scamAlertType),
      scamAlertMessage:
          clearScamAlert ? null : (scamAlertMessage ?? this.scamAlertMessage),
      scamAlertActive:
          clearScamAlert ? false : (scamAlertActive ?? this.scamAlertActive),
      agentGuidance: agentGuidance ?? this.agentGuidance,
      watchdogReport: watchdogReport ?? this.watchdogReport,
    );
  }
}

import 'dart:async';
import 'dart:math' as math;
import '../models/agent_tactical_guidance.dart';
import '../models/live_risk_scores.dart';
import 'guardian_sms_service.dart';
import 'local_database_service.dart';
import 'local_risk_engine.dart';

class LiveCallEvaluator {
  static (LiveRiskScores, ThreatAlertResult) computeScores({
    required String transcript,
    required double syntheticScore,
    required double phoneScore,
  }) {
    final threat = LocalRiskEngine.evaluate(transcript);
    final scam = threat.intentScore;
    final overall = math.max(
      math.max(scam, syntheticScore),
      (scam * 0.55) + (syntheticScore * 0.30) + (phoneScore * 0.15),
    ).clamp(0.0, 1.0);

    final risk = (overall >= 0.65 || threat.scamAlertActive)
        ? 'danger'
        : (overall >= 0.35 ? 'warning' : 'safe');

    final scores = LiveRiskScores(
      syntheticVoice: syntheticScore,
      scamIntent: scam,
      overall: overall,
      transcript: transcript,
      detectedKeywords: threat.detectedKeywords,
      sensitiveAlert:
          threat.detectedKeywords.isNotEmpty || threat.scamAlertActive,
      riskLevel: risk,
      scamAlertType: threat.scamAlertType,
      scamAlertMessage: threat.scamAlertMessage,
      scamAlertActive: threat.scamAlertActive,
    );

    return (scores, threat);
  }

  static void dispatchActions({
    required AgentTacticalGuidance guidance,
    required String callNumber,
    required GuardianSmsService sms,
    required LocalDatabaseService db,
  }) {
    if (guidance.shouldAlertGuardian) {
      unawaited(sms.broadcastEmergencyAlert(
        suspectNumber: callNumber,
        threatType: guidance.stageTitle,
        threatScore: guidance.threatSeverity,
      ));
    }
    if (guidance.shouldAutoQuarantine && callNumber.isNotEmpty) {
      unawaited(db.blockCaller(callNumber, 'Quarantine: ${guidance.stageTitle}'));
    }
  }
}

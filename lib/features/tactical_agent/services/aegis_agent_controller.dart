import 'dart:async';
import '../models/agent_countermeasures.dart';
import '../models/agent_tactical_guidance.dart';

export '../models/agent_countermeasures.dart';
export '../models/agent_tactical_guidance.dart';

class AegisAgentController {
  AgentCallStage _currentStage = AgentCallStage.monitoring;
  final List<String> _cumulativeTriggers = [];
  bool _guardianAlertDispatched = false;
  bool _autoQuarantineDispatched = false;

  final StreamController<AgentTacticalGuidance> _guidanceController =
      StreamController<AgentTacticalGuidance>.broadcast();

  Stream<AgentTacticalGuidance> get guidanceStream => _guidanceController.stream;
  AgentCallStage get currentStage => _currentStage;
  bool get guardianAlertDispatched => _guardianAlertDispatched;
  bool get autoQuarantineDispatched => _autoQuarantineDispatched;

  void reset() {
    _currentStage = AgentCallStage.monitoring;
    _cumulativeTriggers.clear();
    _guardianAlertDispatched = false;
    _autoQuarantineDispatched = false;
  }

  AgentTacticalGuidance evaluate({
    required String transcript,
    required double syntheticVoiceScore,
    required double phoneRiskScore,
    required double intentRiskScore,
    required List<String> detectedKeywords,
  }) {
    for (final kw in detectedKeywords) {
      if (!_cumulativeTriggers.contains(kw)) _cumulativeTriggers.add(kw);
    }

    final lower = transcript.toLowerCase();
    final hasExtraction = lower.contains('otp') ||
        lower.contains('cvv') ||
        lower.contains('pin') ||
        lower.contains('transfer') ||
        lower.contains('anydesk') ||
        lower.contains('teamviewer') ||
        lower.contains('पैसे') ||
        lower.contains('ओटीपी');

    final hasCoercion = lower.contains('arrest') ||
        lower.contains('police') ||
        lower.contains('customs') ||
        lower.contains('cbi') ||
        lower.contains('digital arrest') ||
        lower.contains('skype') ||
        lower.contains('गिरफ्तार');

    final hasIdentity = lower.contains('bank') ||
        lower.contains('courier') ||
        lower.contains('fedex') ||
        lower.contains('dhl') ||
        lower.contains('trai') ||
        lower.contains('kyc');

    if (hasExtraction ||
        intentRiskScore >= 0.80 ||
        (syntheticVoiceScore >= 0.85 && hasIdentity)) {
      _currentStage = AgentCallStage.extractionDanger;
    } else if (hasCoercion ||
        intentRiskScore >= 0.50 ||
        (syntheticVoiceScore >= 0.70)) {
      _currentStage = AgentCallStage.coercionIsolation;
    } else if (hasIdentity ||
        phoneRiskScore >= 0.40 ||
        intentRiskScore >= 0.25) {
      _currentStage = AgentCallStage.identityClaim;
    } else {
      _currentStage = AgentCallStage.monitoring;
    }

    double severity = (syntheticVoiceScore * 0.35) +
        (intentRiskScore * 0.45) +
        (phoneRiskScore * 0.20);
    if (_currentStage == AgentCallStage.extractionDanger) {
      severity = severity < 0.85 ? 0.88 : severity;
    } else if (_currentStage == AgentCallStage.coercionIsolation) {
      severity = severity < 0.65 ? 0.68 : severity;
    }
    severity = severity.clamp(0.0, 1.0);

    final data = AgentCountermeasureData.resolve(_currentStage, severity);

    final guidance = AgentTacticalGuidance(
      stage: _currentStage,
      stageTitle: data.title,
      threatSeverity: severity,
      countermeasure: data.countermeasure,
      recommendedAction: data.action,
      shouldAlertGuardian: data.alertGuardian && !_guardianAlertDispatched,
      shouldAutoQuarantine: data.autoQuarantine && !_autoQuarantineDispatched,
      detectedTriggers: List.unmodifiable(_cumulativeTriggers),
    );

    if (data.alertGuardian) _guardianAlertDispatched = true;
    if (data.autoQuarantine) _autoQuarantineDispatched = true;

    if (!_guidanceController.isClosed) {
      _guidanceController.add(guidance);
    }
    return guidance;
  }

  void dispose() {
    _guidanceController.close();
  }
}

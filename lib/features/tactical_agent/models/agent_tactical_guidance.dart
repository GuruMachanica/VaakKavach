enum AgentCallStage {
  idle,
  monitoring,
  identityClaim,
  coercionIsolation,
  extractionDanger,
}

class AgentTacticalGuidance {
  final AgentCallStage stage;
  final String stageTitle;
  final double threatSeverity;
  final String countermeasure;
  final String recommendedAction;
  final bool shouldAlertGuardian;
  final bool shouldAutoQuarantine;
  final List<String> detectedTriggers;

  const AgentTacticalGuidance({
    required this.stage,
    required this.stageTitle,
    required this.threatSeverity,
    required this.countermeasure,
    required this.recommendedAction,
    this.shouldAlertGuardian = false,
    this.shouldAutoQuarantine = false,
    this.detectedTriggers = const [],
  });

  factory AgentTacticalGuidance.safe() {
    return const AgentTacticalGuidance(
      stage: AgentCallStage.monitoring,
      stageTitle: 'Autonomous Guardian: Active',
      threatSeverity: 0.05,
      countermeasure:
          'Call patterns normal. Shield is continuously analyzing acoustics & intent.',
      recommendedAction: 'Proceed normally.',
      shouldAlertGuardian: false,
      shouldAutoQuarantine: false,
    );
  }
}

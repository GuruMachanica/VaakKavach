class LiveRiskScores {
  final double syntheticVoice;
  final double scamIntent;
  final double overall;
  final String transcript;
  final List<String> detectedKeywords;
  final bool sensitiveAlert;
  final String riskLevel;
  final String? scamAlertType;
  final String? scamAlertMessage;
  final bool scamAlertActive;

  const LiveRiskScores({
    required this.syntheticVoice,
    required this.scamIntent,
    required this.overall,
    this.transcript = '',
    this.detectedKeywords = const [],
    this.sensitiveAlert = false,
    this.riskLevel = 'safe',
    this.scamAlertType,
    this.scamAlertMessage,
    this.scamAlertActive = false,
  });
}

class ThreatAlertResult {
  final double intentScore;
  final List<String> detectedKeywords;
  final List<String> alerts;
  final String? primaryAlert;
  final String? scamAlertType;
  final String? scamAlertMessage;
  final bool scamAlertActive;

  const ThreatAlertResult({
    required this.intentScore,
    required this.detectedKeywords,
    required this.alerts,
    this.primaryAlert,
    this.scamAlertType,
    this.scamAlertMessage,
    this.scamAlertActive = false,
  });
}

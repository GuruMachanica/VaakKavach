import '../models/threat_alert_result.dart';
import 'risk_engine_rules.dart';

export '../models/threat_alert_result.dart';

class LocalRiskEngine {
  static const List<RiskEngineRule> rules = kRiskEngineRules;

  static ThreatAlertResult evaluate(String transcript) {
    if (transcript.trim().isEmpty) {
      return const ThreatAlertResult(
        intentScore: 0.0,
        detectedKeywords: [],
        alerts: [],
      );
    }

    final lower = transcript.toLowerCase();
    final detectedKeywords = <String>[];
    final alerts = <String>[];
    String? primaryAlert;

    for (final rule in rules) {
      final reg = RegExp(rule.pattern, caseSensitive: false, unicode: true);
      if (reg.hasMatch(lower)) {
        detectedKeywords.add(rule.alertTag);
        alerts.add(rule.userAlert);
        primaryAlert ??= rule.userAlert;
      }
    }

    double score = 0.0;
    String? scamAlertType;
    String? scamAlertMessage;
    bool scamAlertActive = false;

    if (detectedKeywords.contains('remote_access_trap')) {
      scamAlertType = 'remote_access_attack';
      scamAlertMessage =
          'CRITICAL DANGER: Caller attempting remote control takeover (AnyDesk/TeamViewer/APK). Do NOT grant access!';
      scamAlertActive = true;
      score = 0.98;
    } else if (detectedKeywords.contains('otp_threat') ||
        detectedKeywords.contains('pin_threat')) {
      scamAlertType = 'otp_asked';
      scamAlertMessage =
          'Caller is aggressively asking for your OTP or PIN. NEVER enter or disclose your security code!';
      scamAlertActive = true;
      score = 0.90 + (detectedKeywords.length * 0.03);
    } else if (detectedKeywords.contains('digital_arrest')) {
      scamAlertType = 'digital_arrest';
      scamAlertMessage =
          'CRITICAL: Digital Arrest extortion scam detected. Law enforcement agencies never arrest people via video/voice calls!';
      scamAlertActive = true;
      score = 0.95;
    } else if (detectedKeywords.contains('isolation_coercion')) {
      scamAlertType = 'psychological_coercion';
      scamAlertMessage =
          'High-pressure isolation tactic: Scammer demands you stay in a locked room or hide call from family!';
      scamAlertActive = true;
      score = 0.92;
    } else if (detectedKeywords.contains('transfer_request')) {
      scamAlertType = 'money_asked';
      scamAlertMessage =
          'Urgent money transfer demand detected. Verify recipient authenticity before sending funds!';
      scamAlertActive = true;
      score = 0.85 + (detectedKeywords.length * 0.03);
    } else if (detectedKeywords.contains('courier_scam')) {
      scamAlertType = 'fake_courier_customs';
      scamAlertMessage =
          'Fraudulent parcel extortion: Claims of seized narcotics or illegal packages sent in your name!';
      scamAlertActive = true;
      score = 0.85 + (detectedKeywords.length * 0.03);
    } else if (detectedKeywords.contains('kyc_urgency')) {
      scamAlertType = 'kyc_scam';
      scamAlertMessage =
          'Fake KYC verification threat detected. Official bank accounts are not blocked over unsolicited calls!';
      scamAlertActive = true;
      score = 0.80 + (detectedKeywords.length * 0.03);
    } else if (detectedKeywords.contains('bank_details') ||
        detectedKeywords.contains('card_details')) {
      scamAlertType = 'bank_details_asked';
      scamAlertMessage =
          'Caller is soliciting sensitive banking credentials or CVV numbers. Hang up immediately!';
      scamAlertActive = true;
      score = 0.78 + (detectedKeywords.length * 0.03);
    } else if (detectedKeywords.isNotEmpty) {
      score = 0.40 + (detectedKeywords.length * 0.15);
    }

    return ThreatAlertResult(
      intentScore: score.clamp(0.0, 1.0),
      detectedKeywords: detectedKeywords,
      alerts: alerts,
      primaryAlert: primaryAlert,
      scamAlertType: scamAlertType,
      scamAlertMessage: scamAlertMessage,
      scamAlertActive: scamAlertActive,
    );
  }
}

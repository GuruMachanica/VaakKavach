import 'agent_tactical_guidance.dart';

class AgentCountermeasureData {
  final String title;
  final String countermeasure;
  final String action;
  final bool alertGuardian;
  final bool autoQuarantine;

  const AgentCountermeasureData({
    required this.title,
    required this.countermeasure,
    required this.action,
    required this.alertGuardian,
    required this.autoQuarantine,
  });

  static AgentCountermeasureData resolve(AgentCallStage stage, double severity) {
    switch (stage) {
      case AgentCallStage.extractionDanger:
        return const AgentCountermeasureData(
          title: '🚨 CRITICAL EXTRACTION THREAT',
          countermeasure:
              'CRITICAL: NEVER disclose OTP, PIN, passwords, or install AnyDesk/screen-sharing tools.',
          action: 'TERMINATE CALL IMMEDIATELY. Threat is actively attempting credential theft.',
          alertGuardian: true,
          autoQuarantine: true,
        );
      case AgentCallStage.coercionIsolation:
        return AgentCountermeasureData(
          title: '⚠️ COERCION & ISOLATION DETECTED',
          countermeasure:
              'Psychological intimidation pattern detected (Digital Arrest / Legal Coercion). Police do not hold trials on phone or Skype.',
          action: 'Ask for official written summons and state: "I will visit the station in person."',
          alertGuardian: severity >= 0.75,
          autoQuarantine: severity >= 0.75,
        );
      case AgentCallStage.identityClaim:
        return const AgentCountermeasureData(
          title: '🛡️ UNVERIFIED AUTHORITY CLAIM',
          countermeasure:
              'Caller claims authority or corporate affiliation. Independently verify the caller.',
          action: 'Do not accept incoming credentials. Verify caller identity via official portal.',
          alertGuardian: false,
          autoQuarantine: false,
        );
      case AgentCallStage.monitoring:
      case AgentCallStage.idle:
        return const AgentCountermeasureData(
          title: '🛡️ AGENT MONITORING: SAFE',
          countermeasure:
              'Acoustic voice synthesis & semantic threat patterns are within safe baseline parameters.',
          action: 'Continue conversation normally.',
          alertGuardian: false,
          autoQuarantine: false,
        );
    }
  }
}

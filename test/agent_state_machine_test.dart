import 'package:flutter_test/flutter_test.dart';
import 'package:aegis_app/services/aegis_agent_controller.dart';

void main() {
  group('AegisAgentController Autonomous State Machine Tests', () {
    late AegisAgentController controller;

    setUp(() {
      controller = AegisAgentController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('starts in monitoring stage with safe baseline guidance', () {
      final guidance = controller.evaluate(
        transcript: 'Hello, how are you doing today?',
        syntheticVoiceScore: 0.05,
        phoneRiskScore: 0.0,
        intentRiskScore: 0.0,
        detectedKeywords: [],
      );

      expect(guidance.stage, AgentCallStage.monitoring);
      expect(guidance.threatSeverity, lessThan(0.20));
      expect(guidance.shouldAlertGuardian, isFalse);
      expect(guidance.shouldAutoQuarantine, isFalse);
    });

    test('transitions to identityClaim when authority or financial institution claimed', () {
      final guidance = controller.evaluate(
        transcript: 'This is officer Sharma calling from head office regarding your bank account.',
        syntheticVoiceScore: 0.15,
        phoneRiskScore: 0.20,
        intentRiskScore: 0.30,
        detectedKeywords: ['bank_details'],
      );

      expect(guidance.stage, AgentCallStage.identityClaim);
      expect(guidance.stageTitle, contains('AUTHORITY CLAIM'));
      expect(guidance.countermeasure, contains('Independently verify'));
    });

    test('transitions to coercionIsolation when digital arrest or isolation tactic detected', () {
      final guidance = controller.evaluate(
        transcript: 'This is CBI narcotics cell. Stay on call and do not disconnect, your parcel has illegal drugs.',
        syntheticVoiceScore: 0.35,
        phoneRiskScore: 0.40,
        intentRiskScore: 0.65,
        detectedKeywords: ['digital_arrest', 'isolation_coercion'],
      );

      expect(guidance.stage, AgentCallStage.coercionIsolation);
      expect(guidance.stageTitle, contains('COERCION'));
      expect(guidance.countermeasure, contains('Digital Arrest'));
    });

    test('transitions to extractionDanger when OTP, PIN, or remote takeover is requested', () {
      final guidance = controller.evaluate(
        transcript: 'Immediately install AnyDesk and verify the 6-digit OTP sent to your phone or your account is frozen.',
        syntheticVoiceScore: 0.40,
        phoneRiskScore: 0.50,
        intentRiskScore: 0.95,
        detectedKeywords: ['remote_access_trap', 'otp_threat'],
      );

      expect(guidance.stage, AgentCallStage.extractionDanger);
      expect(guidance.threatSeverity, greaterThanOrEqualTo(0.85));
      expect(guidance.shouldAlertGuardian, isTrue);
      expect(guidance.shouldAutoQuarantine, isTrue);
      expect(guidance.countermeasure, contains('NEVER disclose OTP'));
    });
  });
}

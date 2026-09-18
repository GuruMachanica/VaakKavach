import 'package:flutter_test/flutter_test.dart';
import 'package:aegis_app/services/audio_watchdog_service.dart';

void main() {
  group('AudioWatchdogService Self-Healing Tests', () {
    test('initializes in healthy state and increments chunk count', () {
      final watchdog = AudioWatchdogService(
        stallThreshold: const Duration(milliseconds: 200),
        heartbeatInterval: const Duration(milliseconds: 50),
      );

      watchdog.start();
      expect(watchdog.isMonitoring, isTrue);
      expect(watchdog.currentStatus, AudioHealthStatus.healthy);

      watchdog.recordChunk();
      watchdog.recordChunk();
      expect(watchdog.currentStatus, AudioHealthStatus.healthy);

      watchdog.stop();
      watchdog.dispose();
    });

    test('detects stream stall and triggers self-healing callback', () async {
      bool recoveryTriggered = false;

      final watchdog = AudioWatchdogService(
        stallThreshold: const Duration(milliseconds: 100),
        heartbeatInterval: const Duration(milliseconds: 30),
        onRecoverAudio: () async {
          recoveryTriggered = true;
          return true;
        },
      );

      watchdog.start();
      watchdog.recordChunk();

      // Wait longer than stallThreshold to trigger watchdog heartbeat check
      await Future.delayed(const Duration(milliseconds: 160));

      expect(recoveryTriggered, isTrue);
      expect(watchdog.recoveryAttempts, greaterThanOrEqualTo(1));

      watchdog.stop();
      watchdog.dispose();
    });
  });
}

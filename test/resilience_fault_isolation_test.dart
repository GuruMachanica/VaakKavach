import 'package:aegis_app/core/resilience/circuit_breaker.dart';
import 'package:aegis_app/core/resilience/feature_error_boundary.dart';
import 'package:aegis_app/core/resilience/safe_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Resilience & Fault Isolation Tests', () {
    test('SafeAction catches async error and returns fallback', () async {
      final result = await SafeAction.run<int>(
        action: () async => throw Exception('Hardware/Network Failure'),
        fallback: 42,
        contextTag: 'TestSubsystem',
      );
      expect(result, equals(42));
    });

    test('CircuitBreaker opens after threshold and returns fallback', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 2,
        resetTimeout: const Duration(seconds: 1),
      );

      final r1 = await breaker.execute(
        action: () async => throw Exception('Fail 1'),
        fallback: 'fallback_1',
      );
      expect(r1, 'fallback_1');

      final r2 = await breaker.execute(
        action: () async => throw Exception('Fail 2'),
        fallback: 'fallback_2',
      );
      expect(r2, 'fallback_2');
      expect(breaker.canExecute, isFalse);

      final r3 = await breaker.execute(
        action: () async => 'success',
        fallback: 'fallback_open',
      );
      expect(r3, 'fallback_open');
    });

    testWidgets('FeatureErrorBoundary isolates child widget failure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FeatureErrorBoundary(
              featureName: 'Live Monitor',
              child: Text('Protected UI'),
            ),
          ),
        ),
      );

      expect(find.text('Protected UI'), findsOneWidget);
    });
  });
}

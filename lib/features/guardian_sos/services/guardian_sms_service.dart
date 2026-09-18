import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'local_database_service.dart';

class GuardianSmsResult {
  final bool success;
  final int dispatchedCount;
  final String message;

  const GuardianSmsResult({
    required this.success,
    required this.dispatchedCount,
    required this.message,
  });
}

/// Service for autonomous dispatch of emergency alerts to designated Guardian contacts.
/// Dispatches directly via SIM hardware or native system SMS intent with zero cloud reliance.
class GuardianSmsService {
  static const MethodChannel _smsChannel =
      MethodChannel('com.example.aegis_app/native_sms');

  final LocalDatabaseService _dbService;

  GuardianSmsService(this._dbService);

  /// Dispatches an emergency SOS broadcast to active guardian contacts stored locally.
  Future<GuardianSmsResult> broadcastEmergencyAlert({
    required String suspectNumber,
    required String threatType,
    required double threatScore,
    String? locationContext,
  }) async {
    try {
      final contacts = await _dbService.loadGuardianContacts();
      final activeGuardians = contacts
          .where((c) => (c['is_active'] as int? ?? 1) == 1)
          .toList();

      if (activeGuardians.isEmpty) {
        return const GuardianSmsResult(
          success: false,
          dispatchedCount: 0,
          message: 'No active guardian contacts configured in local emergency registry.',
        );
      }

      final percentage = (threatScore * 100).toInt();
      final body = '[VAAKKAVACH CRITICAL ALERT] Your family member is currently receiving a suspected fraudulent/coercive call from $suspectNumber. Threat Severity: $percentage% ($threatType). Advise them to hang up immediately!';

      int successCount = 0;

      for (final guardian in activeGuardians) {
        final phone = guardian['phone']?.toString().trim() ?? '';
        if (phone.isEmpty) continue;

        bool sent = false;
        // 1. Try Native Android Direct SIM SMS if on Android
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          try {
            final res = await _smsChannel.invokeMethod<bool>('sendDirectSms', {
              'phone': phone,
              'message': body,
            });
            sent = res == true;
          } catch (_) {
            sent = false;
          }
        }

        // 2. If native direct SMS channel not available or fails, trigger SMS URI
        if (!sent) {
          try {
            final uri = Uri(
              scheme: 'sms',
              path: phone,
              queryParameters: {'body': body},
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
              sent = true;
            }
          } catch (e) {
            debugPrint('Guardian SMS intent failed for $phone: $e');
          }
        }

        if (sent) {
          successCount++;
          await _dbService.logEvent(
            'GUARDIAN_ALERT_SENT',
            'Emergency alert dispatched to guardian: $phone for call: $suspectNumber',
          );
        }
      }

      return GuardianSmsResult(
        success: successCount > 0,
        dispatchedCount: successCount,
        message: 'Alert successfully dispatched to $successCount guardian contact(s).',
      );
    } catch (e) {
      return GuardianSmsResult(
        success: false,
        dispatchedCount: 0,
        message: 'Failed to broadcast guardian alert: $e',
      );
    }
  }
}

final guardianSmsServiceProvider = Provider<GuardianSmsService>((ref) {
  return GuardianSmsService(ref.watch(localDatabaseProvider));
});


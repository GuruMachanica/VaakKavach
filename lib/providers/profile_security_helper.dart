import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/backend_service.dart';
import '../services/local_database_service.dart';
import 'auth_provider.dart';

class ProfileSecurityHelper {
  final Ref ref;
  ProfileSecurityHelper(this.ref);

  Future<String?> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      return 'All fields are required.';
    }
    if (newPassword.length < 8) {
      return 'New password must be at least 8 characters.';
    }
    if (newPassword != confirmPassword) {
      return 'Passwords do not match.';
    }
    if (newPassword == currentPassword) {
      return 'New password must be different.';
    }

    final token = ref.read(authProvider).accessToken;
    if (token.isNotEmpty && token != 'LOCAL_EDGE_OFFLINE_TOKEN') {
      try {
        await ref.read(backendServiceProvider).updatePassword(
          token: token,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      } catch (e) {
        return e.toString();
      }
    }
    return null;
  }

  Future<String?> start2FA(String email) async {
    final token = ref.read(authProvider).accessToken;
    if (token.isEmpty || token == 'LOCAL_EDGE_OFFLINE_TOKEN') return null;

    try {
      await ref.read(backendServiceProvider).start2FA(
        token: token,
        channel: 'email',
        destination: email,
      );
      await ref.read(localDatabaseProvider).logEvent('otp', '2FA OTP sent to $email');
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> verify2FA(String code) async {
    final normalized = code.trim();
    if (normalized.length != 6) return false;
    final token = ref.read(authProvider).accessToken;
    if (token.isEmpty || token == 'LOCAL_EDGE_OFFLINE_TOKEN') return false;


    try {
      await ref.read(backendServiceProvider).verify2FA(token: token, otp: normalized);
      return true;
    } catch (_) {
      return false;
    }
  }
}

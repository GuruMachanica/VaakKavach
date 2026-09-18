import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/backend_service.dart';

class CloudAuthController {
  final Ref ref;
  static bool _googleInitialized = false;

  CloudAuthController(this.ref);

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    return await ref.read(backendServiceProvider).register(
      fullName: fullName,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    return await ref.read(backendServiceProvider).login(
      phone: phone,
      password: password,
    );
  }

  Future<Map<String, dynamic>?> googleSignIn() async {
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      try {
        await google.initialize();
      } catch (_) {}
      _googleInitialized = true;
    }
    final account = await google.authenticate(scopeHint: const ['email']);
    final auth = account.authentication;
    return await ref.read(backendServiceProvider).googleLogin(
      email: account.email,
      fullName: account.displayName ?? 'Google User',
      googleId: account.id,
      idToken: auth.idToken,
    );
  }


  Future<Map<String, dynamic>> verifyOtp({
    required String pendingToken,
    required String otp,
  }) async {
    return await ref.read(backendServiceProvider).verifyLoginOtp(
      pendingToken: pendingToken,
      otp: otp,
    );
  }
}

import 'api_client.dart';

class BackendAuthService {
  final ApiClient _api;
  BackendAuthService(this._api);

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) =>
      _api.request(
        method: 'POST',
        path: '/auth/register',
        body: {
          'full_name': fullName,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) =>
      _api.request(
        method: 'POST',
        path: '/auth/login',
        body: {'phone': phone, 'password': password},
      );

  Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String fullName,
    required String googleId,
    String? idToken,
  }) =>
      _api.request(
        method: 'POST',
        path: '/auth/google-login',
        body: {
          'email': email,
          'full_name': fullName,
          'google_id': googleId,
          'id_token': idToken ?? '',
        },
      );

  Future<Map<String, dynamic>> verifyLoginOtp({
    required String pendingToken,
    required String otp,
  }) =>
      _api.request(
        method: 'POST',
        path: '/auth/login/verify-otp',
        body: {'pending_token': pendingToken, 'otp': otp},
      );

  Future<Map<String, dynamic>> refreshSession({required String refreshToken}) =>
      _api.request(
        method: 'POST',
        path: '/auth/refresh',
        body: {'refresh_token': refreshToken},
      );

  Future<void> logoutAllDevices({required String token}) =>
      _api.request(
        method: 'POST',
        path: '/auth/logout-all',
        token: token,
        body: const {},
      );

  Future<void> requestPasswordReset({required String phone}) =>
      _api.request(
        method: 'POST',
        path: '/auth/password/reset-request',
        body: {'phone': phone},
      );

  Future<void> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) =>
      _api.request(
        method: 'PUT',
        path: '/auth/password',
        token: token,
        body: {'current_password': currentPassword, 'new_password': newPassword},
      );

  Future<void> setPassword({
    required String token,
    required String phone,
    required String newPassword,
  }) =>
      _api.request(
        method: 'POST',
        path: '/auth/set-password',
        token: token,
        body: {'phone': phone, 'new_password': newPassword},
      );

  Future<Map<String, dynamic>> start2FA({
    required String token,
    required String channel,
    required String destination,
  }) =>
      _api.request(
        method: 'POST',
        path: '/auth/2fa/start',
        token: token,
        body: {'channel': channel, 'destination': destination},
      );

  Future<void> verify2FA({required String token, required String otp}) =>
      _api.request(
        method: 'POST',
        path: '/auth/2fa/verify',
        token: token,
        body: {'otp': otp},
      );
}

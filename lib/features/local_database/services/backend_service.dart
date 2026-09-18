import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/call_record.dart';
import 'api_client.dart';
import 'backend_auth_service.dart';
import 'backend_history_service.dart';

export 'api_client.dart';
export 'backend_auth_service.dart';
export 'backend_history_service.dart';

class BackendService {
  BackendService({http.Client? client})
      : _api = ApiClient(client: client),
        _auth = BackendAuthService(ApiClient(client: client)),
        _history = BackendHistoryService(ApiClient(client: client));

  final ApiClient _api;
  final BackendAuthService _auth;
  final BackendHistoryService _history;

  // Auth delegates
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) =>
      _auth.register(fullName: fullName, phone: phone, email: email, password: password);

  Future<Map<String, dynamic>> login({required String phone, required String password}) =>
      _auth.login(phone: phone, password: password);

  Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String fullName,
    required String googleId,
    String? idToken,
  }) =>
      _auth.googleLogin(email: email, fullName: fullName, googleId: googleId, idToken: idToken);

  Future<Map<String, dynamic>> verifyLoginOtp({required String pendingToken, required String otp}) =>
      _auth.verifyLoginOtp(pendingToken: pendingToken, otp: otp);

  Future<Map<String, dynamic>> refreshSession({required String refreshToken}) =>
      _auth.refreshSession(refreshToken: refreshToken);

  Future<void> logoutAllDevices({required String token}) =>
      _auth.logoutAllDevices(token: token);

  Future<void> requestPasswordReset({required String phone}) =>
      _auth.requestPasswordReset(phone: phone);

  Future<void> updatePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) =>
      _auth.updatePassword(token: token, currentPassword: currentPassword, newPassword: newPassword);

  Future<void> setPassword({
    required String token,
    required String phone,
    required String newPassword,
  }) =>
      _auth.setPassword(token: token, phone: phone, newPassword: newPassword);

  Future<Map<String, dynamic>> start2FA({
    required String token,
    required String channel,
    required String destination,
  }) =>
      _auth.start2FA(token: token, channel: channel, destination: destination);

  Future<void> verify2FA({required String token, required String otp}) =>
      _auth.verify2FA(token: token, otp: otp);

  // Profile
  Future<void> updateProfile({
    required String token,
    required String fullName,
    required String email,
    required bool autoDeleteLogs,
    required bool is2FAEnabled,
  }) =>
      _api.request(
        method: 'PUT',
        path: '/profile',
        token: token,
        body: {
          'full_name': fullName,
          'email': email,
          'auto_delete_logs': autoDeleteLogs,
          'two_fa_enabled': is2FAEnabled,
        },
      );

  Future<Map<String, dynamic>> fetchProfile({required String token}) =>
      _api.request(method: 'GET', path: '/profile', token: token);

  // History & Assist delegates
  Future<void> syncHistory({required String token, required List<CallRecord> records}) =>
      _history.syncHistory(token: token, records: records);

  Future<List<CallRecord>> fetchHistory({required String token, int limit = 200}) =>
      _history.fetchHistory(token: token, limit: limit);

  Future<void> clearHistory({required String token}) =>
      _history.clearHistory(token: token);

  Future<Map<String, dynamic>> fetchLatestAiAnalysis() =>
      _history.fetchLatestAiAnalysis();

  Uri latestAiReportPdfUrl() => _history.latestAiReportPdfUrl();
}

final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService();
});

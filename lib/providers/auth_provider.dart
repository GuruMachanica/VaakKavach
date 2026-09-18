import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_state.dart';
import '../services/backend_service.dart';
import 'cloud_auth_controller.dart';

export '../models/auth_state.dart';
export 'cloud_auth_controller.dart';

class AuthNotifier extends Notifier<AuthState> {
  static const _authKey = 'aegis_auth_state';

  @override
  AuthState build() {
    Future.microtask(_hydrate);
    return const AuthState(
      isAuthenticated: true,
      userId: 'local_shield_operator',
      fullName: 'Shield Commander',
      email: 'local.guardian@aegis.shield',
      accessToken: 'LOCAL_EDGE_OFFLINE_TOKEN',
    );
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      state = state.copyWith(
        accessToken: json['token'] as String? ?? state.accessToken,
        userId: json['userId'] as String? ?? state.userId,
        phoneNumber: json['phone'] as String? ?? state.phoneNumber,
        fullName: json['name'] as String? ?? state.fullName,
        email: json['email'] as String? ?? state.email,
        refreshToken: json['refreshToken'] as String? ?? state.refreshToken,
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jsonEncode({
      'token': state.accessToken,
      'userId': state.userId,
      'phone': state.phoneNumber,
      'name': state.fullName,
      'email': state.email,
      'refreshToken': state.refreshToken,
    }));
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final c = CloudAuthController(ref);
      final res = await c.register(
        fullName: fullName,
        phone: phone,
        email: email,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        accessToken: res['token']?.toString() ?? '',
        userId: res['user_id']?.toString() ?? phone,
        phoneNumber: phone,
        fullName: fullName,
        email: email,
      );
      await _persist();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> login({required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final c = CloudAuthController(ref);
      final res = await c.login(phone: phone, password: password);
      state = state.copyWith(
        isLoading: false,
        accessToken: res['token']?.toString() ?? '',
        phoneNumber: phone,
      );
      await _persist();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> ensureSessionValid() async {
    if (state.accessToken == 'LOCAL_EDGE_OFFLINE_TOKEN') return;
    if (state.refreshToken.isEmpty) return;
    try {
      final res = await ref.read(backendServiceProvider).refreshSession(
        refreshToken: state.refreshToken,
      );
      final token = res['token']?.toString() ?? '';
      if (token.isNotEmpty) {
        state = state.copyWith(accessToken: token);
        await _persist();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    state = const AuthState(
      isAuthenticated: true,
      userId: 'local_shield_operator',
      fullName: 'Shield Commander',
      email: 'local.guardian@aegis.shield',
      accessToken: 'LOCAL_EDGE_OFFLINE_TOKEN',
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

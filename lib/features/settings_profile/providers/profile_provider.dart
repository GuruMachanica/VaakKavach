import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_state.dart';
import '../services/backend_service.dart';
import '../services/local_database_service.dart';
import 'auth_provider.dart';
import 'profile_security_helper.dart';

export '../models/profile_state.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  static const _profileKey = 'aegis_profile_state';

  @override
  ProfileState build() {
    Future.microtask(_hydrate);
    return const ProfileState();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;

    final raw = prefs.getString(_profileKey);
    if (raw != null && raw.isNotEmpty) {
      state = ProfileState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }

    final auth = ref.read(authProvider);
    if (auth.fullName.isNotEmpty || auth.email.isNotEmpty) {
      state = state.copyWith(
        fullName: auth.fullName.isNotEmpty ? auth.fullName : state.fullName,
        email: auth.email.isNotEmpty ? auth.email : state.email,
        phoneNumber: auth.phoneNumber.isNotEmpty
            ? auth.phoneNumber
            : state.phoneNumber,
      );
    }
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(state.toJson()));
  }

  Future<void> _syncProfile() async {
    await ref.read(authProvider.notifier).ensureSessionValid();
    final token = ref.read(authProvider).accessToken;
    if (token.isEmpty || token == 'LOCAL_EDGE_OFFLINE_TOKEN') return;

    await ref.read(backendServiceProvider).updateProfile(
      token: token,
      fullName: state.fullName,
      email: state.email,
      autoDeleteLogs: state.autoDeleteLogs,
      is2FAEnabled: state.is2FAEnabled,
    );
  }

  Future<void> setIdentity({
    required String name,
    required String email,
    required String phone,
  }) async {
    state = state.copyWith(fullName: name, email: email, phoneNumber: phone, clearError: true);
    await _persist();
  }

  Future<void> updateAvatarPath(String path) async {
    state = state.copyWith(avatarPath: path, clearError: true);
    await _persist();
    await ref.read(localDatabaseProvider).logEvent('profile', 'Profile picture updated');
  }

  Future<void> updateFullName(String name) async {
    state = state.copyWith(fullName: name, clearError: true);
    await _persist();
  }

  Future<void> updateEmail(String email) async {
    state = state.copyWith(email: email, clearError: true);
    await _persist();
  }

  Future<void> saveProfileDetails({required String name, required String email}) async {
    state = state.copyWith(fullName: name, email: email, clearError: true);
    await _persist();
    await _syncProfile();
  }

  Future<void> toggleAutoDeleteLogs() async {
    state = state.copyWith(autoDeleteLogs: !state.autoDeleteLogs, clearError: true);
    await _persist();
  }

  Future<String?> start2FASetup() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final helper = ProfileSecurityHelper(ref);
    final err = await helper.start2FA(state.email);
    state = state.copyWith(isLoading: false, errorMessage: err);
    return err;
  }

  Future<bool> verify2FA(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final helper = ProfileSecurityHelper(ref);
    final ok = await helper.verify2FA(code);
    state = state.copyWith(isLoading: false, is2FAEnabled: ok);
    await _persist();
    return ok;
  }

  Future<void> disable2FA() async {
    state = state.copyWith(is2FAEnabled: false, clearError: true);
    await _persist();
  }

  Future<String?> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final helper = ProfileSecurityHelper(ref);
    final err = await helper.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    state = state.copyWith(isLoading: false, errorMessage: err);
    await _persist();
    return err;
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

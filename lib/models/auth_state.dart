class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String accessToken;
  final String userId;
  final String phoneNumber;
  final String fullName;
  final String email;
  final String refreshToken;
  final DateTime? sessionExpiresAt;
  final bool isOtpRequired;
  final String pendingOtp;
  final String pendingOtpToken;
  final String otpDeliveryTarget;
  final String otpDeliveryChannel;
  final int failedLoginAttempts;
  final DateTime? firstFailedLoginAt;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.accessToken = '',
    this.userId = '',
    this.phoneNumber = '',
    this.fullName = '',
    this.email = '',
    this.refreshToken = '',
    this.sessionExpiresAt,
    this.isOtpRequired = false,
    this.pendingOtp = '',
    this.pendingOtpToken = '',
    this.otpDeliveryTarget = '',
    this.otpDeliveryChannel = '',
    this.failedLoginAttempts = 0,
    this.firstFailedLoginAt,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? accessToken,
    String? userId,
    String? phoneNumber,
    String? fullName,
    String? email,
    String? refreshToken,
    DateTime? sessionExpiresAt,
    bool? isOtpRequired,
    String? pendingOtp,
    String? pendingOtpToken,
    String? otpDeliveryTarget,
    String? otpDeliveryChannel,
    int? failedLoginAttempts,
    DateTime? firstFailedLoginAt,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      refreshToken: refreshToken ?? this.refreshToken,
      sessionExpiresAt: sessionExpiresAt ?? this.sessionExpiresAt,
      isOtpRequired: isOtpRequired ?? this.isOtpRequired,
      pendingOtp: pendingOtp ?? this.pendingOtp,
      pendingOtpToken: pendingOtpToken ?? this.pendingOtpToken,
      otpDeliveryTarget: otpDeliveryTarget ?? this.otpDeliveryTarget,
      otpDeliveryChannel: otpDeliveryChannel ?? this.otpDeliveryChannel,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      firstFailedLoginAt: firstFailedLoginAt ?? this.firstFailedLoginAt,
    );
  }
}

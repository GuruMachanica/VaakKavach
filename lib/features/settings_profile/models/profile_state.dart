class ProfileState {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String avatarPath;
  final bool autoDeleteLogs;
  final bool is2FAEnabled;
  final bool isLoading;
  final String pending2FACode;
  final String? errorMessage;

  const ProfileState({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.avatarPath = '',
    this.autoDeleteLogs = false,
    this.is2FAEnabled = false,
    this.isLoading = false,
    this.pending2FACode = '',
    this.errorMessage,
  });

  ProfileState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarPath,
    bool? autoDeleteLogs,
    bool? is2FAEnabled,
    bool? isLoading,
    String? pending2FACode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarPath: avatarPath ?? this.avatarPath,
      autoDeleteLogs: autoDeleteLogs ?? this.autoDeleteLogs,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      isLoading: isLoading ?? this.isLoading,
      pending2FACode: pending2FACode ?? this.pending2FACode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarPath': avatarPath,
      'autoDeleteLogs': autoDeleteLogs,
      'is2FAEnabled': is2FAEnabled,
      'pending2FACode': pending2FACode,
    };
  }

  factory ProfileState.fromJson(Map<String, dynamic> json) {
    return ProfileState(
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      avatarPath: json['avatarPath']?.toString() ?? '',
      autoDeleteLogs: json['autoDeleteLogs'] == true,
      is2FAEnabled: json['is2FAEnabled'] == true,
      pending2FACode: json['pending2FACode']?.toString() ?? '',
    );
  }
}

/// 프로필 / 계정 설정 폼 상태
class ProfileSettingsFormState {
  const ProfileSettingsFormState({
    required this.nickname,
    required this.email,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.maskedPhone,
    this.obscureCurrentPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    this.isSaving = false,
    this.nicknameError,
    this.currentPasswordError,
    this.newPasswordError,
    this.confirmPasswordError,
  });

  final String nickname;
  final String email;
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final String maskedPhone;
  final bool obscureCurrentPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool isSaving;
  final String? nicknameError;
  final String? currentPasswordError;
  final String? newPasswordError;
  final String? confirmPasswordError;

  bool get hasPasswordInput =>
      currentPassword.isNotEmpty ||
      newPassword.isNotEmpty ||
      confirmPassword.isNotEmpty;

  ProfileSettingsFormState copyWith({
    String? nickname,
    String? email,
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    String? maskedPhone,
    bool? obscureCurrentPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool? isSaving,
    String? nicknameError,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmPasswordError,
    bool clearNicknameError = false,
    bool clearCurrentPasswordError = false,
    bool clearNewPasswordError = false,
    bool clearConfirmPasswordError = false,
  }) {
    return ProfileSettingsFormState(
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      maskedPhone: maskedPhone ?? this.maskedPhone,
      obscureCurrentPassword:
          obscureCurrentPassword ?? this.obscureCurrentPassword,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isSaving: isSaving ?? this.isSaving,
      nicknameError:
          clearNicknameError ? null : (nicknameError ?? this.nicknameError),
      currentPasswordError: clearCurrentPasswordError
          ? null
          : (currentPasswordError ?? this.currentPasswordError),
      newPasswordError: clearNewPasswordError
          ? null
          : (newPasswordError ?? this.newPasswordError),
      confirmPasswordError: clearConfirmPasswordError
          ? null
          : (confirmPasswordError ?? this.confirmPasswordError),
    );
  }
}

enum ProfileSettingsSaveResult {
  success,
  validationFailed,
  failed,
}

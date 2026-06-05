import 'package:art_port/features/mypage/models/profile_settings_data.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileSettingsProvider =
    NotifierProvider.autoDispose<ProfileSettingsNotifier, ProfileSettingsFormState>(
  ProfileSettingsNotifier.new,
);

class ProfileSettingsNotifier extends AutoDisposeNotifier<ProfileSettingsFormState> {
  static const _minNicknameLength = 2;
  static const _minPasswordLength = 8;

  @override
  ProfileSettingsFormState build() {
    final isArtistMode = ref.read(appModeProvider);
    final nickname = isArtistMode
        ? ref.read(artistProfileProvider).name
        : ref.read(clientProfileProvider).name;
    final email = ref.read(clientProfileProvider).email;

    return ProfileSettingsFormState(
      nickname: nickname,
      email: email,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      maskedPhone: '010-****-5678',
    );
  }

  void updateNickname(String value) {
    state = state.copyWith(
      nickname: value,
      clearNicknameError: true,
    );
  }

  void updateCurrentPassword(String value) {
    state = state.copyWith(
      currentPassword: value,
      clearCurrentPasswordError: true,
    );
  }

  void updateNewPassword(String value) {
    state = state.copyWith(
      newPassword: value,
      clearNewPasswordError: true,
      clearConfirmPasswordError: true,
    );
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      clearConfirmPasswordError: true,
    );
  }

  void toggleCurrentPasswordVisibility() {
    state = state.copyWith(
      obscureCurrentPassword: !state.obscureCurrentPassword,
    );
  }

  void toggleNewPasswordVisibility() {
    state = state.copyWith(
      obscureNewPassword: !state.obscureNewPassword,
    );
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  void onVerifyPhone() {
    // TODO: 전화번호 변경/인증 API 연동
  }

  bool _validate() {
    var isValid = true;
    var nicknameError = state.nicknameError;
    var currentPasswordError = state.currentPasswordError;
    var newPasswordError = state.newPasswordError;
    var confirmPasswordError = state.confirmPasswordError;

    final trimmedNickname = state.nickname.trim();
    if (trimmedNickname.isEmpty) {
      nicknameError = '닉네임을 입력해 주세요.';
      isValid = false;
    } else if (trimmedNickname.length < _minNicknameLength) {
      nicknameError = '닉네임은 $_minNicknameLength자 이상 입력해 주세요.';
      isValid = false;
    }

    if (state.hasPasswordInput) {
      if (state.currentPassword.isEmpty) {
        currentPasswordError = '기존 비밀번호를 입력해 주세요.';
        isValid = false;
      }

      if (state.newPassword.isEmpty) {
        newPasswordError = '새 비밀번호를 입력해 주세요.';
        isValid = false;
      } else if (state.newPassword.length < _minPasswordLength) {
        newPasswordError = '새 비밀번호는 $_minPasswordLength자 이상 입력해 주세요.';
        isValid = false;
      }

      if (state.confirmPassword.isEmpty) {
        confirmPasswordError = '새 비밀번호 확인을 입력해 주세요.';
        isValid = false;
      } else if (state.newPassword != state.confirmPassword) {
        confirmPasswordError = '새 비밀번호가 일치하지 않습니다.';
        isValid = false;
      }
    }

    state = state.copyWith(
      nicknameError: nicknameError,
      currentPasswordError: currentPasswordError,
      newPasswordError: newPasswordError,
      confirmPasswordError: confirmPasswordError,
    );

    return isValid;
  }

  Future<ProfileSettingsSaveResult> save() async {
    if (!_validate()) {
      return ProfileSettingsSaveResult.validationFailed;
    }

    state = state.copyWith(isSaving: true);

    try {
      // TODO: 프로필 / 계정 설정 저장 API 연동
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final trimmedNickname = state.nickname.trim();
      final isArtistMode = ref.read(appModeProvider);

      if (isArtistMode) {
        ref.read(artistProfileProvider.notifier).updateName(trimmedNickname);
      } else {
        ref.read(clientProfileProvider.notifier).updateName(trimmedNickname);
      }

      state = state.copyWith(
        nickname: trimmedNickname,
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
        isSaving: false,
      );

      return ProfileSettingsSaveResult.success;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return ProfileSettingsSaveResult.failed;
    }
  }
}

import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/data/dto/user_dto.dart';
import 'package:art_port/features/auth/presentation/auth_session_effects.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
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
    final user = ref.read(authProvider);
    final isArtistMode = ref.read(appModeProvider);
    final nickname = user?.name ??
        (isArtistMode
            ? ref.read(artistProfileProvider).name
            : ref.read(clientProfileProvider).name);
    final email = user?.email ?? ref.read(clientProfileProvider).email;

    return ProfileSettingsFormState(
      nickname: nickname,
      email: email,
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      maskedPhone: _maskPhone(user?.phone ?? ''),
    );
  }

  void updateNickname(String value) {
    state = state.copyWith(
      nickname: value,
      clearNicknameError: true,
      clearSaveError: true,
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

    final user = ref.read(authProvider);
    if (user == null) {
      state = state.copyWith(saveError: '로그인이 필요합니다.');
      return ProfileSettingsSaveResult.failed;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      if (state.hasPasswordInput) {
        state = state.copyWith(
          isSaving: false,
          saveError: '비밀번호 변경은 아직 지원되지 않습니다. 닉네임만 저장할 수 있습니다.',
        );
        return ProfileSettingsSaveResult.failed;
      }

      final trimmedNickname = state.nickname.trim();
      final updated = await ref.read(userRepositoryProvider).updateUser(
            user.id,
            UpdateUserRequest(name: trimmedNickname),
          );
      ref.read(authProvider.notifier).update(updated);
      syncSessionSideEffectsFromRef(ref, updated);

      state = state.copyWith(
        nickname: trimmedNickname,
        email: updated.email,
        maskedPhone: _maskPhone(updated.phone),
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
        isSaving: false,
      );

      return ProfileSettingsSaveResult.success;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: e.displayMessage,
      );
      return ProfileSettingsSaveResult.failed;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        saveError: '저장에 실패했습니다. 다시 시도해 주세요.',
      );
      return ProfileSettingsSaveResult.failed;
    }
  }

  Future<bool> deactivateAccount() async {
    final user = ref.read(authProvider);
    if (user == null) {
      state = state.copyWith(saveError: '로그인이 필요합니다.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      await ref.read(userRepositoryProvider).deactivateUser(user.id);
      ref.read(authProvider.notifier).signOut();
      ref.read(showMyPageProvider.notifier).close();
      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: e.displayMessage,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        saveError: '회원 탈퇴에 실패했습니다. 다시 시도해 주세요.',
      );
      return false;
    }
  }

  static String _maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 11) {
      return '${digits.substring(0, 3)}-****-${digits.substring(7)}';
    }
    if (digits.length >= 7) {
      return '${digits.substring(0, 3)}-****-${digits.substring(digits.length - 4)}';
    }
    if (phone.isEmpty) return '-';
    return phone;
  }
}

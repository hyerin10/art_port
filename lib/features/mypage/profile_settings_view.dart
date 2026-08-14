import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/mypage/models/profile_settings_data.dart';
import 'package:art_port/features/mypage/profile_settings_providers.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSettingsView extends ConsumerStatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  ConsumerState<ProfileSettingsView> createState() =>
      _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends ConsumerState<ProfileSettingsView> {
  final _nicknameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _initialized = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    final result = await ref.read(profileSettingsProvider.notifier).save();

    if (!mounted) return;

    switch (result) {
      case ProfileSettingsSaveResult.success:
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('변경 사항이 저장되었습니다.')),
        );
      case ProfileSettingsSaveResult.validationFailed:
        break;
      case ProfileSettingsSaveResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(profileSettingsProvider).saveError ??
                  '저장에 실패했습니다. 다시 시도해 주세요.',
            ),
          ),
        );
    }
  }

  Future<void> _onDeactivate() async {
    FocusScope.of(context).unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까? 탈퇴 후에는 계정을 사용할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success =
        await ref.read(profileSettingsProvider.notifier).deactivateAccount();
    if (!mounted) return;

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(profileSettingsProvider).saveError ??
              '회원 탈퇴에 실패했습니다. 다시 시도해 주세요.',
        ),
      ),
    );
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(profileSettingsProvider);
    final notifier = ref.read(profileSettingsProvider.notifier);

    if (!_initialized) {
      _nicknameController.text = form.nickname;
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _onClose,
          icon: const Icon(Icons.close_rounded, size: 26),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          '프로필 / 계정 설정',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.borderLight),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsTextField(
                    controller: _nicknameController,
                    label: '닉네임',
                    onChanged: notifier.updateNickname,
                    errorText: form.nicknameError,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),
                  _ReadOnlyField(
                    label: '이메일',
                    value: form.email,
                    helperText: '이메일은 변경할 수 없습니다',
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '비밀번호 변경',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SettingsTextField(
                    controller: _currentPasswordController,
                    hintText: '기존 비밀번호',
                    obscureText: form.obscureCurrentPassword,
                    onChanged: notifier.updateCurrentPassword,
                    errorText: form.currentPasswordError,
                    textInputAction: TextInputAction.next,
                    suffixIcon: PasswordVisibilityToggle(
                      obscured: form.obscureCurrentPassword,
                      onToggle: notifier.toggleCurrentPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SettingsTextField(
                    controller: _newPasswordController,
                    hintText: '새 비밀번호',
                    obscureText: form.obscureNewPassword,
                    onChanged: notifier.updateNewPassword,
                    errorText: form.newPasswordError,
                    textInputAction: TextInputAction.next,
                    suffixIcon: PasswordVisibilityToggle(
                      obscured: form.obscureNewPassword,
                      onToggle: notifier.toggleNewPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SettingsTextField(
                    controller: _confirmPasswordController,
                    hintText: '새 비밀번호 확인',
                    obscureText: form.obscureConfirmPassword,
                    onChanged: notifier.updateConfirmPassword,
                    errorText: form.confirmPasswordError,
                    textInputAction: TextInputAction.done,
                    suffixIcon: PasswordVisibilityToggle(
                      obscured: form.obscureConfirmPassword,
                      onToggle: notifier.toggleConfirmPasswordVisibility,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '전화번호',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _ReadOnlyField(value: form.maskedPhone),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: notifier.onVerifyPhone,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          '변경/인증',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: form.isSaving ? null : _onDeactivate,
                      child: const Text(
                        '회원 탈퇴',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: form.isSaving ? null : _onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: form.isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '저장하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ArtPortBottomNav(
        onTabSelected: (index) {
          ref.read(showMyPageProvider.notifier).close();
          ref.read(currentTabProvider.notifier).selectTab(index);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.value,
    this.label,
    this.helperText,
  });

  final String value;
  final String? label;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

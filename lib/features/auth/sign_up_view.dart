import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/auth_providers.dart';
import 'package:art_port/features/auth/widgets/auth_field_error.dart';
import 'package:art_port/features/auth/widgets/auth_text_field.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).pop();
  }

  void _onClose() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onSignUp() async {
    FocusScope.of(context).unfocus();
    final form = ref.read(signUpFormProvider);
    final success = await ref.read(signUpFormProvider.notifier).submit();
    if (!success || !mounted) return;

    ref.read(clientProfileProvider.notifier).updateName(form.name.trim());
    ref.read(authProvider.notifier).signIn();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onSignInTap() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(signUpFormProvider);
    final notifier = ref.read(signUpFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 24),
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _onClose,
                    icon: const Icon(Icons.close_rounded, size: 26),
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '회원가입',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _nameController,
                      label: '이름',
                      hintText: '홍길동',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      onChanged: notifier.updateName,
                      errorText: form.nameError,
                      status: form.nameError != null
                          ? AuthFieldStatus.error
                          : AuthFieldStatus.neutral,
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _emailController,
                      label: '이메일',
                      hintText: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: notifier.updateEmail,
                      errorText: form.emailError,
                      status: form.emailError != null
                          ? AuthFieldStatus.error
                          : form.showEmailSuccess
                              ? AuthFieldStatus.success
                              : AuthFieldStatus.neutral,
                    ),
                    const SizedBox(height: 20),
                    _PhoneField(
                      phoneController: _phoneController,
                      verificationCodeController: _verificationCodeController,
                      isVerified: form.isPhoneVerified,
                      isVerifying: form.isVerifyingPhone,
                      verificationCodeSent: form.verificationCodeSent,
                      canRequestVerification: form.canRequestVerification,
                      canConfirmVerification: form.canConfirmVerification,
                      phoneError: form.phoneError,
                      verificationError: form.phoneVerificationErrorMessage,
                      showSuccess: form.showPhoneSuccess,
                      onPhoneChanged: (value) {
                        notifier.updatePhone(value);
                        _verificationCodeController.clear();
                      },
                      onVerificationCodeChanged: notifier.updateVerificationCode,
                      onRequestVerification: notifier.requestVerificationCode,
                      onConfirmVerification: notifier.confirmVerificationCode,
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _passwordController,
                      label: '비밀번호',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: form.obscurePassword,
                      textInputAction: TextInputAction.next,
                      onChanged: notifier.updatePassword,
                      errorText: form.passwordError,
                      status: form.passwordError != null
                          ? AuthFieldStatus.error
                          : AuthFieldStatus.neutral,
                      suffixIcon: PasswordVisibilityToggle(
                        obscured: form.obscurePassword,
                        onToggle: notifier.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _confirmPasswordController,
                      label: '비밀번호 확인',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: form.obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onChanged: notifier.updateConfirmPassword,
                      errorText: form.confirmPasswordError,
                      status: form.confirmPasswordError != null
                          ? AuthFieldStatus.error
                          : AuthFieldStatus.neutral,
                      suffixIcon: PasswordVisibilityToggle(
                        obscured: form.obscureConfirmPassword,
                        onToggle: notifier.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _PrimaryAuthButton(
                      label: 'Sign Up',
                      enabled: form.canSubmit,
                      isLoading: form.isSubmitting,
                      onPressed: _onSignUp,
                    ),
                    const SizedBox(height: 24),
                    _AuthFooterLink(
                      prompt: 'Already have an account? ',
                      actionLabel: 'Sign in',
                      onTap: _onSignInTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.phoneController,
    required this.verificationCodeController,
    required this.isVerified,
    required this.isVerifying,
    required this.verificationCodeSent,
    required this.canRequestVerification,
    required this.canConfirmVerification,
    required this.phoneError,
    required this.verificationError,
    required this.showSuccess,
    required this.onPhoneChanged,
    required this.onVerificationCodeChanged,
    required this.onRequestVerification,
    required this.onConfirmVerification,
  });

  final TextEditingController phoneController;
  final TextEditingController verificationCodeController;
  final bool isVerified;
  final bool isVerifying;
  final bool verificationCodeSent;
  final bool canRequestVerification;
  final bool canConfirmVerification;
  final String? phoneError;
  final String? verificationError;
  final bool showSuccess;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onVerificationCodeChanged;
  final VoidCallback onRequestVerification;
  final VoidCallback onConfirmVerification;

  Color get _phoneBorderColor {
    if (phoneError != null || verificationError != null) return AppColors.error;
    if (showSuccess) return AppColors.success;
    return AppColors.borderSubtle;
  }

  String? get _displayError => verificationError ?? phoneError;

  @override
  Widget build(BuildContext context) {
    final buttonLabel = isVerified
        ? '인증 완료'
        : verificationCodeSent
            ? '확인'
            : '인증하기';

    final buttonColor = isVerified
        ? AppColors.success
        : verificationCodeSent
            ? (canConfirmVerification ? AppColors.info : AppColors.textMuted)
            : canRequestVerification
                ? AppColors.info
                : AppColors.textMuted;

    final canPressButton = isVerified
        ? false
        : isVerifying
            ? false
            : verificationCodeSent
                ? canConfirmVerification
                : canRequestVerification;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '전화번호',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !isVerified,
                onChanged: onPhoneChanged,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '01012345678',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _phoneBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _phoneBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: phoneError != null ||
                              verificationError != null ||
                              showSuccess
                          ? _phoneBorderColor
                          : AppColors.textPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: canPressButton
                    ? () {
                        if (verificationCodeSent) {
                          onConfirmVerification();
                        } else {
                          onRequestVerification();
                        }
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: buttonColor,
                  disabledForegroundColor: buttonColor,
                  side: BorderSide(color: buttonColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: isVerifying
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: buttonColor,
                        ),
                      )
                    : Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (verificationCodeSent && !isVerified) ...[
          const SizedBox(height: 12),
          TextField(
            controller: verificationCodeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onChanged: onVerificationCodeChanged,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '인증번호 6자리',
              hintStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.background,
              prefixIcon: const Icon(
                Icons.sms_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: verificationError != null
                      ? AppColors.error
                      : AppColors.borderSubtle,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: verificationError != null
                      ? AppColors.error
                      : AppColors.borderSubtle,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: verificationError != null
                      ? AppColors.error
                      : AppColors.textPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
        if (_displayError != null) AuthFieldError(message: _displayError!),
      ],
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  static const Color _disabledColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: _disabledColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _AuthFooterLink extends StatelessWidget {
  const _AuthFooterLink({
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: prompt),
              TextSpan(
                text: actionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

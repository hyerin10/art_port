import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/auth_messages.dart';
import 'package:art_port/features/auth/auth_providers.dart';
import 'package:art_port/features/auth/email_verification/email_verification_pending_screen.dart';
import 'package:art_port/features/auth/widgets/auth_footer_link.dart';
import 'package:art_port/features/auth/widgets/auth_primary_button.dart';
import 'package:art_port/features/auth/widgets/auth_text_field.dart';
import 'package:art_port/features/auth/widgets/password_visibility_toggle.dart';
import 'package:art_port/features/auth/widgets/phone_verification_field.dart';
import 'package:art_port/features/auth/widgets/social_login_button.dart';
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

  Future<void> _finishAuthSuccess() async {
    final user = ref.read(authProvider);
    if (user != null && !user.isEmailVerified) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (!mounted) return;
      await EmailVerificationPendingScreen.open(context);
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onSignUp() async {
    FocusScope.of(context).unfocus();
    final success = await ref.read(signUpFormProvider.notifier).submit();
    if (!mounted) return;

    final form = ref.read(signUpFormProvider);
    if (form.submitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(form.submitError!)),
      );
    }
    if (!success) return;

    await _finishAuthSuccess();
  }

  Future<void> _onGoogleSignUp() async {
    FocusScope.of(context).unfocus();
    final success =
        await ref.read(signUpFormProvider.notifier).signUpWithGoogle();
    if (!mounted) return;

    final form = ref.read(signUpFormProvider);
    if (form.submitError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(form.submitError!)),
      );
    }
    if (!success) return;

    // Google 가입은 서버에서 이메일이 이미 인증된 상태로 생성됩니다.
    await _finishAuthSuccess();
  }

  void _onSignInTap() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      signUpFormProvider.select((form) => form.verificationCode),
      (previous, next) {
        if (next.isEmpty && _verificationCodeController.text.isNotEmpty) {
          _verificationCodeController.clear();
        }
      },
    );

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
                    SocialLoginButton(
                      label: AuthMessages.googleSignUp,
                      leading: const GoogleLogo(),
                      enabled: form.canSocialSubmit,
                      isLoading: form.isGoogleSubmitting,
                      onPressed: _onGoogleSignUp,
                    ),
                    const SizedBox(height: 24),
                    const _OrDivider(),
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
                    PhoneVerificationField(
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
                      onPhoneChanged: notifier.updatePhone,
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
                    AuthPrimaryButton(
                      label: 'Sign Up',
                      enabled: form.canSubmit,
                      isLoading:
                          form.isSubmitting && !form.isGoogleSubmitting,
                      onPressed: _onSignUp,
                    ),
                    const SizedBox(height: 24),
                    AuthFooterLink(
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderLight, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.borderLight, thickness: 1)),
      ],
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/auth_providers.dart';
import 'package:art_port/features/auth/sign_up_screen.dart';
import 'package:art_port/features/auth/widgets/auth_footer_link.dart';
import 'package:art_port/features/auth/widgets/auth_logo.dart';
import 'package:art_port/features/auth/widgets/auth_primary_button.dart';
import 'package:art_port/features/auth/widgets/auth_text_field.dart';
import 'package:art_port/features/auth/widgets/password_visibility_toggle.dart';
import 'package:art_port/features/auth/widgets/social_login_button.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      ref.read(signInFormProvider.notifier).markEmailBlurred();
    }
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onClose() {
    Navigator.of(context).pop();
  }

  Future<void> _onSignIn() async {
    FocusScope.of(context).unfocus();
    final success = await ref.read(signInFormProvider.notifier).submit();
    if (!success || !mounted) return;

    ref.read(authProvider.notifier).signIn();
    Navigator.of(context).pop();
  }

  void _onSignUpTap() {
    SignUpScreen.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(signInFormProvider);
    final notifier = ref.read(signInFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
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
                    const AuthLogo(height: 148),
                    const SizedBox(height: 4),
                    const Text(
                      '로그인',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SocialLoginButton(
                      label: 'Continue with Google',
                      leading: const GoogleLogo(),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    SocialLoginButton(
                      label: 'Continue with X',
                      leading: const XLogo(),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 28),
                    const _OrDivider(),
                    const SizedBox(height: 28),
                    Focus(
                      focusNode: _emailFocusNode,
                      child: AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: notifier.updateEmail,
                        errorText: form.emailError,
                        status: form.emailError != null
                            ? AuthFieldStatus.error
                            : AuthFieldStatus.neutral,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: form.obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: notifier.updatePassword,
                      onSubmitted: (_) {
                        if (form.canSubmit) _onSignIn();
                      },
                      errorText: form.passwordError,
                      status: form.passwordError != null
                          ? AuthFieldStatus.error
                          : AuthFieldStatus.neutral,
                      suffixIcon: PasswordVisibilityToggle(
                        obscured: form.obscurePassword,
                        onToggle: notifier.togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.info,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthPrimaryButton(
                      label: 'Sign In',
                      enabled: form.canSubmit,
                      isLoading: form.isSubmitting,
                      onPressed: _onSignIn,
                    ),
                    const SizedBox(height: 24),
                    AuthFooterLink(
                      prompt: "Don't have an account? ",
                      actionLabel: 'Sign up',
                      onTap: _onSignUpTap,
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
            'OR',
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

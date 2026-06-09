import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/auth_messages.dart';
import 'package:art_port/features/auth/forgot_password_providers.dart';
import 'package:art_port/features/auth/widgets/auth_logo.dart';
import 'package:art_port/features/auth/widgets/auth_primary_button.dart';
import 'package:art_port/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      ref.read(forgotPasswordProvider.notifier).markEmailBlurred();
    }
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).pop();
  }

  Future<void> _onSendTemporaryPassword() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(forgotPasswordProvider.notifier)
        .sendTemporaryPassword(_emailController.text);
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('전송 완료'),
        content: const Text(AuthMessages.forgotPasswordSuccessMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (previous, next) {
      if (next.status == ForgotPasswordStatus.success) {
        _showSuccessDialog();
      } else if (next.status == ForgotPasswordStatus.failure) {
        final message =
            next.errorMessage ?? AuthMessages.forgotPasswordEmailNotFound;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(forgotPasswordProvider.notifier).clearFailure();
      }
    });

    final state = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 24),
                    color: AppColors.textPrimary,
                  ),
                  const Expanded(
                    child: Text(
                      '비밀번호 찾기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
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
                    const SizedBox(height: 24),
                    const Text(
                      '회원가입 시 입력한 이메일을 입력해주세요.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Focus(
                      focusNode: _emailFocusNode,
                      child: AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onChanged: notifier.updateEmail,
                        onSubmitted: (_) {
                          if (state.canSubmit) _onSendTemporaryPassword();
                        },
                        errorText: state.emailError,
                        status: state.emailError != null
                            ? AuthFieldStatus.error
                            : AuthFieldStatus.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: AuthPrimaryButton(
                label: '임시 비밀번호 전송하기',
                enabled: state.canSubmit,
                isLoading: state.isLoading,
                onPressed: _onSendTemporaryPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/email_verification/email_verification_providers.dart';
import 'package:art_port/features/auth/email_verification/verification_failure_screen.dart';
import 'package:art_port/features/auth/email_verification/verification_success_screen.dart';
import 'package:art_port/features/auth/widgets/auth_primary_button.dart';
import 'package:art_port/features/auth/widgets/auth_text_field.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationPendingView extends ConsumerStatefulWidget {
  const EmailVerificationPendingView({super.key});

  @override
  ConsumerState<EmailVerificationPendingView> createState() =>
      _EmailVerificationPendingViewState();
}

class _EmailVerificationPendingViewState
    extends ConsumerState<EmailVerificationPendingView> {
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(emailVerificationFlowProvider.notifier);
      notifier.reset();
      notifier.sendCode();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onBack() {
    ref.read(emailVerificationFlowProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  void _onCodeChanged(String value) {
    ref.read(emailVerificationFlowProvider.notifier).updateVerificationCode(value);

    final normalized = ref.read(emailVerificationFlowProvider).verificationCode;
    if (_codeController.text != normalized) {
      _codeController.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();
    final success =
        await ref.read(emailVerificationFlowProvider.notifier).confirmCode();
    if (!mounted) return;

    if (success) {
      ref.read(emailVerificationFlowProvider.notifier).reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const VerificationSuccessScreen(),
        ),
      );
      return;
    }

    final error = ref.read(emailVerificationFlowProvider).errorMessage;
    if (error != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const VerificationFailureScreen(),
        ),
      );
    }
  }

  Future<void> _onResend() async {
    await ref.read(emailVerificationFlowProvider.notifier).resendCode();
    if (!mounted) return;
    _codeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인증번호를 다시 보냈습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(emailVerificationFlowProvider);
    final email = ref.watch(clientProfileProvider).email;

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
                      '이메일 인증',
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
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_rounded,
                          size: 48,
                          color: AppColors.brandNavy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '메일을 확인해주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$email(으)로 발송된\n6자리 인증번호를 입력해주세요.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      controller: _codeController,
                      label: '인증번호',
                      hintText: '인증번호 6자리',
                      prefixIcon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: _onCodeChanged,
                      onSubmitted: (_) {
                        if (flow.canConfirm) _onConfirm();
                      },
                      errorText: flow.displayError,
                      status: flow.displayError != null
                          ? AuthFieldStatus.error
                          : AuthFieldStatus.neutral,
                    ),
                    if (flow.isSending) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          '인증번호를 발송하는 중입니다...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: AuthPrimaryButton(
                label: '인증 확인',
                enabled: flow.canConfirm,
                isLoading: flow.isVerifying,
                backgroundColor: AppColors.brandNavy,
                onPressed: _onConfirm,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: TextButton(
                onPressed: flow.canResend ? _onResend : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandNavy,
                  disabledForegroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: flow.isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '다시 보내기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

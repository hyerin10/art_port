import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/email_verification/email_verification_pending_screen.dart';
import 'package:art_port/features/auth/widgets/auth_primary_button.dart';
import 'package:flutter/material.dart';

class VerificationFailureView extends StatelessWidget {
  const VerificationFailureView({super.key});

  void _onRetry(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const EmailVerificationPendingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_rounded,
                        size: 64,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '인증 실패',
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
                    const Text(
                      '인증번호가 일치하지 않거나 만료되었습니다.\n다시 인증을 시도해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: AuthPrimaryButton(
                label: '재시도',
                enabled: true,
                backgroundColor: AppColors.brandNavy,
                onPressed: () => _onRetry(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

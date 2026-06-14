import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/widgets/auth_primary_button.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerificationSuccessView extends ConsumerWidget {
  const VerificationSuccessView({super.key});

  void _onGoHome(BuildContext context, WidgetRef ref) {
    ref.read(isEmailVerifiedProvider.notifier).markVerified();
    ref.read(currentTabProvider.notifier).selectTab(0);
    ref.read(showMyPageProvider.notifier).close();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        color: AppColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '인증 성공',
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
                      '이메일 인증이 완료되었습니다.\n이제 ArtPort의 모든 기능을 이용할 수 있습니다.',
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
                label: '홈으로',
                enabled: true,
                backgroundColor: AppColors.brandNavy,
                onPressed: () => _onGoHome(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

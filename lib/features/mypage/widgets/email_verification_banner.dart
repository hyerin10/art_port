import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class EmailVerificationBanner extends StatelessWidget {
  const EmailVerificationBanner({
    super.key,
    required this.onVerify,
  });

  final VoidCallback onVerify;

  static const _bannerBackground = Color(0xFFFFF4F4);
  static const _titleColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _bannerBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이메일 인증이 필요합니다',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '보안을 위해 계정을 인증해주세요.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onVerify,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              '인증하기',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

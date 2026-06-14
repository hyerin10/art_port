import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 출금 신청하기 하단 고정 버튼
class WithdrawalFooterButton extends StatelessWidget {
  const WithdrawalFooterButton({
    super.key,
    required this.enabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: enabled && !isSubmitting ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.chipBackground,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '출금 신청하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 마이페이지 설정 화면 하단 저장 버튼
class MyPageSaveFooterButton extends StatelessWidget {
  const MyPageSaveFooterButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSaving = false,
    this.enabled = true,
    this.borderRadius = 14,
    this.showShadow = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSaving;
  final bool enabled;
  final double borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: enabled && !isSaving ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isSaving
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

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: showShadow
            ? BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              )
            : null,
        child: button,
      ),
    );
  }
}

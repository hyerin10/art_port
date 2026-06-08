import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 비밀번호 가시성 토글 아이콘
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.obscured,
    required this.onToggle,
  });

  final bool obscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 22,
        color: AppColors.textMuted,
      ),
    );
  }
}

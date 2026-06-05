import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 인풋 필드 하단 에러 안내 문구
class AuthFieldError extends StatelessWidget {
  const AuthFieldError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
          height: 1.4,
        ),
      ),
    );
  }
}

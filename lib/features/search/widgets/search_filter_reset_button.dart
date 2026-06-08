import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 필터 칩 행 맨 앞 — 전체 필터 초기화
class SearchFilterResetButton extends StatelessWidget {
  const SearchFilterResetButton({
    super.key,
    required this.onTap,
    required this.isActive,
  });

  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isActive ? AppColors.primary : AppColors.textSecondary;

    return Tooltip(
      message: '필터 초기화',
      child: Material(
        color: isActive ? AppColors.primaryLight : AppColors.chipBackground,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

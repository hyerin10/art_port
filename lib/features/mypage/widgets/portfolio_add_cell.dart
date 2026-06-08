import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/dashed_border.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 그리드 — 이미지 추가 셀
class PortfolioAddCell extends StatelessWidget {
  const PortfolioAddCell({
    super.key,
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorder(
        color: AppColors.primary.withValues(alpha: 0.55),
        radius: 14,
        strokeWidth: 1.5,
        dashWidth: 6,
        dashGap: 4,
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 28,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                '추가',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

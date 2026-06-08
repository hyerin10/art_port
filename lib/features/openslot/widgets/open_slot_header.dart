import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 슬롯 관리 화면 상단 타이틀
class OpenSlotHeader extends StatelessWidget {
  const OpenSlotHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '슬롯 관리',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '내 커미션 슬롯을 효율적으로 관리하세요',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

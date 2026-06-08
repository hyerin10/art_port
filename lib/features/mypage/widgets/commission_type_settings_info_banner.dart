import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 커미션 타입 설정 안내 배너
class CommissionTypeSettingsInfoBanner extends StatelessWidget {
  const CommissionTypeSettingsInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: const Text(
        '커미션 타입과 가격을 설정하세요. 각 타입별로 슬롯을 관리할 수 있습니다.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

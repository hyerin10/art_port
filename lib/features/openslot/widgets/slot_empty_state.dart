import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 등록된 슬롯이 없을 때 표시
class SlotEmptyState extends StatelessWidget {
  const SlotEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          '등록된 슬롯이 없습니다.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

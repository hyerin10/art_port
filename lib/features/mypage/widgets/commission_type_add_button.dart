import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 커미션 타입 추가 버튼
class CommissionTypeAddButton extends StatelessWidget {
  const CommissionTypeAddButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 22, color: Colors.white),
              SizedBox(width: 6),
              Text(
                '새 타입 추가',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

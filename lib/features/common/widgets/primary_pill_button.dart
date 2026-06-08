import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 전체 너비 primary CTA 버튼
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.fullWidth = true,
    this.elevation = 3,
  });

  final String label;
  final VoidCallback onTap;
  final bool fullWidth;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          width: fullWidth ? double.infinity : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 마이페이지 메뉴 리스트 아이템
class MenuListItem extends StatelessWidget {
  const MenuListItem({
    super.key,
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.onTap,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

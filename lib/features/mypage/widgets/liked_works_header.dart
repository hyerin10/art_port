import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 찜한 작품 화면 헤더 — 뒤로가기, 타이틀, 알림, 필터 (모드 전환 버튼 없음)
class LikedWorksHeader extends StatelessWidget {
  const LikedWorksHeader({
    super.key,
    required this.onBack,
    this.onNotificationTap,
    this.onFilterTap,
  });

  final VoidCallback onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;

  static const double _actionSize = 40;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: AppColors.textPrimary,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '찜한 작품',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                    ),
                    _NotificationButton(onPressed: onNotificationTap ?? () {}),
                    const SizedBox(width: 4),
                    _IconActionButton(
                      icon: Icons.tune,
                      onPressed: onFilterTap ?? () {},
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LikedWorksHeader._actionSize,
      height: LikedWorksHeader._actionSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.notifications_outlined, size: 24),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: LikedWorksHeader._actionSize,
              minHeight: LikedWorksHeader._actionSize,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.notificationBadge,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LikedWorksHeader._actionSize,
      height: LikedWorksHeader._actionSize,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        color: AppColors.textPrimary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: LikedWorksHeader._actionSize,
          minHeight: LikedWorksHeader._actionSize,
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 공지사항 설정 화면 헤더
class NoticeSettingsHeader extends StatelessWidget {
  const NoticeSettingsHeader({
    super.key,
    required this.onBack,
    this.onNotificationTap,
  });

  final VoidCallback onBack;
  final VoidCallback? onNotificationTap;

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
                        '공지사항 설정',
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
                    const SizedBox(width: 40),
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
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.notifications_outlined, size: 24),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1:1 문의 화면 헤더
class InquiryHeader extends ConsumerWidget {
  const InquiryHeader({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtistMode = ref.watch(appModeProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                      '1:1 문의',
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
                  const SizedBox(width: 6),
                  _ModeToggleChip(
                    isArtistMode: isArtistMode,
                    onTap: () =>
                        ref.read(appModeProvider.notifier).toggleMode(),
                  ),
                ],
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
      width: InquiryHeader._actionSize,
      height: InquiryHeader._actionSize,
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
              minWidth: InquiryHeader._actionSize,
              minHeight: InquiryHeader._actionSize,
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
      width: InquiryHeader._actionSize,
      height: InquiryHeader._actionSize,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        color: AppColors.textPrimary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: InquiryHeader._actionSize,
          minHeight: InquiryHeader._actionSize,
        ),
      ),
    );
  }
}

class _ModeToggleChip extends StatelessWidget {
  const _ModeToggleChip({
    required this.isArtistMode,
    required this.onTap,
  });

  final bool isArtistMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isArtistMode ? 'Client' : 'Artist';

    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

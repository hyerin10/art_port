import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/sign_in_screen.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtPortHeader extends ConsumerWidget {
  const ArtPortHeader({super.key});

  static const double _actionSize = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtistMode = ref.watch(appModeProvider);
    final isLoggedIn = ref.watch(authProvider);

    final profileAvatarUrl = isArtistMode
        ? ref.watch(artistProfileProvider).avatarUrl
        : ref.watch(clientProfileProvider).avatarUrl;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        minimum: const EdgeInsets.only(top: 4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const Text(
              'ArtPort',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            const Spacer(),
            _NotificationButton(onPressed: () {}),
            const SizedBox(width: 6),
            _IconActionButton(
              icon: Icons.tune,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            _ModeToggleChip(
              isArtistMode: isArtistMode,
              onTap: () => ref.read(appModeProvider.notifier).toggleMode(),
            ),
            const SizedBox(width: 10),
            if (isLoggedIn)
              _ProfileAvatar(
                imageUrl: profileAvatarUrl,
                onTap: () => ref.read(showMyPageProvider.notifier).open(),
              )
            else
              _GuestProfileIcon(
                onTap: () => SignInScreen.open(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onPressed});

  final VoidCallback onPressed;

  static const double _size = ArtPortHeader._actionSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
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
              minWidth: _size,
              minHeight: _size,
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

  static const double _size = ArtPortHeader._actionSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        color: AppColors.textPrimary,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: _size,
          minHeight: _size,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
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

class _GuestProfileIcon extends StatelessWidget {
  const _GuestProfileIcon({required this.onTap});

  final VoidCallback onTap;

  static const double _size = ArtPortHeader._actionSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.chipBackground,
          border: Border.all(color: AppColors.borderLight, width: 1.5),
        ),
        child: const Icon(
          Icons.person_outline_rounded,
          size: 22,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.onTap,
  });

  final String imageUrl;
  final VoidCallback onTap;

  static const double _size = ArtPortHeader._actionSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.chipBackground,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.onlineStatus,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

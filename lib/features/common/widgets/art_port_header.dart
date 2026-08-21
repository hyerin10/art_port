import 'package:art_port/core/config/api_config.dart';
import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/sign_in_screen.dart';
import 'package:art_port/features/mypage/data/mypage_write_providers.dart';
import 'package:art_port/features/mypage/models/mypage_data.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtPortHeader extends ConsumerWidget {
  const ArtPortHeader({super.key, this.onProfileTap});

  /// 지정 시 프로필 탭 기본 동작(마이페이지 열기/닫기) 대신 호출됩니다.
  final VoidCallback? onProfileTap;

  static const double _actionSize = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtistMode = ref.watch(appModeProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final showMyPage = ref.watch(showMyPageProvider);

    final profileAvatarUrl = isArtistMode
        ? resolveProfileAvatarUrl(
            ref.watch(myArtistProfileProvider).valueOrNull?.avatarUrl,
            ref.watch(artistProfileProvider).avatarUrl,
          )
        : resolveProfileAvatarUrl(
            ref.watch(myClientProfileProvider).valueOrNull?.avatarUrl,
            ref.watch(clientProfileProvider).avatarUrl,
          );

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
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.centerRight,
              child: showMyPage
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _ModeToggleChip(
                        isArtistMode: isArtistMode,
                        onTap: () =>
                            ref.read(appModeProvider.notifier).toggleMode(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            if (isLoggedIn)
              _ProfileAvatar(
                imageUrl: profileAvatarUrl,
                onTap: onProfileTap ??
                    () => ref.read(showMyPageProvider.notifier).toggle(),
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
    final hasAvatar = imageUrl.trim().isNotEmpty;

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
                backgroundImage: hasAvatar
                    ? NetworkImage(ApiConfig.resolveMediaUrl(imageUrl))
                    : null,
                child: hasAvatar
                    ? null
                    : const Icon(
                        Icons.person_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
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

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_profile/models/artist_public_profile.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:flutter/material.dart';

/// 작가 프로필 상단 기본 정보 + 팔로우/알림 + SNS 칩
class ArtistProfileInfoSection extends StatelessWidget {
  const ArtistProfileInfoSection({
    super.key,
    required this.profile,
    required this.isFollowing,
    required this.notificationsEnabled,
    required this.onFollowTap,
    required this.onNotificationTap,
    this.onFollowersTap,
    this.reviewStats,
  });

  final ArtistPublicProfile profile;
  final bool isFollowing;
  final bool notificationsEnabled;
  final VoidCallback? onFollowTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onFollowersTap;
  final ReviewStats? reviewStats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(imageUrl: profile.avatarUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.oneLineIntro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reviewStats?.averageLabel ?? profile.formattedRating,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (reviewStats != null)
                          Text(
                            ' ${reviewStats!.countLabel}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFollowersTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '팔로워',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.formattedFollowerCount,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (onFollowTap != null) ...[
                Expanded(
                  child: Material(
                    color: isFollowing
                        ? AppColors.chipBackground
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onFollowTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          isFollowing ? '팔로잉' : '팔로우',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isFollowing
                                ? AppColors.textSecondary
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Material(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onNotificationTap,
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      notificationsEnabled
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      size: 22,
                      color: notificationsEnabled
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (profile.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: profile.socialLinks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final link = profile.socialLinks[index];
                  return _SocialLinkChip(link: link);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

  final String imageUrl;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryLight, width: 2),
      ),
      child: CircleAvatar(
        radius: _size / 2,
        backgroundColor: AppColors.chipBackground,
        backgroundImage: imageUrl.isEmpty
            ? null
            : (imageUrl.startsWith('assets/')
                  ? AssetImage(imageUrl)
                  : NetworkImage(imageUrl)),
      ),
    );
  }
}

class _SocialLinkChip extends StatelessWidget {
  const _SocialLinkChip({required this.link});

  final ArtistSocialLink link;

  IconData get _icon => switch (link.type) {
    ArtistSocialLinkType.twitter => Icons.alternate_email_rounded,
    ArtistSocialLinkType.instagram => Icons.camera_alt_outlined,
    ArtistSocialLinkType.website => Icons.link_rounded,
    ArtistSocialLinkType.other => Icons.link_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                link.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

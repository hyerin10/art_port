import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/artist_profile/artist_profile_screen.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/follow/models/follower_list_item.dart';
import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/providers/followed_artists_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowersView extends ConsumerWidget {
  const FollowersView({
    super.key,
    required this.userId,
    this.title = '팔로워',
  });

  final String userId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followersProvider(userId));

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      header: InquiryHeader(
        title: title,
        onBack: () => Navigator.of(context).pop(),
        showActions: false,
      ),
      body: ApiAsyncBody<List<FollowerListItem>>(
        value: followersAsync,
        onRetry: () => ref.invalidate(followersProvider(userId)),
        errorMessage: '팔로워 목록을 불러오지 못했습니다.',
        builder: (followers) {
          if (followers.isEmpty) {
            return const EmptyStateView(
              icon: Icons.people_outline_rounded,
              title: '아직 팔로워가 없습니다',
              subtitle: '작품을 올리면 팔로워가 생길 수 있어요',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: followers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _FollowerTile(item: followers[index]);
            },
          );
        },
      ),
    );
  }
}

class _FollowerTile extends StatelessWidget {
  const _FollowerTile({required this.item});

  final FollowerListItem item;

  @override
  Widget build(BuildContext context) {
    final artistId = item.artistProfileId;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: artistId == null
            ? null
            : () => ArtistProfileScreen.open(context, artistId: artistId),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.chipBackground,
                backgroundImage: item.avatarUrl.startsWith('assets/')
                    ? AssetImage(item.avatarUrl)
                    : NetworkImage(item.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artistId == null ? '의뢰자' : '작가 프로필 보기',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (artistId != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

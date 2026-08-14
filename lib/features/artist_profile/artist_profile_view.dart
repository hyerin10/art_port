import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/artist_profile/artist_profile_providers.dart';
import 'package:art_port/features/artist_profile/widgets/artist_notice_tab.dart';
import 'package:art_port/features/artist_profile/widgets/artist_portfolio_tab.dart';
import 'package:art_port/features/artist_profile/widgets/artist_reviews_tab.dart';
import 'package:art_port/features/artist_profile/widgets/artist_profile_info_section.dart';
import 'package:art_port/features/artist_profile/widgets/artist_profile_sub_header.dart';
import 'package:art_port/features/artist_profile/widgets/artist_profile_tab.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/follow/followers_screen.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:art_port/providers/followed_artists_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistProfileView extends ConsumerStatefulWidget {
  const ArtistProfileView({super.key, required this.artistId});

  final String artistId;

  @override
  ConsumerState<ArtistProfileView> createState() => _ArtistProfileViewState();
}

class _ArtistProfileViewState extends ConsumerState<ArtistProfileView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(
      artistPublicProfileProvider(widget.artistId),
    );
    final followedIds = ref.watch(followedArtistIdsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ApiAsyncBody(
        value: profileAsync,
        onRetry: () =>
            ref.invalidate(artistPublicProfileProvider(widget.artistId)),
        errorMessage: '작가 프로필을 불러오지 못했습니다.',
        builder: (profile) {
          if (profile == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Column(
                children: [
                  ArtistProfileSubHeader(
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '작가 프로필을 찾을 수 없습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('돌아가기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final isFollowing = followedIds.contains(profile.userId);
          final isSelf =
              currentUserId != null && currentUserId == profile.userId;
          final reviewStats = ref
              .watch(artistReviewStatsProvider(profile.userId))
              .valueOrNull;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                ArtistProfileSubHeader(
                  onBack: () => Navigator.of(context).pop(),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 8),
                ArtistProfileInfoSection(
                  profile: profile,
                  isFollowing: isFollowing,
                  notificationsEnabled: _notificationsEnabled,
                  reviewStats: reviewStats,
                  onFollowTap: isSelf
                      ? null
                      : () => toggleFollowedArtist(
                          ref: ref,
                          context: context,
                          followingUserId: profile.userId,
                          artistProfileId: profile.id,
                        ),
                  onFollowersTap: () => FollowersScreen.open(
                    context,
                    userId: profile.userId,
                    title: '${profile.displayName}의 팔로워',
                  ),
                  onNotificationTap: () => setState(
                    () => _notificationsEnabled = !_notificationsEnabled,
                  ),
                ),
                _ProfileTabBar(controller: _tabController),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ArtistNoticeTab(profile: profile),
                      ArtistProfileTabContent(profile: profile),
                      ArtistPortfolioTab(imageUrls: profile.portfolioImageUrls),
                      ArtistReviewsTab(artistUserId: profile.userId),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ArtPortBottomNav(
              onTabSelected: (index) {
                ref.read(currentTabProvider.notifier).selectTab(index);
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.borderLight,
        tabs: const [
          Tab(text: '공지사항'),
          Tab(text: '프로필'),
          Tab(text: '포트폴리오'),
          Tab(text: '리뷰'),
        ],
      ),
    );
  }
}

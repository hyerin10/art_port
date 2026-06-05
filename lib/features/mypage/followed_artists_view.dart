import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/commission/commission_detail_screen.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/mypage/models/followed_artist.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/widgets/followed_artists_header.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:art_port/providers/followed_artists_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 팔로우한 작가 목록 화면
class FollowedArtistsView extends ConsumerWidget {
  const FollowedArtistsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(followedArtistsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          FollowedArtistsHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: artists.isEmpty
                ? const _FollowedArtistsEmptyState()
                : _FollowedArtistsList(artists: artists),
          ),
        ],
      ),
      bottomNavigationBar: ArtPortBottomNav(
        onTabSelected: (index) {
          ref.read(currentTabProvider.notifier).selectTab(index);
          ref.read(showMyPageProvider.notifier).close();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _FollowedArtistsEmptyState extends StatelessWidget {
  const _FollowedArtistsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No followed artists yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Discover talented artists and follow them\nto see their latest work',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List ─────────────────────────────────────────────────────────────────────

class _FollowedArtistsList extends StatelessWidget {
  const _FollowedArtistsList({required this.artists});

  final List<FollowedArtistProfile> artists;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: artists.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _FollowedArtistCard(artist: artists[index]);
      },
    );
  }
}

class _FollowedArtistCard extends ConsumerWidget {
  const _FollowedArtistCard({required this.artist});

  final FollowedArtistProfile artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArtistInfoRow(artist: artist),
            if (artist.recentWorks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Recent Works',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              _RecentWorksRow(works: artist.recentWorks),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArtistInfoRow extends ConsumerWidget {
  const _ArtistInfoRow({required this.artist});

  final FollowedArtistProfile artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openArtistCommission(context, artist),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.chipBackground,
            backgroundImage: NetworkImage(artist.avatarUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _openArtistCommission(context, artist),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  artist.specialtiesLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _FollowingButton(artistId: artist.id),
      ],
    );
  }

  void _openArtistCommission(
    BuildContext context,
    FollowedArtistProfile artist,
  ) {
    if (artist.recentWorks.isEmpty) return;
    CommissionDetailScreen.open(
      context,
      commissionId: artist.recentWorks.first.commissionId,
    );
  }
}

class _FollowingButton extends ConsumerWidget {
  const _FollowingButton({required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () =>
            ref.read(followedArtistIdsProvider.notifier).toggle(artistId),
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            '팔로잉',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentWorksRow extends StatelessWidget {
  const _RecentWorksRow({required this.works});

  final List<ArtistRecentWork> works;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < works.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _RecentWorkThumbnail(work: works[i]),
          ),
        ],
      ],
    );
  }
}

class _RecentWorkThumbnail extends StatelessWidget {
  const _RecentWorkThumbnail({required this.work});

  final ArtistRecentWork work;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => CommissionDetailScreen.open(
            context,
            commissionId: work.commissionId,
          ),
          borderRadius: BorderRadius.circular(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              work.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: AppColors.primarySoft,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

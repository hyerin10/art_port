import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/commission/commission_detail_screen.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/mypage/models/liked_commission_item.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/widgets/liked_works_header.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 찜한 작품 목록 화면
class LikedWorksView extends ConsumerWidget {
  const LikedWorksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedItems = ref.watch(likedCommissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          LikedWorksHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: likedItems.isEmpty
                ? _LikedWorksEmptyState(
                    onExploreTap: () => _navigateToExplore(context, ref),
                  )
                : _LikedWorksGrid(items: likedItems),
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

  void _navigateToExplore(BuildContext context, WidgetRef ref) {
    ref.read(currentTabProvider.notifier).selectTab(0);
    ref.read(showMyPageProvider.notifier).close();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _LikedWorksEmptyState extends StatelessWidget {
  const _LikedWorksEmptyState({required this.onExploreTap});

  final VoidCallback onExploreTap;

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
                Icons.favorite_border_rounded,
                size: 44,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No saved artworks yet',
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
              'Discover amazing art commissions\nand save your favorites here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Material(
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(28),
              color: AppColors.primary,
              child: InkWell(
                onTap: onExploreTap,
                borderRadius: BorderRadius.circular(28),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  child: Text(
                    'Explore Artworks',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _LikedWorksGrid extends ConsumerWidget {
  const _LikedWorksGrid({required this.items});

  final List<LikedCommissionItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _LikedCommissionCard(item: items[index]);
      },
    );
  }
}

class _LikedCommissionCard extends ConsumerWidget {
  const _LikedCommissionCard({required this.item});

  final LikedCommissionItem item;

  static const int _maxVisibleTags = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CommissionDetailScreen.open(
          context,
          commissionId: item.id,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppColors.primarySoft,
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _SavedHeartBadge(
                        onTap: () => ref
                            .read(likedCommissionIdsProvider.notifier)
                            .toggle(item.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.chipBackground,
                        backgroundImage: NetworkImage(item.artistAvatarUrl),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _TagRow(tags: item.tags),
                  const SizedBox(height: 6),
                  Text(
                    item.priceLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedHeartBadge extends StatelessWidget {
  const _SavedHeartBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.favorite_rounded,
          size: 18,
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(_LikedCommissionCard._maxVisibleTags).toList();
    final extra = tags.length - visible.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final tag in visible) _TagChip(label: tag),
        if (extra > 0) _TagChip(label: '+$extra'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.1,
        ),
      ),
    );
  }
}

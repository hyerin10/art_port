import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/commission/commission_detail_screen.dart';
import 'package:art_port/features/mypage/models/liked_commission_item.dart';
import 'package:art_port/features/search/models/search_commission.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 그리드 카드 표시 데이터
class CommissionCardDisplayData {
  const CommissionCardDisplayData({
    required this.id,
    required this.imageUrl,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.title,
    required this.tags,
    required this.priceLabel,
    this.hasSlot = false,
    this.likeCountLabel,
  });

  final String id;
  final String imageUrl;
  final String artistName;
  final String artistAvatarUrl;
  final String title;
  final List<String> tags;
  final String priceLabel;
  final bool hasSlot;
  final String? likeCountLabel;

  factory CommissionCardDisplayData.fromLiked(LikedCommissionItem item) {
    return CommissionCardDisplayData(
      id: item.id,
      imageUrl: item.imageUrl,
      artistName: item.artistName,
      artistAvatarUrl: item.artistAvatarUrl,
      title: item.title,
      tags: item.tags,
      priceLabel: item.priceLabel,
    );
  }

  factory CommissionCardDisplayData.fromSearch(SearchCommissionItem item) {
    return CommissionCardDisplayData(
      id: item.id,
      imageUrl: item.imageUrl,
      artistName: item.artistName,
      artistAvatarUrl: item.artistAvatarUrl,
      title: item.title,
      tags: item.tags,
      priceLabel: item.priceLabel,
      hasSlot: item.hasSlot,
      likeCountLabel: item.likeCountLabel,
    );
  }
}

enum CommissionLikeButtonStyle { overlay, saved }

/// 검색·찜 목록 등에서 공유하는 커미션 그리드 카드
class CommissionGridCard extends ConsumerWidget {
  const CommissionGridCard({
    super.key,
    required this.data,
    this.likeButtonStyle = CommissionLikeButtonStyle.overlay,
    this.isLiked,
  });

  final CommissionCardDisplayData data;
  final CommissionLikeButtonStyle likeButtonStyle;
  final bool? isLiked;

  static const int maxVisibleTags = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = isLiked ??
        (likeButtonStyle == CommissionLikeButtonStyle.saved ||
            ref.watch(likedCommissionIdsProvider).contains(data.id));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CommissionDetailScreen.open(
          context,
          commissionId: data.id,
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
                      data.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: AppColors.primarySoft,
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    if (data.hasSlot)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.onlineStatus,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '슬롯 있음',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CommissionLikeButton(
                        isLiked: liked,
                        style: likeButtonStyle,
                        onTap: () => ref
                            .read(likedCommissionIdsProvider.notifier)
                            .toggle(data.id),
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
                        backgroundImage: NetworkImage(data.artistAvatarUrl),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.artistName,
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
                    data.title,
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
                  CommissionTagRow(tags: data.tags),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        data.priceLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (data.likeCountLabel != null) ...[
                        const Spacer(),
                        Text(
                          data.likeCountLabel!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
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

class CommissionTagRow extends StatelessWidget {
  const CommissionTagRow({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(CommissionGridCard.maxVisibleTags).toList();
    final extra = tags.length - visible.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final tag in visible) _CommissionTagChip(label: tag),
        if (extra > 0) _CommissionTagChip(label: '+$extra'),
      ],
    );
  }
}

class _CommissionTagChip extends StatelessWidget {
  const _CommissionTagChip({required this.label});

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

class CommissionLikeButton extends StatelessWidget {
  const CommissionLikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.style = CommissionLikeButtonStyle.overlay,
  });

  final bool isLiked;
  final VoidCallback onTap;
  final CommissionLikeButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: switch (style) {
            CommissionLikeButtonStyle.overlay =>
              Colors.black.withValues(alpha: 0.35),
            CommissionLikeButtonStyle.saved => Colors.white,
          },
          shape: BoxShape.circle,
          boxShadow: style == CommissionLikeButtonStyle.saved
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          switch (style) {
            CommissionLikeButtonStyle.overlay => isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            CommissionLikeButtonStyle.saved => Icons.favorite_rounded,
          },
          size: 18,
          color: switch (style) {
            CommissionLikeButtonStyle.overlay =>
              isLiked ? AppColors.primary : Colors.white,
            CommissionLikeButtonStyle.saved => const Color(0xFFEF4444),
          },
        ),
      ),
    );
  }
}

import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:art_port/features/review/models/review_list_item.dart';
import 'package:art_port/features/review/widgets/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistReviewsTab extends ConsumerWidget {
  const ArtistReviewsTab({super.key, required this.artistUserId});

  final String artistUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(artistReviewItemsProvider(artistUserId));

    return ApiAsyncBody<List<ReviewListItem>>(
      value: reviewsAsync,
      onRetry: () => ref.invalidate(artistReviewItemsProvider(artistUserId)),
      errorMessage: '리뷰를 불러오지 못했습니다.',
      builder: (items) {
        if (items.isEmpty) {
          return const EmptyStateView(
            icon: Icons.star_outline_rounded,
            title: '아직 리뷰가 없습니다',
            subtitle: '이 작가의 첫 리뷰를 기다려 주세요',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return ReviewCard(item: items[index]);
          },
        );
      },
    );
  }
}

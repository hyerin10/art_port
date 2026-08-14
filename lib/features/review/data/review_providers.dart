import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:art_port/features/review/data/dto/review_dto.dart';
import 'package:art_port/features/review/data/review_repository.dart';
import 'package:art_port/features/review/models/review_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewStats {
  const ReviewStats({required this.count, required this.averageRating});

  final int count;
  final double averageRating;

  factory ReviewStats.fromReviews(List<ReviewDto> reviews) {
    if (reviews.isEmpty) {
      return const ReviewStats(count: 0, averageRating: 0);
    }
    final sum = reviews.fold<double>(0, (total, review) => total + review.rating);
    return ReviewStats(
      count: reviews.length,
      averageRating: sum / reviews.length,
    );
  }

  String get averageLabel => averageRating.toStringAsFixed(2);

  String get countLabel => '($count)';

  String get detailLabel =>
      '${averageRating.toStringAsFixed(1)} ($count 리뷰)';
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(apiClientProvider));
});

final myReviewsProvider = FutureProvider<List<ReviewDto>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  return ref.watch(reviewRepositoryProvider).getMy(userId);
});

final artistReviewsProvider =
    FutureProvider.family<List<ReviewDto>, String>((ref, artistUserId) async {
  if (artistUserId.isEmpty) return const [];
  return ref.watch(reviewRepositoryProvider).getByArtist(artistUserId);
});

final reviewForOrderProvider = Provider.family<ReviewDto?, String>((ref, orderId) {
  final reviews = ref.watch(myReviewsProvider).valueOrNull ?? const [];
  for (final review in reviews) {
    if (review.orderId == orderId) return review;
  }
  return null;
});

final myReviewItemsProvider = FutureProvider<List<ReviewListItem>>((ref) async {
  final reviews = await ref.watch(myReviewsProvider.future);
  return _toItems(ref, reviews, counterpartIsArtist: true);
});

final receivedReviewItemsProvider = FutureProvider<List<ReviewListItem>>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  final reviews = await ref.watch(artistReviewsProvider(userId).future);
  return _toItems(ref, reviews, counterpartIsArtist: false);
});

final artistReviewItemsProvider =
    FutureProvider.family<List<ReviewListItem>, String>((ref, artistUserId) async {
  final reviews = await ref.watch(artistReviewsProvider(artistUserId).future);
  return _toItems(ref, reviews, counterpartIsArtist: false);
});

/// 실제 리뷰 목록 기준 평점·개수. 프로필의 캐시된 reviewCount 대신 사용한다.
final artistReviewStatsProvider =
    Provider.family<AsyncValue<ReviewStats>, String>((ref, artistUserId) {
  return ref.watch(artistReviewsProvider(artistUserId)).whenData(
        ReviewStats.fromReviews,
      );
});

Future<List<ReviewListItem>> _toItems(
  Ref ref,
  List<ReviewDto> reviews, {
  required bool counterpartIsArtist,
}) async {
  if (reviews.isEmpty) return const [];

  CommissionCatalog? catalog = ref.watch(commissionCatalogProvider).valueOrNull;
  if (catalog == null) {
    try {
      catalog = await ref.watch(commissionCatalogProvider.future);
    } catch (_) {}
  }

  final lookups = await ParticipantLookups.resolve(
    ref,
    userIds: [
      for (final review in reviews) ...[review.artistId, review.clientId],
    ],
  );

  final items = [
    for (final review in reviews)
      ReviewListItem(
        review: review,
        title: catalog?.typeById(review.commissionTypeId)?.name ?? '커미션',
        counterpartName: lookups.nameFor(
          counterpartIsArtist ? review.artistId : review.clientId,
        ),
        counterpartAvatarUrl: lookups.avatarFor(
          counterpartIsArtist ? review.artistId : review.clientId,
        ),
      ),
  ]..sort((a, b) => b.review.createdAt.compareTo(a.review.createdAt));
  return items;
}

void invalidateReviewQueries(dynamic ref, {String? artistUserId}) {
  ref.invalidate(myReviewsProvider);
  ref.invalidate(myReviewItemsProvider);
  ref.invalidate(receivedReviewItemsProvider);
  if (artistUserId != null && artistUserId.isNotEmpty) {
    ref.invalidate(artistReviewsProvider(artistUserId));
    ref.invalidate(artistReviewItemsProvider(artistUserId));
  }
  ref.invalidate(commissionCatalogProvider);
}

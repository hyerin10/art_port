import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/mypage/models/liked_commission_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역 찜(좋아요) 커미션 ID 집합
final likedCommissionIdsProvider =
    NotifierProvider<LikedCommissionIdsNotifier, Set<String>>(
  LikedCommissionIdsNotifier.new,
);

class LikedCommissionIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  bool isLiked(String id) => state.contains(id);
}

/// 찜한 작품 목록 (카드 표시용)
final likedCommissionsProvider = Provider<List<LikedCommissionItem>>((ref) {
  final likedIds = ref.watch(likedCommissionIdsProvider);
  final catalog = ref.watch(commissionCatalogProvider).valueOrNull;
  if (catalog == null) return const [];

  return [
    for (final id in likedIds)
      if (catalog.detailFor(id) case final detail?)
        LikedCommissionItem.fromDetail(detail),
  ];
});

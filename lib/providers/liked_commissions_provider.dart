import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/mypage/models/liked_commission_item.dart';
import 'package:art_port/features/search/models/search_commission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역 찜(좋아요) 커미션 ID 집합
final likedCommissionIdsProvider =
    NotifierProvider<LikedCommissionIdsNotifier, Set<String>>(
  LikedCommissionIdsNotifier.new,
);

class LikedCommissionIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialLikedIds();

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

Set<String> _initialLikedIds() {
  final ids = <String>{};
  for (final item in SearchDummyData.commissions) {
    if (item.isLiked) ids.add(item.id);
  }
  for (final sample in ExploreDummyData.gallerySamples) {
    if (sample.isLiked) ids.add(sample.id);
  }
  return ids;
}

/// 찜한 작품 목록 (카드 표시용)
final likedCommissionsProvider = Provider<List<LikedCommissionItem>>((ref) {
  final likedIds = ref.watch(likedCommissionIdsProvider);
  final items = <LikedCommissionItem>[];

  for (final id in likedIds) {
    final detail = CommissionDetailData.forId(id);
    if (detail != null) {
      items.add(LikedCommissionItem.fromDetail(detail));
    }
  }

  return items;
});

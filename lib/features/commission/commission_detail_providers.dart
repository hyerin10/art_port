import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commissionDetailProvider =
    Provider.family<CommissionDetail?, String>((ref, commissionId) {
  return CommissionDetailData.forId(commissionId);
});

/// 커미션 상세 좋아요 상태 (더미)
class CommissionLikedIdsNotifier extends Notifier<Set<String>> {
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

final commissionLikedIdsProvider =
    NotifierProvider<CommissionLikedIdsNotifier, Set<String>>(
  CommissionLikedIdsNotifier.new,
);

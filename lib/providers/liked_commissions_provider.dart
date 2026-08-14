import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/auth/widgets/login_required_dialog.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/models/liked_commission_item.dart';
import 'package:art_port/features/wishlist/data/wishlist_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(apiClientProvider));
});

/// 앱 전역 찜 커미션 ID 집합
final likedCommissionIdsProvider =
    NotifierProvider<LikedCommissionIdsNotifier, Set<String>>(
      LikedCommissionIdsNotifier.new,
    );

class LikedCommissionIdsNotifier extends Notifier<Set<String>> {
  var _loadId = 0;

  @override
  Set<String> build() {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return {};
    _refresh(userId);
    return {};
  }

  Future<void> _refresh(String userId) async {
    final loadId = ++_loadId;
    try {
      final items = await ref.read(wishlistRepositoryProvider).getAll(userId);
      if (loadId != _loadId) return;
      if (ref.read(currentUserIdProvider) != userId) return;
      state = {for (final item in items) item.commissionTypeId};
    } catch (_) {}
  }

  Future<void> toggle(String commissionTypeId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const ApiException(
        code: 'UNAUTHORIZED',
        status: 401,
        message: '로그인이 필요합니다.',
      );
    }

    _loadId++;
    final previous = state;
    final optimistic = Set<String>.from(previous);
    if (optimistic.contains(commissionTypeId)) {
      optimistic.remove(commissionTypeId);
    } else {
      optimistic.add(commissionTypeId);
    }
    state = optimistic;

    try {
      final result = await ref
          .read(wishlistRepositoryProvider)
          .toggle(userId: userId, commissionTypeId: commissionTypeId);
      final next = Set<String>.from(state);
      if (result.wishlisted) {
        next.add(commissionTypeId);
      } else {
        next.remove(commissionTypeId);
      }
      state = next;
    } catch (_) {
      state = previous;
      rethrow;
    }
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

Future<void> toggleLikedCommission({
  required WidgetRef ref,
  required BuildContext context,
  required String commissionTypeId,
}) async {
  if (!ref.read(isLoggedInProvider)) {
    await showLoginRequiredDialog(context);
    return;
  }

  try {
    await ref
        .read(likedCommissionIdsProvider.notifier)
        .toggle(commissionTypeId);
  } on ApiException catch (e) {
    if (!context.mounted) return;
    AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
  } catch (_) {
    if (!context.mounted) return;
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '찜 처리에 실패했습니다. 다시 시도해 주세요.',
    );
  }
}

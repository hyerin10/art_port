import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/artist_profile/artist_profile_providers.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/auth/widgets/login_required_dialog.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/follow/data/follow_repository.dart';
import 'package:art_port/features/follow/models/follower_list_item.dart';
import 'package:art_port/features/mypage/models/followed_artist.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository(ref.watch(apiClientProvider));
});

/// 팔로우한 작가의 **유저 ID** 집합 (`followingId`)
final followedArtistIdsProvider =
    NotifierProvider<FollowedArtistIdsNotifier, Set<String>>(
      FollowedArtistIdsNotifier.new,
    );

class FollowedArtistIdsNotifier extends Notifier<Set<String>> {
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
      final items = await ref
          .read(followRepositoryProvider)
          .getFollowings(userId);
      if (loadId != _loadId) return;
      if (ref.read(currentUserIdProvider) != userId) return;
      state = {for (final item in items) item.followingId};
    } catch (_) {}
  }

  Future<void> toggle(String followingUserId) async {
    final followerId = ref.read(currentUserIdProvider);
    if (followerId == null) {
      throw const ApiException(
        code: 'UNAUTHORIZED',
        status: 401,
        message: '로그인이 필요합니다.',
      );
    }
    if (followerId == followingUserId) {
      throw const ApiException(
        code: 'BAD_REQUEST',
        status: 400,
        message: '자기 자신은 팔로우할 수 없습니다.',
      );
    }

    _loadId++;
    final previous = state;
    final isFollowing = previous.contains(followingUserId);
    final optimistic = Set<String>.from(previous);
    if (isFollowing) {
      optimistic.remove(followingUserId);
    } else {
      optimistic.add(followingUserId);
    }
    state = optimistic;

    try {
      final repo = ref.read(followRepositoryProvider);
      if (isFollowing) {
        await repo.unfollow(followingUserId);
      } else {
        await repo.follow(followingUserId);
      }
      ref.invalidate(followersProvider(followingUserId));
      ref.invalidate(followersProvider(followerId));
    } on ApiException catch (e) {
      if (e.code == 'DUPLICATE_RESOURCE') {
        state = {...previous, followingUserId};
        return;
      }
      if (e.code == 'FOLLOW_NOT_FOUND') {
        final next = Set<String>.from(previous)..remove(followingUserId);
        state = next;
        return;
      }
      state = previous;
      rethrow;
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  bool isFollowing(String followingUserId) => state.contains(followingUserId);
}

/// 팔로우한 작가 목록 (카드 표시용)
final followedArtistsProvider = Provider<List<FollowedArtistProfile>>((ref) {
  final followedIds = ref.watch(followedArtistIdsProvider);
  final catalog = ref.watch(commissionCatalogProvider).valueOrNull;
  if (catalog == null) return const [];

  return [
    for (final userId in followedIds) ?catalog.followedProfileForUserId(userId),
  ];
});

final followersProvider =
    FutureProvider.family<List<FollowerListItem>, String>((ref, userId) async {
  if (userId.isEmpty) return const [];

  final follows = await ref.watch(followRepositoryProvider).getFollowers(userId);
  final lookups = await ParticipantLookups.resolve(
    ref,
    userIds: [for (final item in follows) item.followerId],
  );

  return [
    for (final item in follows)
      FollowerListItem(
        userId: item.followerId,
        name: lookups.nameFor(item.followerId),
        avatarUrl: lookups.avatarFor(item.followerId),
        artistProfileId: lookups.artistProfileIdFor(item.followerId),
      ),
  ];
});

Future<void> toggleFollowedArtist({
  required WidgetRef ref,
  required BuildContext context,
  required String followingUserId,
  String? artistProfileId,
}) async {
  if (!ref.read(isLoggedInProvider)) {
    await showLoginRequiredDialog(context);
    return;
  }

  try {
    await ref.read(followedArtistIdsProvider.notifier).toggle(followingUserId);
    if (artistProfileId != null) {
      ref.invalidate(artistPublicProfileProvider(artistProfileId));
    }
  } on ApiException catch (e) {
    if (!context.mounted) return;
    AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
  } catch (_) {
    if (!context.mounted) return;
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '팔로우 처리에 실패했습니다. 다시 시도해 주세요.',
    );
  }
}

import 'package:art_port/features/mypage/models/followed_artist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역 팔로우한 작가 ID 집합
final followedArtistIdsProvider =
    NotifierProvider<FollowedArtistIdsNotifier, Set<String>>(
  FollowedArtistIdsNotifier.new,
);

class FollowedArtistIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => _initialFollowedIds();

  void toggle(String artistId) {
    final next = Set<String>.from(state);
    if (next.contains(artistId)) {
      next.remove(artistId);
    } else {
      next.add(artistId);
    }
    state = next;
  }

  void toggleByName(String artistName) {
    toggle(ArtistCatalog.idForName(artistName));
  }

  bool isFollowing(String artistId) => state.contains(artistId);

  bool isFollowingByName(String artistName) =>
      state.contains(ArtistCatalog.idForName(artistName));
}

Set<String> _initialFollowedIds() {
  return {
    ArtistCatalog.idForName('초코쌤'),
    ArtistCatalog.idForName('미유_Miyu'),
  };
}

/// 팔로우한 작가 목록 (카드 표시용)
final followedArtistsProvider = Provider<List<FollowedArtistProfile>>((ref) {
  final followedIds = ref.watch(followedArtistIdsProvider);
  final artists = <FollowedArtistProfile>[];

  for (final id in followedIds) {
    final profile = ArtistCatalog.forId(id);
    if (profile != null) {
      artists.add(profile);
    }
  }

  return artists;
});

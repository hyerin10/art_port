import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/artist_profile/artist_profile_providers.dart';
import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/mypage/data/client_profile_repository.dart';
import 'package:art_port/features/mypage/data/dto/client_profile_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientProfileRepositoryProvider = Provider<ClientProfileRepository>((ref) {
  return ClientProfileRepository(ref.watch(apiClientProvider));
});

final myArtistProfileProvider = FutureProvider<ArtistProfileDto?>((ref) async {
  final profileId = ref.watch(currentArtistProfileIdProvider);
  if (profileId == null) return null;
  return ref.watch(artistProfileRepositoryProvider).getById(profileId);
});

final myClientProfileProvider = FutureProvider<ClientProfileDto?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  try {
    return await ref.watch(clientProfileRepositoryProvider).getMe();
  } on ApiException catch (e) {
    if (e.status == 404 || e.code == 'CLIENT_PROFILE_NOT_FOUND') {
      return null;
    }
    rethrow;
  }
});

void invalidateArtistWorkspaceQueries(dynamic ref, {String? artistProfileId}) {
  ref.invalidate(commissionCatalogProvider);
  ref.invalidate(myArtistProfileProvider);
  if (artistProfileId != null && artistProfileId.isNotEmpty) {
    ref.invalidate(artistPublicProfileProvider(artistProfileId));
  }
}

import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/artist_profile/data/artist_profile_repository.dart';
import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';
import 'package:art_port/features/commission/data/commission_catalog.dart';
import 'package:art_port/features/commission/data/commission_catalog_mapper.dart';
import 'package:art_port/features/commission/data/commission_type_repository.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final artistProfileRepositoryProvider = Provider<ArtistProfileRepository>((
  ref,
) {
  return ArtistProfileRepository(ref.watch(apiClientProvider));
});

final commissionTypeRepositoryProvider = Provider<CommissionTypeRepository>((
  ref,
) {
  return CommissionTypeRepository(ref.watch(apiClientProvider));
});

final commissionCatalogProvider = FutureProvider<CommissionCatalog>((
  ref,
) async {
  final artistRepo = ref.watch(artistProfileRepositoryProvider);
  final commissionRepo = ref.watch(commissionTypeRepositoryProvider);
  final (artists, types) = await (
    artistRepo.getAll(),
    commissionRepo.getAll(),
  ).wait;
  return CommissionCatalog(artists: artists, types: types);
});

final commissionDetailProvider =
    FutureProvider.family<CommissionDetail?, String>((ref, commissionId) async {
      final cached = ref
          .watch(commissionCatalogProvider)
          .valueOrNull
          ?.detailFor(commissionId);
      if (cached != null) return cached;

      try {
        final type = await ref
            .watch(commissionTypeRepositoryProvider)
            .getById(commissionId);
        final catalogArtist = ref
            .watch(commissionCatalogProvider)
            .valueOrNull
            ?.artistsById[type.artistProfileId];
        final artist =
            catalogArtist ?? await _artistOrNull(ref, type.artistProfileId);
        return CommissionCatalogMapper.toDetail(type, artist);
      } on ApiException catch (e) {
        if (e.status == 404 || e.code == 'COMMISSION_TYPE_NOT_FOUND') {
          return null;
        }
        rethrow;
      }
    });

Future<ArtistProfileDto?> _artistOrNull(Ref ref, String artistProfileId) async {
  try {
    return await ref
        .watch(artistProfileRepositoryProvider)
        .getById(artistProfileId);
  } catch (_) {
    return null;
  }
}

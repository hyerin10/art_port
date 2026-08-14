import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/artist_profile/models/artist_public_profile.dart';
import 'package:art_port/features/commission/data/commission_catalog_mapper.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final artistPublicProfileProvider =
    FutureProvider.family<ArtistPublicProfile?, String>((ref, artistId) async {
      try {
        final bundle = await ref
            .watch(artistProfileRepositoryProvider)
            .getPublicBundle(artistId);
        final types = await ref
            .watch(commissionTypeRepositoryProvider)
            .getByArtistProfileId(artistId);

        return CommissionCatalogMapper.toPublicProfile(
          profile: bundle.profile,
          portfolio: bundle.portfolio,
          notices: bundle.notices,
          socialLinks: bundle.socialLinks,
          primaryCommissionId: types.isEmpty ? null : types.first.id,
        );
      } on ApiException catch (e) {
        if (e.status == 404 || e.code == 'ARTIST_PROFILE_NOT_FOUND') {
          return null;
        }
        rethrow;
      }
    });

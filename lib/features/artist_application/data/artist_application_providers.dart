import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/artist_application/data/artist_application_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final artistApplicationRepositoryProvider =
    Provider<ArtistApplicationRepository>((ref) {
  return ArtistApplicationRepository(ref.watch(apiClientProvider));
});

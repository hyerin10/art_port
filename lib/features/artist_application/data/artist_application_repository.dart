import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/artist_application/data/dto/artist_application_dto.dart';

class ArtistApplicationRepository {
  ArtistApplicationRepository(this._client);

  final ApiClient _client;

  Future<ArtistApplicationDto> getMyApplication(String userId) async {
    final json = await _client.get(
      '/artist-applications/my',
      queryParameters: {'userId': userId},
    );
    return ArtistApplicationDto.fromJson(json);
  }
}

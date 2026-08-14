import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/mypage/data/dto/client_profile_dto.dart';

class ClientProfileRepository {
  ClientProfileRepository(this._client);

  final ApiClient _client;

  Future<ClientProfileDto> get(String userId) async {
    final json = await _client.get('/users/$userId/client-profile');
    return ClientProfileDto.fromJson(json);
  }

  Future<ClientProfileDto> upsert({
    required String userId,
    required String avatarUrl,
  }) async {
    final json = await _client.patch(
      '/users/$userId/client-profile',
      body: {'avatarUrl': avatarUrl},
    );
    return ClientProfileDto.fromJson(json);
  }
}

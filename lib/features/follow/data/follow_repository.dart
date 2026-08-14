import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/follow/data/dto/follow_dto.dart';

class FollowRepository {
  FollowRepository(this._client);

  final ApiClient _client;

  Future<List<FollowDto>> getFollowings(String userId) async {
    final json = await _client.getList('/users/$userId/followings');
    return json.map(FollowDto.fromJson).toList();
  }

  Future<void> follow({
    required String followerId,
    required String followingId,
  }) async {
    await _client.post(
      '/follows',
      queryParameters: {'followerId': followerId},
      body: {'followingId': followingId},
    );
  }

  Future<void> unfollow({
    required String followerId,
    required String followingId,
  }) async {
    await _client.delete(
      '/follows/$followingId',
      queryParameters: {'followerId': followerId},
    );
  }
}

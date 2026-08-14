import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/review/data/dto/review_dto.dart';

class ReviewRepository {
  ReviewRepository(this._client);

  final ApiClient _client;

  Future<List<ReviewDto>> getByArtist(String artistUserId) async {
    final json = await _client.getList('/reviews/artist/$artistUserId');
    return json.map(ReviewDto.fromJson).toList();
  }

  Future<List<ReviewDto>> getMy(String clientId) async {
    final json = await _client.getList(
      '/reviews/my',
      queryParameters: {'clientId': clientId},
    );
    return json.map(ReviewDto.fromJson).toList();
  }

  Future<ReviewDto> create({
    required String orderId,
    required String clientId,
    required double rating,
    String? content,
  }) async {
    final json = await _client.post(
      '/reviews',
      queryParameters: {'orderId': orderId, 'clientId': clientId},
      body: {
        'rating': rating,
        'content': ?content,
      },
    );
    return ReviewDto.fromJson(json);
  }

  Future<ReviewDto> update({
    required String reviewId,
    required String clientId,
    double? rating,
    String? content,
  }) async {
    final json = await _client.patch(
      '/reviews/$reviewId',
      queryParameters: {'clientId': clientId},
      body: {
        'rating': ?rating,
        'content': ?content,
      },
    );
    return ReviewDto.fromJson(json);
  }

  Future<void> delete({
    required String reviewId,
    required String clientId,
  }) async {
    await _client.delete(
      '/reviews/$reviewId',
      queryParameters: {'clientId': clientId},
    );
  }
}

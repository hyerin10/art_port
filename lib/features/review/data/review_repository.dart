import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/review/data/dto/review_dto.dart';

class ReviewRepository {
  ReviewRepository(this._client);

  final ApiClient _client;

  Future<List<ReviewDto>> getByArtist(String artistUserId) async {
    final json = await _client.getList('/reviews/artist/$artistUserId');
    return json.map(ReviewDto.fromJson).toList();
  }

  Future<List<ReviewDto>> getMy() async {
    final json = await _client.getList('/reviews/my');
    return json.map(ReviewDto.fromJson).toList();
  }

  Future<ReviewDto> create({
    required String orderId,
    required double rating,
    String? content,
  }) async {
    final json = await _client.post(
      '/reviews',
      queryParameters: {'orderId': orderId},
      body: {
        'rating': rating,
        'content': ?content,
      },
    );
    return ReviewDto.fromJson(json);
  }

  Future<ReviewDto> update({
    required String reviewId,
    double? rating,
    String? content,
  }) async {
    final json = await _client.patch(
      '/reviews/$reviewId',
      body: {
        'rating': ?rating,
        'content': ?content,
      },
    );
    return ReviewDto.fromJson(json);
  }

  Future<void> delete(String reviewId) async {
    await _client.delete('/reviews/$reviewId');
  }
}

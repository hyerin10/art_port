import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/wishlist/data/dto/wishlist_dto.dart';

class WishlistRepository {
  WishlistRepository(this._client);

  final ApiClient _client;

  Future<List<WishlistDto>> getAll(String userId) async {
    final json = await _client.getList('/users/$userId/wishlists');
    return json.map(WishlistDto.fromJson).toList();
  }

  Future<ToggleWishlistResult> toggle({
    required String userId,
    required String commissionTypeId,
  }) async {
    final json = await _client.post(
      '/wishlists/toggle',
      queryParameters: {'userId': userId},
      body: {'commissionTypeId': commissionTypeId},
    );
    return ToggleWishlistResult.fromJson(json);
  }
}

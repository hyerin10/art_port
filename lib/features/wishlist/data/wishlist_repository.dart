import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/wishlist/data/dto/wishlist_dto.dart';

class WishlistRepository {
  WishlistRepository(this._client);

  final ApiClient _client;

  Future<List<WishlistDto>> getMine() async {
    final json = await _client.getList('/users/me/wishlists');
    return json.map(WishlistDto.fromJson).toList();
  }

  Future<ToggleWishlistResult> toggle({
    required String commissionTypeId,
  }) async {
    final json = await _client.post(
      '/wishlists/toggle',
      body: {'commissionTypeId': commissionTypeId},
    );
    return ToggleWishlistResult.fromJson(json);
  }
}

import 'package:art_port/core/network/json_parsers.dart';

class WishlistDto {
  const WishlistDto({
    required this.id,
    required this.commissionTypeId,
    required this.commissionTypeName,
    required this.createdAt,
  });

  final String id;
  final String commissionTypeId;
  final String commissionTypeName;
  final DateTime createdAt;

  factory WishlistDto.fromJson(Map<String, dynamic> json) {
    return WishlistDto(
      id: JsonParsers.string(json['id']),
      commissionTypeId: JsonParsers.string(json['commissionTypeId']),
      commissionTypeName: JsonParsers.string(json['commissionTypeName']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
    );
  }
}

class ToggleWishlistResult {
  const ToggleWishlistResult({required this.wishlisted, this.wishlist});

  final bool wishlisted;
  final WishlistDto? wishlist;

  factory ToggleWishlistResult.fromJson(Map<String, dynamic> json) {
    final wishlistJson = json['wishlist'];
    return ToggleWishlistResult(
      wishlisted: JsonParsers.boolean(json['wishlisted']),
      wishlist: wishlistJson is Map<String, dynamic>
          ? WishlistDto.fromJson(wishlistJson)
          : null,
    );
  }
}

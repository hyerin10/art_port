import 'package:art_port/core/network/json_parsers.dart';

class ReviewDto {
  const ReviewDto({
    required this.id,
    required this.orderId,
    required this.commissionTypeId,
    required this.artistId,
    required this.clientId,
    required this.rating,
    this.content,
    required this.imageUrls,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderId;
  final String commissionTypeId;
  final String artistId;
  final String clientId;
  final double rating;
  final String? content;
  final List<String> imageUrls;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: JsonParsers.string(json['id']),
      orderId: JsonParsers.string(json['orderId']),
      commissionTypeId: JsonParsers.string(json['commissionTypeId']),
      artistId: JsonParsers.string(json['artistId']),
      clientId: JsonParsers.string(json['clientId']),
      rating: JsonParsers.decimal(json['rating']),
      content: JsonParsers.optionalString(json['content']),
      imageUrls: JsonParsers.stringList(json['imageUrls']),
      isPublic: JsonParsers.boolean(json['isPublic'], true),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
      updatedAt: JsonParsers.requireDateTime(json['updatedAt']),
    );
  }
}

import 'package:art_port/core/network/json_parsers.dart';

class FollowDto {
  const FollowDto({
    required this.id,
    required this.followingId,
    required this.createdAt,
  });

  final String id;
  final String followingId;
  final DateTime createdAt;

  factory FollowDto.fromJson(Map<String, dynamic> json) {
    return FollowDto(
      id: JsonParsers.string(json['id']),
      followingId: JsonParsers.string(json['followingId']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
    );
  }
}

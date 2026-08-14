import 'package:art_port/core/network/json_parsers.dart';

class FollowerDto {
  const FollowerDto({
    required this.id,
    required this.followerId,
    required this.createdAt,
  });

  final String id;
  final String followerId;
  final DateTime createdAt;

  factory FollowerDto.fromJson(Map<String, dynamic> json) {
    return FollowerDto(
      id: JsonParsers.string(json['id']),
      followerId: JsonParsers.string(json['followerId']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
    );
  }
}

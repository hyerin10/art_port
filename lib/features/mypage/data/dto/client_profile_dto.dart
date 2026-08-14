import 'package:art_port/core/network/json_parsers.dart';

class ClientProfileDto {
  const ClientProfileDto({
    required this.id,
    required this.userId,
    this.avatarUrl,
  });

  final String id;
  final String userId;
  final String? avatarUrl;

  factory ClientProfileDto.fromJson(Map<String, dynamic> json) {
    return ClientProfileDto(
      id: JsonParsers.string(json['id']),
      userId: JsonParsers.string(json['userId']),
      avatarUrl: JsonParsers.optionalString(json['avatarUrl']),
    );
  }
}

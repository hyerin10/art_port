import 'package:art_port/core/network/json_parsers.dart';

class ChatRoomDto {
  const ChatRoomDto({
    required this.id,
    required this.clientId,
    required this.artistId,
    this.lastMessagePreview,
    required this.unreadCount,
    this.lastMessageAt,
  });

  final String id;
  final String clientId;
  final String artistId;
  final String? lastMessagePreview;
  final int unreadCount;
  final DateTime? lastMessageAt;

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) {
    return ChatRoomDto(
      id: JsonParsers.string(json['id']),
      clientId: JsonParsers.string(json['clientId']),
      artistId: JsonParsers.string(json['artistId']),
      lastMessagePreview: JsonParsers.optionalString(json['lastMessagePreview']),
      unreadCount: JsonParsers.integer(json['unreadCount']),
      lastMessageAt: JsonParsers.dateTime(json['lastMessageAt']),
    );
  }

  String counterpartId(String currentUserId) =>
      artistId == currentUserId ? clientId : artistId;
}

import 'package:art_port/core/network/json_parsers.dart';
import 'package:art_port/features/chat/models/chat_message.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.type,
    this.content,
    this.attachmentUrl,
    this.attachmentName,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String chatRoomId;
  final String senderId;
  final String type;
  final String? content;
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: JsonParsers.string(json['id']),
      chatRoomId: JsonParsers.string(json['chatRoomId']),
      senderId: JsonParsers.string(json['senderId']),
      type: JsonParsers.string(json['type'], 'text'),
      content: JsonParsers.optionalString(json['content']),
      attachmentUrl: JsonParsers.optionalString(json['attachmentUrl']),
      attachmentName: JsonParsers.optionalString(json['attachmentName']),
      isRead: JsonParsers.boolean(json['isRead']),
      readAt: JsonParsers.dateTime(json['readAt']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
    );
  }

  bool get isCardType => type == 'application_card' || type == 'payment_request';

  ChatMessage toChatMessage(String currentUserId) {
    final isMine = senderId == currentUserId;
    final messageType = switch (type) {
      'image' => ChatMessageType.image,
      'file' => ChatMessageType.file,
      _ => ChatMessageType.text,
    };

    return ChatMessage(
      id: id,
      isMine: isMine,
      type: messageType,
      timeLabel: formatChatTimeLabel(createdAt),
      text: content,
      attachmentLabel: attachmentName,
      attachmentUrl: attachmentUrl,
    );
  }
}

String formatChatTimeLabel(DateTime timestamp) {
  final local = timestamp.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

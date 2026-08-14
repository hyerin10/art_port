import 'package:art_port/core/network/json_parsers.dart';
import 'package:art_port/features/chat/data/dto/chat_message_dto.dart';
import 'package:art_port/features/chat/models/chat_message.dart';

class SupportMessageDto {
  const SupportMessageDto({
    required this.id,
    required this.inquiryId,
    this.senderId,
    required this.isAdmin,
    required this.content,
    required this.attachmentUrls,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String inquiryId;
  final String? senderId;
  final bool isAdmin;
  final String content;
  final List<String> attachmentUrls;
  final bool isRead;
  final DateTime createdAt;

  factory SupportMessageDto.fromJson(Map<String, dynamic> json) {
    return SupportMessageDto(
      id: JsonParsers.string(json['id']),
      inquiryId: JsonParsers.string(json['inquiryId']),
      senderId: JsonParsers.optionalString(json['senderId']),
      isAdmin: JsonParsers.boolean(json['isAdmin']),
      content: JsonParsers.string(json['content']),
      attachmentUrls: JsonParsers.stringList(json['attachmentUrls']),
      isRead: JsonParsers.boolean(json['isRead']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
    );
  }

  ChatMessage toChatMessage(String currentUserId) {
    return ChatMessage(
      id: id,
      isMine: senderId == currentUserId,
      type: ChatMessageType.text,
      timeLabel: formatChatTimeLabel(createdAt),
      text: content,
    );
  }
}

class SupportInquiryDto {
  const SupportInquiryDto({
    required this.id,
    required this.userId,
    required this.category,
    this.title,
    required this.status,
    this.lastMessagePreview,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  final String userId;
  final String category;
  final String? title;
  final String status;
  final String? lastMessagePreview;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SupportMessageDto> messages;

  factory SupportInquiryDto.fromJson(Map<String, dynamic> json) {
    return SupportInquiryDto(
      id: JsonParsers.string(json['id']),
      userId: JsonParsers.string(json['userId']),
      category: JsonParsers.string(json['category'], 'etc'),
      title: JsonParsers.optionalString(json['title']),
      status: JsonParsers.string(json['status'], 'open'),
      lastMessagePreview: JsonParsers.optionalString(json['lastMessagePreview']),
      lastMessageAt: JsonParsers.dateTime(json['lastMessageAt']),
      unreadCount: JsonParsers.integer(json['unreadCount']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
      updatedAt: JsonParsers.requireDateTime(json['updatedAt']),
      messages: JsonParsers.objectList(json['messages'])
          .map(SupportMessageDto.fromJson)
          .toList(),
    );
  }
}

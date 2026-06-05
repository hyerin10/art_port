import 'package:art_port/features/chat/models/chat_message.dart';

/// 채팅 이미지 메시지의 표시·저장·확대에 필요한 정보
class ChatImageAttachment {
  const ChatImageAttachment({
    required this.messageId,
    required this.fileName,
    this.localPath,
    this.networkUrl,
  });

  final String messageId;
  final String fileName;
  final String? localPath;
  final String? networkUrl;

  String get heroTag => 'chat-image-$messageId';

  bool get hasDisplaySource =>
      (localPath != null && localPath!.isNotEmpty) ||
      (networkUrl != null && networkUrl!.isNotEmpty);

  static ChatImageAttachment? fromMessage(ChatMessage message) {
    if (message.type != ChatMessageType.image) return null;
    if (message.attachmentLocalPath == null && message.attachmentUrl == null) {
      return null;
    }

    return ChatImageAttachment(
      messageId: message.id,
      fileName: message.attachmentLabel ?? 'image.jpg',
      localPath: message.attachmentLocalPath,
      networkUrl: message.attachmentUrl,
    );
  }
}

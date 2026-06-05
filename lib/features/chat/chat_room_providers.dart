import 'package:art_port/features/chat/models/chat_dummy_data.dart';
import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomDetailProvider =
    Provider.family<ChatRoomDetail?, String>((ref, roomId) {
  return ChatDummyData.roomFor(roomId);
});

final chatMessagesProvider =
    NotifierProvider.family<ChatMessagesNotifier, List<ChatMessage>, String>(
  ChatMessagesNotifier.new,
);

class ChatMessagesNotifier
    extends FamilyNotifier<List<ChatMessage>, String> {
  @override
  List<ChatMessage> build(String roomId) {
    return List<ChatMessage>.from(ChatDummyData.initialMessages(roomId));
  }

  void sendText(String raw) {
    sendBatch(text: raw, attachments: const []);
  }

  /// 텍스트 + 대기 중인 첨부 파일 일괄 전송
  void sendBatch({
    required String text,
    required List<PendingAttachment> attachments,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachments.isEmpty) return;

    final timeLabel = ChatDummyData.formatNow();
    final base = DateTime.now().millisecondsSinceEpoch;
    final outgoing = <ChatMessage>[];

    if (trimmed.isNotEmpty) {
      outgoing.add(
        ChatMessage(
          id: 'local-$base-text',
          isMine: true,
          type: ChatMessageType.text,
          timeLabel: timeLabel,
          text: trimmed,
        ),
      );
    }

    for (var i = 0; i < attachments.length; i++) {
      final att = attachments[i];
      final isImage = att.kind == PendingAttachmentKind.image;
      outgoing.add(
        ChatMessage(
          id: 'local-$base-$i',
          isMine: true,
          type: isImage ? ChatMessageType.image : ChatMessageType.file,
          timeLabel: timeLabel,
          attachmentLabel: att.fileName,
          attachmentLocalPath: att.localPath,
          attachmentSizeLabel: att.sizeLabel,
        ),
      );
    }

    state = [...state, ...outgoing];
  }
}

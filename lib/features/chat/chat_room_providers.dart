import 'package:art_port/features/chat/models/chat_dummy_data.dart';
import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:art_port/features/commission/commission_transaction_providers.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomDetailProvider =
    Provider.family<ChatRoomDetail?, String>((ref, roomId) {
  final base = ChatDummyData.roomFor(roomId);  if (base == null) return null;

  final transaction = ref.watch(commissionTransactionProvider(roomId));
  if (transaction == null) return base;

  final isArtist = ref.watch(appModeProvider);
  if (isArtist) {
    return base.copyWith(
      counterpartName: transaction.clientName,
      avatarUrl: transaction.clientAvatarUrl,
      statusLabel: transaction.status.statusBarLabel,
    );
  }

  return base.copyWith(
    counterpartName: transaction.artistName,
    avatarUrl: transaction.artistAvatarUrl,
    statusLabel: transaction.status.statusBarLabel,
  );
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

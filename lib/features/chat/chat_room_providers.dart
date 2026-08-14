import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/chat/data/chat_providers.dart';
import 'package:art_port/features/chat/data/dto/chat_message_dto.dart';
import 'package:art_port/features/chat/models/chat_dummy_data.dart';
import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:art_port/features/commission/commission_transaction_providers.dart';
import 'package:art_port/features/mypage/inquiry_providers.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:art_port/features/chat/data/chat_providers.dart';

bool isLocalSupportRoom(String roomId) =>
    roomId == 'support' || roomId.startsWith('inquiry-');

bool isApiChatRoom(String roomId) =>
    SupportInquiryConstants.inquiryIdFromRoom(roomId) == null &&
    !isLocalSupportRoom(roomId);

final chatRoomDetailProvider =
    FutureProvider.family<ChatRoomDetail?, String>((ref, roomId) async {
  final inquiryId = SupportInquiryConstants.inquiryIdFromRoom(roomId);
  if (inquiryId != null) {
    final inquiry = await ref.watch(supportInquiryDetailProvider(inquiryId).future);
    if (inquiry == null) return null;
    final isAdmin = ref.watch(isAdminProvider);
    var counterpartName = SupportInquiryConstants.centerName;
    var avatarUrl = SupportInquiryConstants.centerAvatarAsset;
    if (isAdmin) {
      counterpartName = '문의 사용자';
      try {
        final user =
            await ref.read(userRepositoryProvider).getUser(inquiry.userId);
        counterpartName = user.name;
      } catch (_) {}
      avatarUrl = fallbackAvatarUrl;
    }
    return ChatRoomDetail(
      id: roomId,
      counterpartName: counterpartName,
      avatarUrl: avatarUrl,
      isOnline: true,
      statusLabel: SupportInquiryItem.statusLabelOf(inquiry.status),
    );
  }

  if (isLocalSupportRoom(roomId)) {
    return ChatDummyData.roomFor(roomId);
  }

  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final transaction = ref.watch(commissionTransactionProvider(roomId));

  try {
    final room = await ref.watch(chatRoomRepositoryProvider).getById(
          roomId: roomId,
          userId: userId,
        );
    try {
      await ref.read(chatRoomRepositoryProvider).markRead(
            roomId: roomId,
            userId: userId,
          );
    } catch (_) {}

    final lookups = await ParticipantLookups.resolve(
      ref,
      userIds: [room.clientId, room.artistId],
    );
    final counterpartId = room.counterpartId(userId);

    return ChatRoomDetail(
      id: room.id,
      counterpartName: lookups.nameFor(counterpartId),
      avatarUrl: lookups.avatarFor(counterpartId),
      isOnline: false,
      statusLabel: transaction?.status.statusBarLabel ?? 'Status: Chat / 채팅 중',
      artistId: lookups.artistProfileIdFor(room.artistId),
    );
  } on ApiException catch (e) {
    if (e.status == 404 || e.code == 'CHAT_ROOM_NOT_FOUND') {
      return null;
    }
    rethrow;
  }
});

final chatMessagesProvider = AsyncNotifierProvider.family<
    ChatMessagesNotifier, List<ChatMessage>, String>(
  ChatMessagesNotifier.new,
);

class ChatMessagesNotifier
    extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  @override
  Future<List<ChatMessage>> build(String roomId) async {
    final inquiryId = SupportInquiryConstants.inquiryIdFromRoom(roomId);
    if (inquiryId != null) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return const [];
      final inquiry =
          await ref.watch(supportInquiryDetailProvider(inquiryId).future);
      final messages = [...?inquiry?.messages]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return [
        for (final message in messages) message.toChatMessage(userId),
      ];
    }

    if (isLocalSupportRoom(roomId)) {
      return List<ChatMessage>.from(ChatDummyData.initialMessages(roomId));
    }

    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const [];

    final messages = await ref.watch(chatMessageRepositoryProvider).getAll(
          roomId: roomId,
          userId: userId,
        );
    return [
      for (final message in messages)
        if (!message.isCardType) message.toChatMessage(userId),
    ];
  }

  Future<void> sendText(String raw) {
    return sendBatch(text: raw, attachments: const []);
  }

  /// 텍스트 + 대기 중인 첨부 파일 일괄 전송
  Future<void> sendBatch({
    required String text,
    required List<PendingAttachment> attachments,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachments.isEmpty) return;

    if (isLocalSupportRoom(arg)) {
      _appendLocal(text: trimmed, attachments: attachments);
      return;
    }

    final inquiryId = SupportInquiryConstants.inquiryIdFromRoom(arg);
    if (inquiryId != null) {
      await _sendSupportMessage(inquiryId: inquiryId, text: trimmed);
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const ApiException(
        code: 'UNAUTHORIZED',
        status: 401,
        message: '로그인이 필요합니다.',
      );
    }

    if (trimmed.isEmpty) return;

    final previous = state.valueOrNull ?? const <ChatMessage>[];
    final optimistic = ChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      isMine: true,
      type: ChatMessageType.text,
      timeLabel: formatChatTimeLabel(DateTime.now()),
      text: trimmed,
    );
    state = AsyncData([...previous, optimistic]);

    try {
      final sent = await ref.read(chatMessageRepositoryProvider).send(
            roomId: arg,
            userId: userId,
            type: 'text',
            content: trimmed,
          );
      final current = state.valueOrNull ?? previous;
      state = AsyncData([
        for (final message in current)
          if (message.id != optimistic.id) message,
        sent.toChatMessage(userId),
      ]);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> _sendSupportMessage({
    required String inquiryId,
    required String text,
  }) async {
    if (text.isEmpty) {
      throw const ApiException(
        code: 'NOT_IMPLEMENTED',
        status: 501,
        message: '파일 업로드는 아직 지원되지 않습니다.',
      );
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const ApiException(
        code: 'UNAUTHORIZED',
        status: 401,
        message: '로그인이 필요합니다.',
      );
    }

    final previous = state.valueOrNull ?? const <ChatMessage>[];
    final optimistic = ChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      isMine: true,
      type: ChatMessageType.text,
      timeLabel: formatChatTimeLabel(DateTime.now()),
      text: text,
    );
    state = AsyncData([...previous, optimistic]);

    try {
      final sent = await ref.read(supportRepositoryProvider).addMessage(
            inquiryId: inquiryId,
            userId: userId,
            content: text,
          );
      final current = state.valueOrNull ?? previous;
      state = AsyncData([
        for (final message in current)
          if (message.id != optimistic.id) message,
        sent.toChatMessage(userId),
      ]);
      invalidateSupportQueries(ref);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  void _appendLocal({
    required String text,
    required List<PendingAttachment> attachments,
  }) {
    final timeLabel = ChatDummyData.formatNow();
    final base = DateTime.now().millisecondsSinceEpoch;
    final outgoing = <ChatMessage>[];

    if (text.isNotEmpty) {
      outgoing.add(
        ChatMessage(
          id: 'local-$base-text',
          isMine: true,
          type: ChatMessageType.text,
          timeLabel: timeLabel,
          text: text,
        ),
      );
    }

    for (var i = 0; i < attachments.length; i++) {
      final att = attachments[i];
      outgoing.add(
        ChatMessage(
          id: 'local-$base-$i',
          isMine: true,
          type: att.kind == PendingAttachmentKind.image
              ? ChatMessageType.image
              : ChatMessageType.file,
          timeLabel: timeLabel,
          attachmentLabel: att.fileName,
          attachmentLocalPath: att.localPath,
          attachmentSizeLabel: att.sizeLabel,
        ),
      );
    }

    final current = state.valueOrNull ?? const <ChatMessage>[];
    state = AsyncData([...current, ...outgoing]);
  }

  Future<void> deleteMessage(String messageId) async {
    if (!isApiChatRoom(arg) || messageId.startsWith('local-')) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const ApiException(
        code: 'UNAUTHORIZED',
        status: 401,
        message: '로그인이 필요합니다.',
      );
    }

    final previous = state.valueOrNull ?? const <ChatMessage>[];
    state = AsyncData([
      for (final message in previous)
        if (message.id != messageId) message,
    ]);

    try {
      await ref.read(chatMessageRepositoryProvider).delete(
            messageId: messageId,
            userId: userId,
          );
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/artist_profile/artist_profile_screen.dart';
import 'package:art_port/features/chat/chat_pending_attachments_provider.dart';
import 'package:art_port/features/chat/chat_room_actions.dart';
import 'package:art_port/features/chat/chat_room_providers.dart';
import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/chat/models/chat_timeline.dart';
import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:art_port/features/chat/services/chat_attachment_picker.dart';
import 'package:art_port/features/chat/widgets/attachment_bottom_sheet.dart';
import 'package:art_port/features/chat/widgets/chat_input_bar.dart';
import 'package:art_port/features/chat/widgets/chat_message_bubble.dart';
import 'package:art_port/features/chat/widgets/chat_pending_attachments_bar.dart';
import 'package:art_port/features/chat/widgets/chat_room_header.dart';
import 'package:art_port/features/chat/widgets/chat_status_bar.dart';
import 'package:art_port/features/chat/widgets/commission_arrival_card.dart';
import 'package:art_port/features/chat/widgets/payment_request_card.dart';
import 'package:art_port/features/commission/commission_transaction_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/common/widgets/art_port_header.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRoomView extends ConsumerStatefulWidget {
  const ChatRoomView({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends ConsumerState<ChatRoomView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onSend() async {
    final pending = ref.read(chatPendingAttachmentsProvider(widget.roomId));
    final text = _messageController.text;
    if (text.trim().isEmpty && pending.isEmpty) return;

    if (pending.isNotEmpty && !isLocalSupportRoom(widget.roomId)) {
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '파일 업로드는 아직 지원되지 않아 텍스트만 전송됩니다.',
      );
      if (text.trim().isEmpty) return;
    }

    _messageController.clear();
    ref.read(chatPendingAttachmentsProvider(widget.roomId).notifier).clear();

    try {
      await ref.read(chatMessagesProvider(widget.roomId).notifier).sendBatch(
            text: text,
            attachments: isLocalSupportRoom(widget.roomId)
                ? pending
                : const [],
          );
      ref.invalidate(workroomChatsProvider);
      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '메시지 전송에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  Future<void> _addToPendingQueue(
    Future<List<PendingAttachment>> pickFuture,
  ) async {
    final picked = await pickFuture;
    if (!mounted || picked.isEmpty) return;

    ref
        .read(chatPendingAttachmentsProvider(widget.roomId).notifier)
        .addAll(picked);
  }

  void _onAttach() {
    AttachmentBottomSheet.show(
      context,
      onCamera: () => _addToPendingQueue(ChatAttachmentPicker.pickFromCamera()),
      onGallery: () => _addToPendingQueue(ChatAttachmentPicker.pickFromGallery()),
      onFile: () => _addToPendingQueue(ChatAttachmentPicker.pickFiles()),
    );
  }

  void _onRemovePending(int index) {
    ref
        .read(chatPendingAttachmentsProvider(widget.roomId).notifier)
        .removeAt(index);
  }

  void _openMyPageFromChatRoom() {
    ref.read(showMyPageProvider.notifier).open();
    Navigator.of(context).pop();
  }

  bool _canDeleteMessage(ChatMessage message) {
    return isApiChatRoom(widget.roomId) &&
        message.isMine &&
        !message.id.startsWith('local-');
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메시지 삭제'),
        content: const Text('이 메시지를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(chatMessagesProvider(widget.roomId).notifier)
          .deleteMessage(message.id);
      ref.invalidate(workroomChatsProvider);
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '메시지를 삭제했습니다.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '메시지 삭제에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  Future<void> _deleteRoom() async {
    final deleted = await ChatRoomActions.confirmAndDeleteRoom(
      context: context,
      ref: ref,
      roomId: widget.roomId,
      showSuccessToast: false,
    );
    if (deleted && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(chatRoomDetailProvider(widget.roomId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));
    final transaction = ref.watch(commissionTransactionProvider(widget.roomId));
    final pendingAttachments =
        ref.watch(chatPendingAttachmentsProvider(widget.roomId));

    ref.listen(chatMessagesProvider(widget.roomId), (previous, next) {
      final prevLen = previous?.valueOrNull?.length ?? 0;
      final nextLen = next.valueOrNull?.length ?? 0;
      if (nextLen > prevLen) _scrollToBottom();
    });

    ref.listen(chatRoomDetailProvider(widget.roomId), (previous, next) {
      if (previous?.hasValue != true && next.hasValue) {
        ref.invalidate(workroomChatsProvider);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      body: Column(
        children: [
          ArtPortHeader(onProfileTap: _openMyPageFromChatRoom),
          Expanded(
            child: ApiAsyncBody<ChatRoomDetail?>(
              value: roomAsync,
              onRetry: () {
                ref.invalidate(chatRoomDetailProvider(widget.roomId));
                ref.invalidate(chatMessagesProvider(widget.roomId));
              },
              errorMessage: '채팅방을 불러오지 못했습니다.',
              builder: (room) {
                if (room == null) {
                  return const Center(
                    child: Text(
                      '채팅방을 찾을 수 없습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                final messages = messagesAsync.valueOrNull ?? const <ChatMessage>[];
                final timeline = buildChatTimeline(
                  messages: messages,
                  transaction: transaction,
                );

                return Column(
                  children: [
                    ChatRoomHeader(
                      counterpartName: room.counterpartName,
                      avatarUrl: room.avatarUrl,
                      isOnline: room.isOnline,
                      onBack: () => Navigator.of(context).pop(),
                      onProfileTap: room.artistId != null
                          ? () => ArtistProfileScreen.open(
                                context,
                                artistId: room.artistId!,
                              )
                          : null,
                      onDeleteRoom:
                          isApiChatRoom(widget.roomId) ? _deleteRoom : null,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderLight,
                    ),
                    ChatStatusBar(statusLabel: room.statusLabel),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: timeline.length,
                        itemBuilder: (context, index) {
                          final item = timeline[index];
                          return switch (item.type) {
                            ChatTimelineItemType.message => ChatMessageBubble(
                                message: item.message!,
                                onDelete: _canDeleteMessage(item.message!)
                                    ? () => _deleteMessage(item.message!)
                                    : null,
                              ),
                            ChatTimelineItemType.commissionApplication =>
                              CommissionArrivalCard(
                                roomId: widget.roomId,
                                transaction: transaction!,
                              ),
                            ChatTimelineItemType.paymentRequest =>
                              PaymentRequestCard(
                                roomId: widget.roomId,
                                transaction: transaction!,
                              ),
                          };
                        },
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderLight,
                    ),
                    ChatPendingAttachmentsBar(
                      attachments: pendingAttachments,
                      onRemove: _onRemovePending,
                    ),
                    ChatInputBar(
                      controller: _messageController,
                      onAttach: _onAttach,
                      onSend: _onSend,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

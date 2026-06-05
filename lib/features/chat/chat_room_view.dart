import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_profile/artist_profile_screen.dart';
import 'package:art_port/features/chat/chat_pending_attachments_provider.dart';
import 'package:art_port/features/chat/chat_room_providers.dart';
import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:art_port/features/chat/services/chat_attachment_picker.dart';
import 'package:art_port/features/chat/widgets/attachment_bottom_sheet.dart';
import 'package:art_port/features/chat/widgets/chat_input_bar.dart';
import 'package:art_port/features/chat/widgets/chat_message_bubble.dart';
import 'package:art_port/features/chat/widgets/chat_pending_attachments_bar.dart';
import 'package:art_port/features/chat/widgets/chat_room_header.dart';
import 'package:art_port/features/chat/widgets/chat_status_bar.dart';
import 'package:art_port/features/common/widgets/art_port_header.dart';
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

  void _onSend() {
    final pending =
        ref.read(chatPendingAttachmentsProvider(widget.roomId));
    final text = _messageController.text;

    if (text.trim().isEmpty && pending.isEmpty) return;

    ref.read(chatMessagesProvider(widget.roomId).notifier).sendBatch(
          text: text,
          attachments: pending,
        );
    _messageController.clear();
    ref.read(chatPendingAttachmentsProvider(widget.roomId).notifier).clear();
    _scrollToBottom();
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

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(chatRoomDetailProvider(widget.roomId));
    final messages = ref.watch(chatMessagesProvider(widget.roomId));
    final pendingAttachments =
        ref.watch(chatPendingAttachmentsProvider(widget.roomId));

    if (room == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const ArtPortHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '채팅방을 찾을 수 없습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('돌아가기'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    ref.listen(chatMessagesProvider(widget.roomId), (previous, next) {
      if (previous != null && next.length > previous.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      body: Column(
        children: [
          const ArtPortHeader(),
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
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          ChatStatusBar(statusLabel: room.statusLabel),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(message: messages[index]);
              },
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
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
      ),
    );
  }
}

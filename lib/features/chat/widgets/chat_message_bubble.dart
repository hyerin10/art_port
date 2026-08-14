import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/chat/models/chat_image_attachment.dart';
import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/chat/widgets/chat_image_save_sheet.dart';
import 'package:art_port/features/chat/widgets/chat_image_viewer.dart';
import 'package:art_port/features/chat/widgets/chat_message_image.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onDelete,
  });

  final ChatMessage message;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            Flexible(child: _buildBubble(context)),
            const SizedBox(width: 6),
            _ExternalTimestamp(label: message.timeLabel),
          ] else ...[
            Flexible(child: _buildBubble(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final bubble = switch (message.type) {
      ChatMessageType.image => _ImageBubble(
          message: message,
          onDelete: onDelete,
        ),
      ChatMessageType.file => _FileBubble(message: message),
      _ => _TextBubble(message: message),
    };

    if (onDelete == null || message.type == ChatMessageType.image) {
      return bubble;
    }

    return GestureDetector(
      onLongPress: onDelete,
      child: bubble,
    );
  }
}

class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: isMine ? AppColors.chatOutgoing : Colors.white,
        borderRadius: _bubbleRadius(isMine),
        border: isMine
            ? null
            : Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isMine ? Colors.white : AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          if (isMine) ...[
            const SizedBox(height: 4),
            Text(
              message.timeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageBubble extends StatelessWidget {
  const _ImageBubble({
    required this.message,
    this.onDelete,
  });

  final ChatMessage message;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final attachment = ChatImageAttachment.fromMessage(message);

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: isMine ? AppColors.chatOutgoing : Colors.white,
        borderRadius: _bubbleRadius(isMine),
        border: isMine
            ? null
            : Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (attachment != null)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: GestureDetector(
                onTap: () => ChatImageViewer.open(context, attachment),
                onLongPress: () => ChatImageSaveSheet.show(
                  context,
                  attachment,
                  onDelete: onDelete,
                ),
                child: ChatMessageImage(
                  attachment: attachment,
                  fit: BoxFit.cover,
                  heroTag: attachment.heroTag,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 16,
                  color: isMine ? Colors.white70 : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message.attachmentLabel ?? 'image',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMine ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isMine)
                  Text(
                    message.timeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileBubble extends StatelessWidget {
  const _FileBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isMine ? AppColors.chatOutgoing : Colors.white,
        borderRadius: _bubbleRadius(isMine),
        border: isMine
            ? null
            : Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 28,
            color: isMine ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.attachmentLabel ?? 'file',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isMine ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (message.attachmentSizeLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    message.attachmentSizeLabel!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isMine
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 8),
            Text(
              message.timeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExternalTimestamp extends StatelessWidget {
  const _ExternalTimestamp({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
          height: 1.1,
        ),
      ),
    );
  }
}

BorderRadius _bubbleRadius(bool isMine) {
  const r = Radius.circular(16);
  const sharp = Radius.circular(4);
  return BorderRadius.only(
    topLeft: isMine ? r : sharp,
    topRight: isMine ? sharp : r,
    bottomLeft: r,
    bottomRight: r,
  );
}

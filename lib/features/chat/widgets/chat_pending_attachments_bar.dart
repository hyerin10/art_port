import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 입력창 위 업로드 대기 리스트 (수평 스크롤)
class ChatPendingAttachmentsBar extends StatelessWidget {
  const ChatPendingAttachmentsBar({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  final List<PendingAttachment> attachments;
  final void Function(int index) onRemove;

  static const double _itemSize = 72;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: SizedBox(
          height: _itemSize + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachments.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _PendingThumbnail(
                attachment: attachments[index],
                onRemove: () => onRemove(index),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PendingThumbnail extends StatelessWidget {
  const _PendingThumbnail({
    required this.attachment,
    required this.onRemove,
  });

  final PendingAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ChatPendingAttachmentsBar._itemSize,
      height: ChatPendingAttachmentsBar._itemSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ColoredBox(
              color: AppColors.chipBackground,
              child: _ThumbnailContent(attachment: attachment),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: _RemoveButton(onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailContent extends StatelessWidget {
  const _ThumbnailContent({required this.attachment});

  final PendingAttachment attachment;

  @override
  Widget build(BuildContext context) {
    if (attachment.kind == PendingAttachmentKind.image) {
      final path = attachment.localPath;
      if (path != null && !kIsWeb && File(path).existsSync()) {
        return Image.file(
          File(path),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      }
      return const Center(
        child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 28),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.primary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            attachment.fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textPrimary,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.shadow,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/chat/models/chat_image_attachment.dart';
import 'package:art_port/features/chat/services/chat_image_save_service.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';

/// 이미지 롱 프레스 시 저장 메뉴 바텀시트
class ChatImageSaveSheet extends StatelessWidget {
  const ChatImageSaveSheet({
    super.key,
    required this.attachment,
    this.onDelete,
  });

  final ChatImageAttachment attachment;
  final VoidCallback? onDelete;

  static Future<void> show(
    BuildContext context,
    ChatImageAttachment attachment, {
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChatImageSaveSheet(
        attachment: attachment,
        onDelete: onDelete,
      ),
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final result = await ChatImageSaveService.saveToGallery(attachment);

    if (result == ChatImageSaveResult.success) {
      AppToast.show(messenger, message: '이미지가 저장되었습니다.');
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(ChatImageSaveService.messageFor(result))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                attachment.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                '기기에 저장하기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                '이미지를 갤러리/사진첩에 다운로드',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              onTap: () => _onSave(context),
            ),
            if (onDelete != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
                title: const Text(
                  '메시지 삭제',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onDelete!();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

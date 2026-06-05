import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/chat/models/chat_image_attachment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 채팅 말풍선·풀스크린 뷰어에서 공통으로 쓰는 이미지 위젯
class ChatMessageImage extends StatelessWidget {
  const ChatMessageImage({
    super.key,
    required this.attachment,
    required this.fit,
    this.heroTag,
  });

  final ChatImageAttachment attachment;
  final BoxFit fit;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (heroTag == null) return image;

    return Hero(
      tag: heroTag!,
      child: Material(color: Colors.transparent, child: image),
    );
  }

  Widget _buildImage() {
    final localPath = attachment.localPath;
    if (localPath != null && !kIsWeb) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => _brokenPlaceholder(),
        );
      }
    }

    final url = attachment.networkUrl;
    if (url != null) {
      return Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              color: Colors.white54,
            ),
          );
        },
        errorBuilder: (_, _, _) => _brokenPlaceholder(),
      );
    }

    return _brokenPlaceholder();
  }

  Widget _brokenPlaceholder() {
    return Container(
      color: AppColors.chipBackground,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textMuted,
        size: 40,
      ),
    );
  }
}

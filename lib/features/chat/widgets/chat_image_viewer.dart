import 'package:art_port/features/chat/models/chat_image_attachment.dart';
import 'package:art_port/features/chat/widgets/chat_message_image.dart';
import 'package:flutter/material.dart';

/// 이미지 탭 시 풀스크린 확대 보기
class ChatImageViewer extends StatelessWidget {
  const ChatImageViewer({super.key, required this.attachment});

  final ChatImageAttachment attachment;

  static Future<void> open(BuildContext context, ChatImageAttachment attachment) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ChatImageViewer(attachment: attachment),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: ChatMessageImage(
                attachment: attachment,
                fit: BoxFit.contain,
                heroTag: attachment.heroTag,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:art_port/features/chat/chat_room_screen.dart';
import 'package:art_port/features/mypage/inquiry_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1:1 문의 채팅방 이동 헬퍼
abstract final class InquiryNavigation {
  static void openChatRoom(BuildContext context, String roomId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomScreen(roomId: roomId),
      ),
    );
  }

  static void createAndOpen(BuildContext context, WidgetRef ref) {
    final roomId =
        ref.read(supportInquiriesProvider.notifier).createNewInquiry();
    openChatRoom(context, roomId);
  }

  static void openExisting(BuildContext context, WidgetRef ref, String roomId) {
    ref.read(supportInquiriesProvider.notifier).markAsRead(roomId);
    openChatRoom(context, roomId);
  }
}

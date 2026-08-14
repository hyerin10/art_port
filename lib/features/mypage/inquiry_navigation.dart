import 'package:art_port/features/chat/chat_room_screen.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:flutter/material.dart';

/// 1:1 문의 채팅방 이동 헬퍼
abstract final class InquiryNavigation {
  static void openChatRoom(BuildContext context, String inquiryId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomScreen(
          roomId: SupportInquiryConstants.roomIdFor(inquiryId),
        ),
      ),
    );
  }

  static void openExisting(BuildContext context, String inquiryId) {
    openChatRoom(context, inquiryId);
  }

  static void openCreated(BuildContext context, String inquiryId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomScreen(
          roomId: SupportInquiryConstants.roomIdFor(inquiryId),
        ),
      ),
    );
  }
}

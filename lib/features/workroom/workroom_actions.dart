import 'package:art_port/features/chat/chat_room_screen.dart';
import 'package:art_port/features/workroom/order_detail_screen.dart';
import 'package:flutter/material.dart';

/// 작업실 화면 액션 헬퍼
abstract final class WorkroomActions {
  static void openChat(BuildContext context, String roomId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomScreen(roomId: roomId),
      ),
    );
  }

  static void openOrderDetail(BuildContext context, String orderId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderDetailScreen(orderId: orderId),
      ),
    );
  }
}

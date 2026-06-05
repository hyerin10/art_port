import 'package:art_port/features/chat/chat_room_view.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return ChatRoomView(roomId: roomId);
  }
}

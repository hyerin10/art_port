import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/chat/data/chat_message_repository.dart';
import 'package:art_port/features/chat/data/chat_room_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  return ChatRoomRepository(ref.watch(apiClientProvider));
});

final chatMessageRepositoryProvider = Provider<ChatMessageRepository>((ref) {
  return ChatMessageRepository(ref.watch(apiClientProvider));
});

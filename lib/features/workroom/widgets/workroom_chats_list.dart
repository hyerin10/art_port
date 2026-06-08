import 'package:art_port/features/workroom/widgets/chat_list_tile.dart';
import 'package:art_port/features/workroom/widgets/workroom_empty_state.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실 채팅 탭 목록
class WorkroomChatsList extends ConsumerWidget {
  const WorkroomChatsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(workroomChatsProvider);

    if (chats.isEmpty) {
      return const WorkroomEmptyState(message: '채팅방이 없습니다.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 24),
      itemCount: chats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return ChatListTile(item: chats[index]);
      },
    );
  }
}

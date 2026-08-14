import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
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
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) {
      return const WorkroomEmptyState(message: '로그인하면 채팅을 볼 수 있습니다.');
    }

    final chats = ref.watch(workroomChatsProvider);
    return ApiAsyncBody<List<WorkroomChatItem>>(
      value: chats,
      onRetry: () => ref.invalidate(workroomChatsProvider),
      errorMessage: '채팅 목록을 불러오지 못했습니다.',
      builder: (data) {
        if (data.isEmpty) {
          return const WorkroomEmptyState(message: '채팅방이 없습니다.');
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 24),
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            return ChatListTile(item: data[index]);
          },
        );
      },
    );
  }
}

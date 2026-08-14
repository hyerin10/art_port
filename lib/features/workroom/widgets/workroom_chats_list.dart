import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/chat/chat_room_actions.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
import 'package:art_port/features/workroom/widgets/chat_list_tile.dart';
import 'package:art_port/features/workroom/widgets/workroom_empty_state.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실 채팅 탭 목록
class WorkroomChatsList extends ConsumerStatefulWidget {
  const WorkroomChatsList({super.key});

  @override
  ConsumerState<WorkroomChatsList> createState() => _WorkroomChatsListState();
}

class _WorkroomChatsListState extends ConsumerState<WorkroomChatsList> {
  final _hiddenIds = <String>{};

  @override
  Widget build(BuildContext context) {
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
        final visible = [
          for (final item in data)
            if (!_hiddenIds.contains(item.id)) item,
        ];
        if (visible.isEmpty) {
          return const WorkroomEmptyState(message: '채팅방이 없습니다.');
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 24),
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final item = visible[index];
            return Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              background: const _ChatDeleteBackground(),
              confirmDismiss: (_) async {
                final deleted = await ChatRoomActions.confirmAndDeleteRoom(
                  context: context,
                  ref: ref,
                  roomId: item.id,
                );
                if (deleted && mounted) {
                  setState(() => _hiddenIds.add(item.id));
                }
                return deleted;
              },
              child: ChatListTile(item: item),
            );
          },
        );
      },
    );
  }
}

class _ChatDeleteBackground extends StatelessWidget {
  const _ChatDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}

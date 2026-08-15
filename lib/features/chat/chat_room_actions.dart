import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/chat/chat_room_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class ChatRoomActions {
  static Future<bool> confirmAndDeleteRoom({
    required BuildContext context,
    required WidgetRef ref,
    required String roomId,
    bool showSuccessToast = true,
  }) async {
    if (!isApiChatRoom(roomId)) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 삭제'),
        content: const Text('이 채팅방을 삭제할까요? 삭제 후에는 대화를 볼 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    try {
      await ref.read(chatRoomRepositoryProvider).delete(roomId);
      ref.invalidate(workroomChatsProvider);
      ref.invalidate(chatRoomDetailProvider(roomId));
      ref.invalidate(chatMessagesProvider(roomId));
      if (showSuccessToast && context.mounted) {
        AppToast.show(
          ScaffoldMessenger.of(context),
          message: '채팅방을 삭제했습니다.',
        );
      }
      return true;
    } on ApiException catch (e) {
      if (context.mounted) {
        AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        AppToast.show(
          ScaffoldMessenger.of(context),
          message: '채팅방 삭제에 실패했습니다. 다시 시도해 주세요.',
        );
      }
      return false;
    }
  }
}

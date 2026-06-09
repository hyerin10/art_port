import 'package:art_port/features/workroom/models/workroom_sample.dart';

/// 신청서 제출 등으로 동적 생성된 작업실 채팅방
abstract final class WorkroomChatRegistry {
  static final List<WorkroomChatItem> _items = [];

  static List<WorkroomChatItem> get items => List.unmodifiable(_items);

  static void register({
    required String roomId,
    required String artistName,
    required String artistAvatarUrl,
    required String clientName,
    required String clientAvatarUrl,
    required String preview,
    DateTime? lastMessageTimestamp,
  }) {
    final timestamp = lastMessageTimestamp ?? DateTime.now();
    _items.removeWhere((item) => item.id == roomId);

    _items.addAll([
      WorkroomChatItem(
        id: roomId,
        counterpartName: artistName,
        avatarUrl: artistAvatarUrl,
        lastMessagePreview: preview,
        timeAgoLabel: '방금',
        lastMessageTimestamp: timestamp,
        unreadCount: 1,
        isOnline: true,
        isReceivedAsArtist: false,
      ),
      WorkroomChatItem(
        id: roomId,
        counterpartName: clientName,
        avatarUrl: clientAvatarUrl,
        lastMessagePreview: preview,
        timeAgoLabel: '방금',
        lastMessageTimestamp: timestamp,
        unreadCount: 1,
        isOnline: true,
        isReceivedAsArtist: true,
      ),
    ]);
  }

  static void updatePreview({
    required String roomId,
    required String preview,
  }) {
    final timestamp = DateTime.now();
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].id == roomId) {
        final item = _items[i];
        _items[i] = WorkroomChatItem(
          id: item.id,
          counterpartName: item.counterpartName,
          avatarUrl: item.avatarUrl,
          lastMessagePreview: preview,
          timeAgoLabel: '방금',
          lastMessageTimestamp: timestamp,
          unreadCount: item.unreadCount,
          isOnline: item.isOnline,
          isReceivedAsArtist: item.isReceivedAsArtist,
        );
      }
    }
  }
}

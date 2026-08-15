import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/chat/data/chat_providers.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:art_port/features/order/data/order_providers.dart';
import 'package:art_port/features/workroom/models/workroom_commission_order.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실 하위 탭: 채팅 / 주문 현황
enum WorkroomSubTab { chats, orders }

final workroomSubTabProvider =
    NotifierProvider<WorkroomSubTabNotifier, WorkroomSubTab>(
  WorkroomSubTabNotifier.new,
);

class WorkroomSubTabNotifier extends Notifier<WorkroomSubTab> {
  @override
  WorkroomSubTab build() => WorkroomSubTab.chats;

  void select(WorkroomSubTab tab) => state = tab;
}

/// 모드에 따라 필터링된 채팅방 목록
final workroomChatsProvider = FutureProvider<List<WorkroomChatItem>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final isArtistMode = ref.watch(appModeProvider);
  final rooms = await ref.watch(chatRoomRepositoryProvider).getAll();
  final filtered = [
    for (final room in rooms)
      if (isArtistMode ? room.artistId == userId : room.clientId == userId) room,
  ];

  final lookups = await ParticipantLookups.resolve(
    ref,
    userIds: [
      for (final room in filtered) ...[room.clientId, room.artistId],
    ],
  );

  final items = [
    for (final room in filtered)
      WorkroomChatItem(
        id: room.id,
        counterpartName: lookups.nameFor(room.counterpartId(userId)),
        avatarUrl: lookups.avatarFor(room.counterpartId(userId)),
        lastMessagePreview:
            room.lastMessagePreview ?? '아직 메시지가 없습니다.',
        timeAgoLabel: room.lastMessageAt == null
            ? ''
            : formatWorkroomRelativeTime(room.lastMessageAt!.toLocal()),
        lastMessageTimestamp: room.lastMessageAt?.toLocal() ??
            DateTime.fromMillisecondsSinceEpoch(0),
        unreadCount: room.unreadCount,
        isReceivedAsArtist: room.artistId == userId,
      ),
  ]..sort(
      (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
    );

  return items;
});

/// 모드에 따라 필터링된 주문 현황 목록
final workroomOrdersProvider =
    FutureProvider<List<WorkroomCommissionOrder>>((ref) async {
  final orders = await ref.watch(myOrdersProvider.future);
  final lookups = await ref.watch(orderLookupsProvider.future);
  final isArtistMode = ref.watch(appModeProvider);

  return [
    for (final order in orders)
      OrderMappers.toWorkroomOrder(
        order,
        lookups: lookups,
        isArtistMode: isArtistMode,
      ),
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
});

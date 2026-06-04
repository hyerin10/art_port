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
///
/// - 의뢰인 모드 (`isArtistMode == false`): 내가 신청한 채팅방
/// - 작가 모드 (`isArtistMode == true`): 내가 접수한 채팅방
final workroomChatsProvider = Provider<List<WorkroomChatItem>>((ref) {
  final isArtistMode = ref.watch(appModeProvider);

  // TODO: API 연동 시
  // if (isArtistMode) {
  //   return chatRepository.fetchReceivedChatRooms();
  // }
  // return chatRepository.fetchRequestedChatRooms();

  return WorkroomDummyData.chatRooms
      .where((item) => item.isReceivedAsArtist == isArtistMode)
      .toList();
});

/// 모드에 따라 필터링된 주문 목록
///
/// - 의뢰인 모드: 내가 신청한 주문
/// - 작가 모드: 내가 접수한 주문
final workroomOrdersProvider = Provider<List<WorkroomOrderItem>>((ref) {
  final isArtistMode = ref.watch(appModeProvider);

  // TODO: API 연동 시
  // if (isArtistMode) {
  //   return orderRepository.fetchReceivedOrders();
  // }
  // return orderRepository.fetchRequestedOrders();

  return WorkroomDummyData.orders
      .where((item) => item.isReceivedAsArtist == isArtistMode)
      .toList();
});

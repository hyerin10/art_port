import 'package:art_port/features/commission/commission_transaction_providers.dart';
import 'package:art_port/features/workroom/models/workroom_commission_order.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
import 'package:art_port/features/workroom/workroom_chat_registry.dart';
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
  ref.watch(commissionTransactionRegistryProvider);

  // TODO: API 연동 시
  // if (isArtistMode) {
  //   return chatRepository.fetchReceivedChatRooms();
  // }
  // return chatRepository.fetchRequestedChatRooms();

  final chats = [
    ...WorkroomDummyData.chatRooms().where(
      (item) => item.isReceivedAsArtist == isArtistMode,
    ),
    ...WorkroomChatRegistry.items.where(
      (item) => item.isReceivedAsArtist == isArtistMode,
    ),
  ]..sort(
      (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
    );

  return chats;
});

/// 커미션 거래 레지스트리 기반 주문 현황 목록 (채팅 탭과 동일 SSOT)
final workroomCommissionOrdersProvider =
    Provider<List<WorkroomCommissionOrder>>((ref) {
  final isArtistMode = ref.watch(appModeProvider);
  final transactions =
      ref.watch(commissionTransactionRegistryProvider).values.toList();

  return transactions
      .map(
        (tx) => WorkroomCommissionOrder.fromTransaction(
          tx,
          isArtistMode: isArtistMode,
        ),
      )
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
});

/// 모드에 따라 필터링된 주문 목록
///
/// 커미션 거래 데이터(`commissionTransactionRegistryProvider`)와 실시간 동기화됩니다.
final workroomOrdersProvider = Provider<List<WorkroomCommissionOrder>>((ref) {
  return ref.watch(workroomCommissionOrdersProvider);
});
import 'package:art_port/features/openslot/models/slot_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mySlotsProvider =
    NotifierProvider<MySlotsNotifier, List<SlotModel>>(MySlotsNotifier.new);

class MySlotsNotifier extends Notifier<List<SlotModel>> {
  @override
  List<SlotModel> build() => List<SlotModel>.from(SlotDummyData.initialSlots);

  void removeSlot(String id) {
    state = [
      for (final slot in state)
        if (slot.id != id) slot,
    ];
  }

  void updateSlot(SlotModel updated) {
    state = [
      for (final slot in state)
        if (slot.id == updated.id) updated else slot,
    ];
  }

  void addSlot(SlotModel slot) {
    state = [...state, slot];
  }
}

/// 대시보드 요약 수치 (활성 슬롯은 목록에서 파생, 나머지는 추후 API 연동)
final openSlotDashboardProvider = Provider<OpenSlotDashboardStats>((ref) {
  final slots = ref.watch(mySlotsProvider);
  final activeCount = slots.where((s) => !s.isFull).length;

  // TODO: API 연동 시 진행 중 주문·월 정산 금액 조회
  return OpenSlotDashboardStats(
    activeSlotCount: activeCount,
    ordersInProgress: 6,
    monthlyEarningsWon: 320000,
  );
});

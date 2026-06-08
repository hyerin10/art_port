import 'package:art_port/features/openslot/models/slot_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mySlotsProvider =
    AsyncNotifierProvider<MySlotsNotifier, List<SlotModel>>(MySlotsNotifier.new);

class MySlotsNotifier extends AsyncNotifier<List<SlotModel>> {
  @override
  Future<List<SlotModel>> build() => _fetchSlots();

  Future<List<SlotModel>> _fetchSlots() async {
    // TODO: API 연동 시 교체
    return List<SlotModel>.from(SlotDummyData.initialSlots);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchSlots);
  }

  void removeSlot(String id) {
    final current = state.requireValue;
    state = AsyncData([
      for (final slot in current)
        if (slot.id != id) slot,
    ]);
  }

  void updateSlot(SlotModel updated) {
    final current = state.requireValue;
    state = AsyncData([
      for (final slot in current)
        if (slot.id == updated.id) updated else slot,
    ]);
  }

  void addSlot(SlotModel slot) {
    final current = state.requireValue;
    state = AsyncData([...current, slot]);
  }
}

/// 대시보드 요약 수치 (활성 슬롯은 목록에서 파생, 나머지는 추후 API 연동)
final openSlotDashboardProvider = Provider<AsyncValue<OpenSlotDashboardStats>>(
  (ref) {
    return ref.watch(mySlotsProvider).whenData(_buildDashboardStats);
  },
);

OpenSlotDashboardStats _buildDashboardStats(List<SlotModel> slots) {
  final activeCount = slots.where((s) => !s.isFull).length;

  // TODO: API 연동 시 진행 중 주문·월 정산 금액 조회
  return OpenSlotDashboardStats(
    activeSlotCount: activeCount,
    ordersInProgress: 6,
    monthlyEarningsWon: 320000,
  );
}

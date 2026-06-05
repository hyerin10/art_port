import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 결제 내역 필터
enum PaymentHistoryFilter {
  all,
  completed,
  canceled,
}

extension PaymentHistoryFilterLabel on PaymentHistoryFilter {
  String get label => switch (this) {
        PaymentHistoryFilter.all => '전체',
        PaymentHistoryFilter.completed => '결제 완료',
        PaymentHistoryFilter.canceled => '결제 취소',
      };
}

/// 결제 내역 필터 상태
final paymentHistoryFilterProvider =
    NotifierProvider<PaymentHistoryFilterNotifier, PaymentHistoryFilter>(
  PaymentHistoryFilterNotifier.new,
);

class PaymentHistoryFilterNotifier extends Notifier<PaymentHistoryFilter> {
  @override
  PaymentHistoryFilter build() => PaymentHistoryFilter.all;

  void select(PaymentHistoryFilter filter) => state = filter;
}

/// 결제 내역 원본 데이터
final paymentHistoryItemsProvider = Provider<List<PaymentHistoryItem>>((ref) {
  return PaymentHistoryDummyData.items;
});

/// 필터 적용된 결제 내역
final filteredPaymentHistoryProvider =
    Provider<List<PaymentHistoryItem>>((ref) {
  final items = ref.watch(paymentHistoryItemsProvider);
  final filter = ref.watch(paymentHistoryFilterProvider);

  return switch (filter) {
    PaymentHistoryFilter.all => items,
    PaymentHistoryFilter.completed =>
      items.where((i) => i.status == PaymentStatus.completed).toList(),
    PaymentHistoryFilter.canceled =>
      items.where((i) => i.status == PaymentStatus.canceled).toList(),
  };
});

/// 이번 달 지출 금액 (결제 완료 건만 합산)
final monthlySpendingProvider = Provider<int>((ref) {
  final items = ref.watch(paymentHistoryItemsProvider);
  final now = DateTime.now();

  return items
      .where(
        (item) =>
            item.status == PaymentStatus.completed &&
            item.paidAt.year == now.year &&
            item.paidAt.month == now.month,
      )
      .fold<int>(0, (sum, item) => sum + item.totalAmount);
});

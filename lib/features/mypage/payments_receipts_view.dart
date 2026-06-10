import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/mypage/mypage_navigation.dart';
import 'package:art_port/features/mypage/payments_receipts_actions.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/payments_receipts_body.dart';
import 'package:art_port/features/mypage/widgets/payments_receipts_header.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/payment_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 결제 및 영수증 통합 화면
class PaymentsReceiptsView extends ConsumerWidget {
  const PaymentsReceiptsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(paymentHistoryItemsProvider);
    final filteredItems = ref.watch(filteredPaymentHistoryProvider);
    final monthlySpending = ref.watch(monthlySpendingProvider);
    final activeFilter = ref.watch(paymentHistoryFilterProvider);
    final isArtistMode = ref.watch(appModeProvider);
    final screenTitle =
        isArtistMode ? '결제 내역 관리' : '결제 및 영수증';
    final summaryLabel =
        isArtistMode ? '이번 달 수익 금액' : '이번 달 지출 금액';

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      header: PaymentsReceiptsHeader(
        onBack: () => Navigator.of(context).pop(),
        title: screenTitle,
      ),
      body: allItems.isEmpty
          ? EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: '결제 내역이 아직 없습니다',
              subtitle: '커미션 결제 및 영수증 내역이 여기에 표시됩니다',
              actionLabel: '커미션 둘러보기',
              onAction: () =>
                  MyPageNavigation.navigateToExploreTab(context, ref),
              actionPlacement: EmptyStateActionPlacement.bottom,
            )
          : PaymentsReceiptsBody(
              monthlySpending: monthlySpending,
              summaryLabel: summaryLabel,
              activeFilter: activeFilter,
              filteredItems: filteredItems,
              onFilterSelected: (filter) => ref
                  .read(paymentHistoryFilterProvider.notifier)
                  .select(filter),
              onViewReceipt: (item) =>
                  PaymentsReceiptsActions.openReceiptDetail(context, item),
            ),
    );
  }
}

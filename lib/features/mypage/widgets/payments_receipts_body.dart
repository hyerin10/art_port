import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:art_port/features/mypage/widgets/monthly_spending_card.dart';
import 'package:art_port/features/mypage/widgets/payment_filter_chips.dart';
import 'package:art_port/features/mypage/widgets/payment_history_card.dart';
import 'package:art_port/providers/payment_history_provider.dart';
import 'package:flutter/material.dart';

/// 결제 및 영수증 본문 (목록)
class PaymentsReceiptsBody extends StatelessWidget {
  const PaymentsReceiptsBody({
    super.key,
    required this.monthlySpending,
    required this.summaryLabel,
    required this.activeFilter,
    required this.filteredItems,
    required this.onFilterSelected,
    required this.onViewReceipt,
  });

  final int monthlySpending;
  final String summaryLabel;
  final PaymentHistoryFilter activeFilter;
  final List<PaymentHistoryItem> filteredItems;
  final ValueChanged<PaymentHistoryFilter> onFilterSelected;
  final ValueChanged<PaymentHistoryItem> onViewReceipt;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: MonthlySpendingCard(
              amount: monthlySpending,
              summaryLabel: summaryLabel,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: PaymentFilterChips(
              activeFilter: activeFilter,
              onFilterSelected: onFilterSelected,
            ),
          ),
        ),
        if (filteredItems.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView(
              icon: Icons.filter_list_off_rounded,
              title: '해당 조건의 결제 내역이 없습니다',
              subtitle: '다른 필터를 선택해 보세요',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: filteredItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return PaymentHistoryCard(
                  item: item,
                  onViewReceipt: () => onViewReceipt(item),
                );
              },
            ),
          ),
      ],
    );
  }
}

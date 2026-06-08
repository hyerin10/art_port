import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:art_port/features/mypage/mypage_navigation.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/payments_receipts_header.dart';
import 'package:art_port/features/mypage/widgets/receipt_detail_bottom_sheet.dart';
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
    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      header: PaymentsReceiptsHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: allItems.isEmpty
          ? _PaymentsEmptyState(
              onExploreTap: () =>
                  MyPageNavigation.navigateToExploreTab(context, ref),
            )
          : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _MonthlySpendingCard(
                            amount: monthlySpending,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: _PaymentFilterChips(
                            activeFilter: activeFilter,
                            onFilterSelected: (filter) => ref
                                .read(paymentHistoryFilterProvider.notifier)
                                .select(filter),
                          ),
                        ),
                      ),
                      if (filteredItems.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _FilteredEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          sliver: SliverList.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _PaymentHistoryCard(
                                item: filteredItems[index],
                                onViewReceipt: () =>
                                    _openReceiptDetail(context, filteredItems[index]),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
    );
  }

  void _openReceiptDetail(BuildContext context, PaymentHistoryItem item) {
    ReceiptDetailBottomSheet.show(
      context,
      item: item,
      onDownloadPdf: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF 다운로드를 준비 중입니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

// ─── Monthly Spending Card ─────────────────────────────────────────────────────

class _MonthlySpendingCard extends StatelessWidget {
  const _MonthlySpendingCard({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이번 달 지출 금액',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatWonSymbol(amount),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chips ──────────────────────────────────────────────────────────────

class _PaymentFilterChips extends StatelessWidget {
  const _PaymentFilterChips({
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final PaymentHistoryFilter activeFilter;
  final ValueChanged<PaymentHistoryFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < PaymentHistoryFilter.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          _PaymentFilterChip(
            label: PaymentHistoryFilter.values[i].label,
            isActive: activeFilter == PaymentHistoryFilter.values[i],
            onTap: () => onFilterSelected(PaymentHistoryFilter.values[i]),
          ),
        ],
      ],
    );
  }
}

class _PaymentFilterChip extends StatelessWidget {
  const _PaymentFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? AppColors.primary : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Payment History Card ──────────────────────────────────────────────────────

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({
    required this.item,
    required this.onViewReceipt,
  });

  final PaymentHistoryItem item;
  final VoidCallback onViewReceipt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 72,
                  height: 72,
                  color: AppColors.primarySoft,
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.artistName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.totalAmountLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.paidAtLabel} • ${item.paymentMethod.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _PaymentStatusBadge(status: item.status),
                      const Spacer(),
                      if (item.status != PaymentStatus.processing)
                        GestureDetector(
                          onTap: onViewReceipt,
                          child: const Text(
                            '영수증 보기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      PaymentStatus.completed => (
          const Color(0xFFD1FAE5),
          const Color(0xFF059669),
          Icons.check_circle_outline_rounded,
        ),
      PaymentStatus.processing => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          Icons.schedule_rounded,
        ),
      PaymentStatus.canceled => (
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626),
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty States ──────────────────────────────────────────────────────────────

class _PaymentsEmptyState extends StatelessWidget {
  const _PaymentsEmptyState({required this.onExploreTap});

  final VoidCallback onExploreTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.chipBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 44,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '결제 내역이 아직 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '커미션 결제 및 영수증 내역이 여기에 표시됩니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Material(
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(28),
              color: AppColors.primary,
              child: InkWell(
                onTap: onExploreTap,
                borderRadius: BorderRadius.circular(28),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  child: Text(
                    '커미션 둘러보기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.filter_list_off_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              '해당 조건의 결제 내역이 없습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

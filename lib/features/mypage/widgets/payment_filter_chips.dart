import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/providers/payment_history_provider.dart';
import 'package:flutter/material.dart';

/// 결제 내역 필터 칩 목록
class PaymentFilterChips extends StatelessWidget {
  const PaymentFilterChips({
    super.key,
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
          PaymentFilterChip(
            label: PaymentHistoryFilter.values[i].label,
            isActive: activeFilter == PaymentHistoryFilter.values[i],
            onTap: () => onFilterSelected(PaymentHistoryFilter.values[i]),
          ),
        ],
      ],
    );
  }
}

/// 결제 내역 필터 단일 칩
class PaymentFilterChip extends StatelessWidget {
  const PaymentFilterChip({
    super.key,
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

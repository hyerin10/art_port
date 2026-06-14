import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

/// 출금 내역 요약 카드
class WithdrawalSummaryCard extends StatelessWidget {
  const WithdrawalSummaryCard({
    super.key,
    required this.requestedAmount,
    required this.feeAmount,
    required this.finalDepositAmount,
  });

  final int requestedAmount;
  final int feeAmount;
  final int finalDepositAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '출금 내역',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          const SizedBox(height: 4),
          _SummaryRow(
            label: '신청 금액',
            value: CurrencyFormatter.formatWon(requestedAmount),
          ),
          _SummaryRow(
            label: '수수료 / 세금',
            value: CurrencyFormatter.formatWon(feeAmount),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          const SizedBox(height: 4),
          _SummaryRow(
            label: '최종 입금 예정 금액',
            value: CurrencyFormatter.formatWon(finalDepositAmount),
            isTotal: true,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: isTotal ? 14 : 13,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
      color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
    );
    final valueStyle = TextStyle(
      fontSize: isTotal ? 15 : 13,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
      color: isTotal ? AppColors.primary : AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

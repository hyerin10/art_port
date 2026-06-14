import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

/// 출금 가능한 수익금 카드
class WithdrawalAvailableProfitCard extends StatelessWidget {
  const WithdrawalAvailableProfitCard({
    super.key,
    required this.amount,
  });

  final int amount;

  static const _cardBackground = Color(0xFFF0F0FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '출금 가능한 수익금',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatWon(amount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

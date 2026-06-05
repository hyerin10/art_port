import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:flutter/material.dart';

/// 결제 정보 카드
class OrderPaymentInfoCard extends StatelessWidget {
  const OrderPaymentInfoCard({
    super.key,
    required this.payment,
  });

  final WorkroomOrderPayment payment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _PaymentRow(label: '기본 가격', value: payment.basePriceLabel),
          const SizedBox(height: 12),
          _PaymentRow(label: '추가 옵션', value: payment.additionalOptionsLabel),
          const SizedBox(height: 12),
          _PaymentRow(label: '플랫폼 수수료', value: payment.platformFeeLabel),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          ),
          Row(
            children: [
              const Text(
                '총 결제 금액',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                payment.totalLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.2,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

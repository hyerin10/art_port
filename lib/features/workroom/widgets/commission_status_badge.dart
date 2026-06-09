import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/commission/models/commission_status.dart';
import 'package:flutter/material.dart';

/// 커미션 거래 단계 상태 뱃지 (주문 현황 탭)
class CommissionStatusBadge extends StatelessWidget {
  const CommissionStatusBadge({
    super.key,
    required this.status,
    this.isDeclined = false,
  });

  final CommissionStatus status;
  final bool isDeclined;

  ({Color background, Color foreground, IconData icon, String label})
      get _style {
    if (isDeclined) {
      return (
        background: const Color(0xFFFEE2E2),
        foreground: AppColors.error,
        icon: Icons.cancel_outlined,
        label: '거절됨',
      );
    }

    return switch (status) {
      CommissionStatus.submitted => (
          background: const Color(0xFFDBEAFE),
          foreground: const Color(0xFF2563EB),
          icon: Icons.description_outlined,
          label: status.orderLabel,
        ),
      CommissionStatus.accepted => (
          background: const Color(0xFFDCFCE7),
          foreground: AppColors.success,
          icon: Icons.check_circle_outline_rounded,
          label: status.orderLabel,
        ),
      CommissionStatus.paymentRequested => (
          background: const Color(0xFFEDE9FE),
          foreground: AppColors.primary,
          icon: Icons.payment_rounded,
          label: status.orderLabel,
        ),
      CommissionStatus.paid => (
          background: const Color(0xFFDCFCE7),
          foreground: const Color(0xFF15803D),
          icon: Icons.verified_outlined,
          label: status.orderLabel,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foreground),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: style.foreground,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

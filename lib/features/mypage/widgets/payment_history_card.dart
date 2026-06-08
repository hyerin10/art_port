import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:flutter/material.dart';

/// 결제 내역 카드
class PaymentHistoryCard extends StatelessWidget {
  const PaymentHistoryCard({
    super.key,
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
                      PaymentStatusBadge(status: item.status),
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

/// 결제 상태 배지 표시 스타일
enum PaymentStatusBadgeVariant { card, detail }

/// 결제 상태 배지
class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.variant = PaymentStatusBadgeVariant.card,
  });

  final PaymentStatus status;
  final PaymentStatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final isDetail = variant == PaymentStatusBadgeVariant.detail;
    final (bg, fg, icon) = switch (status) {
      PaymentStatus.completed => isDetail
          ? (
              const Color(0xFFD1FAE5),
              const Color(0xFF059669),
              Icons.check_circle_outline_rounded,
            )
          : (
              AppColors.primaryLight,
              AppColors.success,
              Icons.check_circle_outline_rounded,
            ),
      PaymentStatus.processing => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          Icons.schedule_rounded,
        ),
      PaymentStatus.canceled => (
          const Color(0xFFFEE2E2),
          isDetail ? const Color(0xFFDC2626) : AppColors.error,
          Icons.cancel_outlined,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDetail ? 10 : 8,
        vertical: isDetail ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isDetail ? 14 : 13, color: fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: isDetail ? 12 : 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

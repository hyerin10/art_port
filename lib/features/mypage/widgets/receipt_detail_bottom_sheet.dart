import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:flutter/material.dart';

/// 영수증 상세 바텀시트
class ReceiptDetailBottomSheet extends StatelessWidget {
  const ReceiptDetailBottomSheet({
    super.key,
    required this.item,
    required this.onDownloadPdf,
  });

  final PaymentHistoryItem item;
  final VoidCallback onDownloadPdf;

  static Future<void> show(
    BuildContext context, {
    required PaymentHistoryItem item,
    required VoidCallback onDownloadPdf,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ReceiptDetailBottomSheet(
          item: item,
          onDownloadPdf: () {
            Navigator.of(ctx).pop();
            onDownloadPdf();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SheetHeader(onClose: () => Navigator.of(context).pop()),
                    const SizedBox(height: 24),
                    const _PlatformLogoSection(),
                    const SizedBox(height: 28),
                    _DetailRow(label: '주문 ID', value: item.orderId),
                    const SizedBox(height: 14),
                    _DetailRow(label: '결제 일시', value: item.paidAtLabel),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: '결제 수단',
                      value: item.paymentMethod.label,
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      label: '상태',
                      valueWidget: _StatusBadge(status: item.status),
                    ),
                    const SizedBox(height: 20),
                    _ProductInfoCard(item: item),
                    const SizedBox(height: 20),
                    _AmountRow(
                      label: '공급가액',
                      amount: item.subtotalAmountLabel,
                    ),
                    const SizedBox(height: 10),
                    _AmountRow(
                      label: '부가세 (10%)',
                      amount: item.vatAmountLabel,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: AppColors.borderLight),
                    ),
                    _AmountRow(
                      label: '총 결제금액',
                      amount: item.totalAmountLabel,
                      isTotal: true,
                    ),
                    const SizedBox(height: 20),
                    const _CompanyFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _DownloadPdfButton(onTap: onDownloadPdf),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '영수증 상세',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, size: 22),
          color: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

class _PlatformLogoSection extends StatelessWidget {
  const _PlatformLogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'ArtPort',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '아트 커미션 플랫폼',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: valueWidget ??
              Text(
                value ?? '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

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

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              status.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.item});

  final PaymentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
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
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: AppColors.borderLight,
                      backgroundImage: NetworkImage(item.artistAvatarUrl),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
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
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  final String label;
  final String amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 17 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CompanyFooter extends StatelessWidget {
  const _CompanyFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        children: [
          Text(
            'ArtPort Inc. | 사업자등록번호: 123-45-67890',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          Text(
            'support@artport.com | +82-2-1234-5678',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadPdfButton extends StatelessWidget {
  const _DownloadPdfButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: double.infinity,
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download_rounded, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'PDF 다운로드',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

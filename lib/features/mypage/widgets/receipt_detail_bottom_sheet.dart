import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:art_port/features/mypage/widgets/receipt_detail_body.dart';
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
      builder: (ctx) => ReceiptDetailBottomSheet(
        item: item,
        onDownloadPdf: onDownloadPdf,
      ),
    );
  }

  void _handleDownloadPdf(BuildContext context) {
    Navigator.of(context).pop();
    onDownloadPdf();
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
              child: ReceiptDetailBody(
                item: item,
                onClose: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _DownloadPdfButton(
                onTap: () => _handleDownloadPdf(context),
              ),
            ),
          ],
        ),
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

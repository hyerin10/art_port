import 'package:art_port/features/mypage/models/payment_history_item.dart';
import 'package:art_port/features/mypage/widgets/receipt_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// 결제 및 영수증 화면 액션 헬퍼
abstract final class PaymentsReceiptsActions {
  static void openReceiptDetail(
    BuildContext context,
    PaymentHistoryItem item,
  ) {
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

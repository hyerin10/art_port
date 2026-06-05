import 'package:art_port/features/mypage/payments_receipts_view.dart';
import 'package:flutter/material.dart';

class PaymentsReceiptsScreen extends StatelessWidget {
  const PaymentsReceiptsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PaymentsReceiptsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PaymentsReceiptsView();
  }
}

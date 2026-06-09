import 'package:art_port/features/commission/models/commission_transaction.dart';
import 'package:art_port/features/payment/payment_view.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
    required this.roomId,
    required this.transaction,
  });

  final String roomId;
  final CommissionTransaction transaction;

  static void open(
    BuildContext context, {
    required String roomId,
    required CommissionTransaction transaction,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(
          roomId: roomId,
          transaction: transaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaymentView(roomId: roomId, transaction: transaction);
  }
}

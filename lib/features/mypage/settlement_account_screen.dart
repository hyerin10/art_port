import 'package:art_port/features/mypage/settlement_account_view.dart';
import 'package:flutter/material.dart';

class SettlementAccountScreen extends StatelessWidget {
  const SettlementAccountScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettlementAccountScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SettlementAccountView();
  }
}

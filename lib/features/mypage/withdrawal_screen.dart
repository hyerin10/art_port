import 'package:art_port/features/mypage/withdrawal_view.dart';
import 'package:flutter/material.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WithdrawalScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const WithdrawalView();
  }
}

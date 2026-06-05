import 'package:art_port/features/mypage/commission_type_settings_view.dart';
import 'package:flutter/material.dart';

class CommissionTypeSettingsScreen extends StatelessWidget {
  const CommissionTypeSettingsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CommissionTypeSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const CommissionTypeSettingsView();
  }
}

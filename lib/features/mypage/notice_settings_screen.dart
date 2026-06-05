import 'package:art_port/features/mypage/notice_settings_view.dart';
import 'package:flutter/material.dart';

class NoticeSettingsScreen extends StatelessWidget {
  const NoticeSettingsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NoticeSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const NoticeSettingsView();
  }
}

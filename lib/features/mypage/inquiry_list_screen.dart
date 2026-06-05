import 'package:art_port/features/mypage/inquiry_list_view.dart';
import 'package:flutter/material.dart';

class InquiryListScreen extends StatelessWidget {
  const InquiryListScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const InquiryListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const InquiryListView();
  }
}

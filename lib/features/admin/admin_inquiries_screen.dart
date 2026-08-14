import 'package:art_port/features/admin/admin_inquiries_view.dart';
import 'package:flutter/material.dart';

class AdminInquiriesScreen extends StatelessWidget {
  const AdminInquiriesScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminInquiriesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AdminInquiriesView();
  }
}

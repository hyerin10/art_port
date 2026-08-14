import 'package:art_port/features/admin/admin_applications_view.dart';
import 'package:flutter/material.dart';

class AdminApplicationsScreen extends StatelessWidget {
  const AdminApplicationsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AdminApplicationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AdminApplicationsView();
  }
}

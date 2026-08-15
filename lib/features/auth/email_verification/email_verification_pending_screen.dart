import 'package:art_port/features/auth/email_verification/email_verification_pending_view.dart';
import 'package:flutter/material.dart';

class EmailVerificationPendingScreen extends StatelessWidget {
  const EmailVerificationPendingScreen({super.key});

  static Future<T?> open<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => const EmailVerificationPendingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const EmailVerificationPendingView();
  }
}

import 'package:art_port/features/auth/email_verification/verification_failure_view.dart';
import 'package:flutter/material.dart';

class VerificationFailureScreen extends StatelessWidget {
  const VerificationFailureScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const VerificationFailureScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const VerificationFailureView();
  }
}

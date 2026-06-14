import 'package:art_port/features/auth/email_verification/verification_success_view.dart';
import 'package:flutter/material.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const VerificationSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const VerificationSuccessView();
  }
}

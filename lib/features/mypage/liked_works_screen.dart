import 'package:art_port/features/mypage/liked_works_view.dart';
import 'package:flutter/material.dart';

class LikedWorksScreen extends StatelessWidget {
  const LikedWorksScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LikedWorksScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const LikedWorksView();
  }
}

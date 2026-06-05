import 'package:art_port/features/mypage/followed_artists_view.dart';
import 'package:flutter/material.dart';

class FollowedArtistsScreen extends StatelessWidget {
  const FollowedArtistsScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FollowedArtistsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const FollowedArtistsView();
  }
}

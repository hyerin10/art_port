import 'package:art_port/features/follow/followers_view.dart';
import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({
    super.key,
    required this.userId,
    this.title = '팔로워',
  });

  final String userId;
  final String title;

  static void open(
    BuildContext context, {
    required String userId,
    String title = '팔로워',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FollowersScreen(userId: userId, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FollowersView(userId: userId, title: title);
  }
}

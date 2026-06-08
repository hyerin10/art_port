import 'package:art_port/core/widgets/no_overscroll_scroll_view.dart';
import 'package:flutter/material.dart';

class MyPageScrollView extends StatelessWidget {
  const MyPageScrollView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NoOverscrollScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: child,
    );
  }
}

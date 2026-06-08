import 'package:flutter/material.dart';

class MyPageScrollView extends StatelessWidget {
  const MyPageScrollView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _MyPageScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: child,
      ),
    );
  }
}

class _MyPageScrollBehavior extends ScrollBehavior {
  const _MyPageScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

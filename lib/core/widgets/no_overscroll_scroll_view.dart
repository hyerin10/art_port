import 'package:flutter/material.dart';

/// 오버스크롤 글로우·스크롤바를 숨긴 [SingleChildScrollView] 래퍼
class NoOverscrollScrollView extends StatelessWidget {
  const NoOverscrollScrollView({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _NoOverscrollScrollBehavior(),
      child: SingleChildScrollView(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _NoOverscrollScrollBehavior extends ScrollBehavior {
  const _NoOverscrollScrollBehavior();

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

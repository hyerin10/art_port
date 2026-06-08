import 'package:flutter/material.dart';

/// 검색 탭 가로 스크롤 — 스크롤바·오버스크롤 인디케이터 숨김
class SearchScrollBehavior extends ScrollBehavior {
  const SearchScrollBehavior();

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

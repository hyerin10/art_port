import 'package:flutter/material.dart';

enum AppTab {
  explore,
  search,
  openSlot,
  workroom,
}

extension AppTabX on AppTab {
  String get label {
    switch (this) {
      case AppTab.explore:
        return '탐색';
      case AppTab.search:
        return '검색';
      case AppTab.openSlot:
        return '슬롯 관리';
      case AppTab.workroom:
        return '작업실';
    }
  }

  IconData get icon {
    switch (this) {
      case AppTab.explore:
        return Icons.explore_outlined;
      case AppTab.search:
        return Icons.search;
      case AppTab.openSlot:
        return Icons.event_available_outlined;
      case AppTab.workroom:
        return Icons.chat_bubble_outline;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case AppTab.explore:
        return Icons.explore;
      case AppTab.search:
        return Icons.search;
      case AppTab.openSlot:
        return Icons.event_available;
      case AppTab.workroom:
        return Icons.chat_bubble;
    }
  }
}

abstract final class AppTabNavigation {
  static List<AppTab> tabsForMode({required bool isArtistMode}) {
    if (isArtistMode) {
      return AppTab.values;
    }
    return const [AppTab.explore, AppTab.search, AppTab.workroom];
  }

  /// 모드 전환 시 탭 인덱스를 안전하게 매핑
  static int remapIndex({
    required int currentIndex,
    required bool fromArtistMode,
    required bool toArtistMode,
  }) {
    if (fromArtistMode == toArtistMode) return currentIndex;

    if (fromArtistMode && !toArtistMode) {
      return switch (currentIndex) {
        0 => 0,
        1 => 1,
        2 => 1,
        _ => 2,
      };
    }

    return switch (currentIndex) {
      0 => 0,
      1 => 1,
      _ => 3,
    };
  }
}

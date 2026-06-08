import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/profile_settings_screen.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이페이지 관련 화면 전환 헬퍼
abstract final class MyPageNavigation {
  static void selectMainTab(
    BuildContext context,
    WidgetRef ref,
    int tabIndex,
  ) {
    ref.read(currentTabProvider.notifier).selectTab(tabIndex);
    ref.read(showMyPageProvider.notifier).close();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  static void navigateToExploreTab(BuildContext context, WidgetRef ref) {
    selectMainTab(context, ref, 0);
  }

  static void openProfileSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfileSettingsScreen(),
      ),
    );
  }
}

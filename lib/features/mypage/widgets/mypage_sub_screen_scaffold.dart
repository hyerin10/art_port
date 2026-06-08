import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/mypage/mypage_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이페이지 서브 화면 공통 Scaffold (헤더 + 본문 + 하단 탭)
class MyPageSubScreenScaffold extends ConsumerWidget {
  const MyPageSubScreenScaffold({
    super.key,
    required this.header,
    required this.body,
    this.footer,
    this.backgroundColor = AppColors.background,
  });

  final Widget header;
  final Widget body;
  final Widget? footer;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          header,
          Expanded(child: body),
          ?footer,
        ],
      ),
      bottomNavigationBar: ArtPortBottomNav(
        onTabSelected: (index) =>
            MyPageNavigation.selectMainTab(context, ref, index),
      ),
    );
  }
}

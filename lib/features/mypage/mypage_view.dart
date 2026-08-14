import 'package:art_port/features/auth/presentation/auth_session_effects.dart';
import 'package:art_port/features/mypage/artist_mypage_content.dart';
import 'package:art_port/features/mypage/client_mypage_content.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이페이지 메인 뷰 — Client / Artist 모드에 따라 UI 분기
class MyPageView extends ConsumerStatefulWidget {
  const MyPageView({super.key});

  @override
  ConsumerState<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends ConsumerState<MyPageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshCurrentUser(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArtistMode = ref.watch(appModeProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isArtistMode
          ? const ArtistMyPageContent(key: ValueKey('artist'))
          : const ClientMyPageContent(key: ValueKey('client')),
    );
  }
}

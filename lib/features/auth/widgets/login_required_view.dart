import 'package:art_port/features/auth/sign_in_screen.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:flutter/material.dart';

/// 비로그인 사용자에게 표시하는 로그인 안내 페이지
class LoginRequiredView extends StatelessWidget {
  const LoginRequiredView({
    super.key,
    this.title = '로그인이 필요합니다',
    this.subtitle = '이 기능을 이용하려면\n로그인 후 이용해 주세요.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: Icons.lock_outline_rounded,
      title: title,
      subtitle: subtitle,
      actionLabel: '로그인하기',
      onAction: () => SignInScreen.open(context),
      actionPlacement: EmptyStateActionPlacement.inline,
    );
  }
}

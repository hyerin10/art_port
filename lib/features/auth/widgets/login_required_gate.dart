import 'package:art_port/features/auth/widgets/login_required_view.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인된 사용자만 자식 위젯을 표시하고, 비로그인 시 안내 페이지를 노출합니다.
class LoginRequiredGate extends ConsumerWidget {
  const LoginRequiredGate({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (isLoggedIn) {
      return child;
    }

    return LoginRequiredView(
      title: title ?? '로그인이 필요합니다',
      subtitle: subtitle ??
          '이 기능을 이용하려면\n로그인 후 이용해 주세요.',
    );
  }
}

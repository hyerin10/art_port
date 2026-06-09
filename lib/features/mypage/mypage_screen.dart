import 'package:art_port/features/auth/widgets/login_required_gate.dart';
import 'package:art_port/features/mypage/mypage_view.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginRequiredGate(
      title: '로그인이 필요합니다',
      subtitle: '마이페이지를 이용하려면\n로그인 후 이용해 주세요.',
      child: const MyPageView(),
    );
  }
}

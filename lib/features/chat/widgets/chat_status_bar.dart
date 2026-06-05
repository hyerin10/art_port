import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 커미션 진행 상태 바 — 헤더 바로 아래 고정
class ChatStatusBar extends StatelessWidget {
  const ChatStatusBar({super.key, required this.statusLabel});

  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: AppColors.commissionStatusBar,
      alignment: Alignment.center,
      child: Text(
        statusLabel,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.25,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

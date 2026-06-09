import 'package:flutter/material.dart';

/// 커미션 진행 상태 바 — 헤더 바로 아래 고정
class ChatStatusBar extends StatelessWidget {
  const ChatStatusBar({
    super.key,
    required this.statusLabel,
    this.backgroundColor = const Color(0xFF2F80ED),
  });

  final String statusLabel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: backgroundColor,
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

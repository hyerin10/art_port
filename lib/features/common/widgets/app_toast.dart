import 'package:flutter/material.dart';

/// 화면 하단 중앙 토스트 스타일 안내
abstract final class AppToast {
  static void show(
    ScaffoldMessengerState messenger, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xE6000000),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.fromLTRB(48, 0, 48, 32),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: duration,
      ),
    );
  }
}

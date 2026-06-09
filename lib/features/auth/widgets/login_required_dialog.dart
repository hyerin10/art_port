import 'package:flutter/material.dart';

/// 비로그인 상태 안내 다이얼로그
Future<void> showLoginRequiredDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('로그인 필요'),
      content: const Text('로그인이 필요합니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}

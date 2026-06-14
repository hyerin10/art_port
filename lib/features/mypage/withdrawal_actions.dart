import 'package:art_port/features/mypage/withdrawal_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 출금 신청 화면 액션
abstract final class WithdrawalActions {
  static Future<void> submit(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(withdrawalProvider.notifier).submit();
    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('출금 신청이 완료되었습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }
}

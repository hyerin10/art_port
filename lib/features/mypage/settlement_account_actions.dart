import 'package:art_port/features/mypage/settlement_account_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 정산 계좌 관리 화면 액션
abstract final class SettlementAccountActions {
  static Future<void> verifyAccount(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(settlementAccountProvider.notifier).verifyAccount();
    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('계좌 인증이 완료되었습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> save(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(settlementAccountProvider.notifier).save();
    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('정산 계좌 정보가 저장되었습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }
}

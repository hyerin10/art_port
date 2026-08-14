import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 타입 설정 화면 액션 헬퍼
abstract final class CommissionTypeSettingsActions {
  static Future<void> saveAll(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(commissionTypeSettingsProvider.notifier).saveAll();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('커미션 타입 설정이 저장되었습니다.')),
      );
    } else {
      final error = ref.read(commissionTypeSettingsProvider).saveError;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: error ?? '저장에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  static Future<void> confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('타입 삭제'),
        content: Text('\'$name\' 타입을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(commissionTypeSettingsProvider.notifier).removeType(id);
    }
  }
}

import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 타입 폼 화면 액션 헬퍼
abstract final class CommissionTypeFormActions {
  static Future<void> pickSampleImage(
    BuildContext context,
    WidgetRef ref,
    String? editingTypeId,
    int index,
  ) async {
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '이미지 업로드는 아직 지원되지 않습니다.',
    );
  }

  static void submit(
    BuildContext context,
    WidgetRef ref,
    String? editingTypeId,
  ) {
    FocusScope.of(context).unfocus();
    final success = ref
        .read(commissionTypeFormProvider(editingTypeId).notifier)
        .submit();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    }
  }
}

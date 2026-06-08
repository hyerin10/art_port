import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/openslot/models/slot_model.dart';
import 'package:art_port/features/openslot/open_slot_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 슬롯 관리 화면 액션 헬퍼
abstract final class OpenSlotActions {
  static void openCreate(BuildContext context) {
    // TODO: 새 슬롯 등록 화면
  }

  static void openEdit(BuildContext context, String slotId) {
    // TODO: 슬롯 수정 화면
  }

  static Future<void> confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SlotModel slot,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('슬롯 삭제'),
        content: Text('\'${slot.title}\' 슬롯을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(mySlotsProvider.notifier).removeSlot(slot.id);
    }
  }

  static Future<void> reload(WidgetRef ref) async {
    await ref.read(mySlotsProvider.notifier).reload();
  }
}

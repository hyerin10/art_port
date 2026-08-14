import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/notice_settings_providers.dart';
import 'package:art_port/features/mypage/widgets/notice_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 공지사항 설정 화면 액션 헬퍼
abstract final class NoticeSettingsActions {
  static Future<void> save(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(noticeSettingsProvider.notifier).saveAll();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공지사항 설정이 저장되었습니다.')),
      );
    } else {
      final error = ref.read(noticeSettingsProvider).saveError;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: error ?? '저장에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  static Future<void> editPinnedNotice(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final state = ref.read(noticeSettingsProvider);
    final result = await PinnedNoticeFormDialog.show(
      context,
      existing: state.pinnedNotice,
    );

    if (result != null) {
      ref.read(noticeSettingsProvider.notifier).updatePinnedNotice(result);
    }
  }

  static Future<void> addNotice(BuildContext context, WidgetRef ref) async {
    final result = await NoticeFormDialog.show(context);
    if (result != null) {
      ref.read(noticeSettingsProvider.notifier).addGeneralNotice(result);
    }
  }

  static Future<void> editNotice(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final existing =
        ref.read(noticeSettingsProvider.notifier).findGeneralNotice(id);
    if (existing == null) return;

    final result = await NoticeFormDialog.show(context, existing: existing);
    if (result != null) {
      ref.read(noticeSettingsProvider.notifier).updateGeneralNotice(result);
    }
  }

  static Future<void> confirmDeleteNotice(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공지 삭제'),
        content: Text('\'$title\' 공지를 삭제하시겠습니까?'),
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
      ref.read(noticeSettingsProvider.notifier).removeGeneralNotice(id);
    }
  }
}

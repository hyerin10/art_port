import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:art_port/features/mypage/notice_settings_providers.dart';
import 'package:art_port/features/mypage/widgets/general_notice_card.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/notice_form_dialog.dart';
import 'package:art_port/features/mypage/widgets/notice_settings_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 공지사항 설정 메인 화면
class NoticeSettingsView extends ConsumerStatefulWidget {
  const NoticeSettingsView({super.key});

  @override
  ConsumerState<NoticeSettingsView> createState() => _NoticeSettingsViewState();
}

class _NoticeSettingsViewState extends ConsumerState<NoticeSettingsView> {
  final _statusMessageController = TextEditingController();

  @override
  void dispose() {
    _statusMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticeSettingsProvider);
    final notifier = ref.read(noticeSettingsProvider.notifier);

    if (_statusMessageController.text != state.statusMessage) {
      _statusMessageController.text = state.statusMessage;
    }

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      header: NoticeSettingsHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                _WorkStatusSection(
                  slotStatus: state.slotStatus,
                  statusMessageController: _statusMessageController,
                  onSlotStatusChanged: notifier.updateSlotStatus,
                  onStatusMessageChanged: notifier.updateStatusMessage,
                ),
                const SizedBox(height: 16),
                _PinnedNoticeSection(
                  notice: state.pinnedNotice,
                  onEdit: () => _editPinnedNotice(context, ref),
                ),
                const SizedBox(height: 20),
                _GeneralNoticesSection(
                  notices: state.generalNotices,
                  onAdd: () => _addNotice(context, ref),
                  onToggleActive: (id, value) {
                    final notice = notifier.findGeneralNotice(id);
                    if (notice != null && notice.isActive != value) {
                      notifier.toggleGeneralNoticeActive(id);
                    }
                  },
                  onEdit: (id) => _editNotice(context, ref, id),
                  onDelete: (id, title) =>
                      _confirmDeleteNotice(context, ref, id, title),
                ),
              ],
            ),
      footer: _SaveSettingsButton(
        isSaving: state.isSaving,
        onSave: () => _onSave(context, ref),
      ),
    );
  }

  Future<void> _onSave(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(noticeSettingsProvider.notifier).saveAll();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공지사항 설정이 저장되었습니다.')),
      );
    }
  }

  Future<void> _editPinnedNotice(BuildContext context, WidgetRef ref) async {
    final state = ref.read(noticeSettingsProvider);
    final result = await PinnedNoticeFormDialog.show(
      context,
      existing: state.pinnedNotice,
    );

    if (result != null) {
      ref.read(noticeSettingsProvider.notifier).updatePinnedNotice(result);
    }
  }

  Future<void> _addNotice(BuildContext context, WidgetRef ref) async {
    final result = await NoticeFormDialog.show(context);
    if (result != null) {
      ref.read(noticeSettingsProvider.notifier).addGeneralNotice(result);
    }
  }

  Future<void> _editNotice(
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

  Future<void> _confirmDeleteNotice(
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
              foregroundColor: const Color(0xFFEF4444),
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

// ─── 현재 작업 현황 섹션 ─────────────────────────────────────────────────────

class _WorkStatusSection extends StatelessWidget {
  const _WorkStatusSection({
    required this.slotStatus,
    required this.statusMessageController,
    required this.onSlotStatusChanged,
    required this.onStatusMessageChanged,
  });

  final WorkSlotStatus slotStatus;
  final TextEditingController statusMessageController;
  final ValueChanged<WorkSlotStatus> onSlotStatusChanged;
  final ValueChanged<String> onStatusMessageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '현재 작업 현황',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < WorkSlotStatus.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SlotStatusChip(
                    status: WorkSlotStatus.values[i],
                    isSelected: slotStatus == WorkSlotStatus.values[i],
                    onTap: () => onSlotStatusChanged(WorkSlotStatus.values[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '상태 메시지',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: statusMessageController,
            maxLength: NoticeSettingsState.maxStatusMessage,
            onChanged: onStatusMessageChanged,
            decoration: InputDecoration(
              hintText: '현재 대기 시간: 약 2주',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: AppColors.chipBackground,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotStatusChip extends StatelessWidget {
  const _SlotStatusChip({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final WorkSlotStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _dotColor {
    switch (status) {
      case WorkSlotStatus.open:
        return AppColors.onlineStatus;
      case WorkSlotStatus.closed:
        return const Color(0xFFEF4444);
      case WorkSlotStatus.resting:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.background : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1F2937)
                  : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 상단 고정 공지 섹션 ─────────────────────────────────────────────────────

class _PinnedNoticeSection extends StatelessWidget {
  const _PinnedNoticeSection({
    required this.notice,
    required this.onEdit,
  });

  final PinnedNotice notice;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.push_pin_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '상단 고정 공지',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.primary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            notice.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          for (final point in notice.bulletPoints) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                notice.formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 8),
              if (notice.isPublic)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '공개',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 일반 공지사항 섹션 ─────────────────────────────────────────────────────

class _GeneralNoticesSection extends StatelessWidget {
  const _GeneralNoticesSection({
    required this.notices,
    required this.onAdd,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final List<GeneralNotice> notices;
  final VoidCallback onAdd;
  final void Function(String id, bool value) onToggleActive;
  final void Function(String id) onEdit;
  final void Function(String id, String title) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '일반 공지사항',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    '+ 새 공지',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notices.isEmpty)
          const _EmptyNoticesState()
        else
          for (var i = 0; i < notices.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            GeneralNoticeCard(
              notice: notices[i],
              onToggleActive: (value) =>
                  onToggleActive(notices[i].id, value),
              onEdit: () => onEdit(notices[i].id),
              onDelete: () => onDelete(notices[i].id, notices[i].title),
            ),
          ],
      ],
    );
  }
}

class _EmptyNoticesState extends StatelessWidget {
  const _EmptyNoticesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 36,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            '등록된 공지사항이 없습니다',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 하단 저장 버튼 ─────────────────────────────────────────────────────────

class _SaveSettingsButton extends StatelessWidget {
  const _SaveSettingsButton({
    required this.isSaving,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '설정 저장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

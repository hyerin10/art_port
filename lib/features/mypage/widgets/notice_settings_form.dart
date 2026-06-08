import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:art_port/features/mypage/widgets/general_notices_section.dart';
import 'package:art_port/features/mypage/widgets/pinned_notice_section.dart';
import 'package:art_port/features/mypage/widgets/work_status_section.dart';
import 'package:flutter/material.dart';

/// 공지사항 설정 폼 본문
class NoticeSettingsForm extends StatelessWidget {
  const NoticeSettingsForm({
    super.key,
    required this.state,
    required this.statusMessageController,
    required this.onSlotStatusChanged,
    required this.onStatusMessageChanged,
    required this.onEditPinned,
    required this.onAddNotice,
    required this.onToggleActive,
    required this.onEditNotice,
    required this.onDeleteNotice,
  });

  final NoticeSettingsState state;
  final TextEditingController statusMessageController;
  final ValueChanged<WorkSlotStatus> onSlotStatusChanged;
  final ValueChanged<String> onStatusMessageChanged;
  final VoidCallback onEditPinned;
  final VoidCallback onAddNotice;
  final void Function(String id, bool value) onToggleActive;
  final void Function(String id) onEditNotice;
  final void Function(String id, String title) onDeleteNotice;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        WorkStatusSection(
          slotStatus: state.slotStatus,
          statusMessageController: statusMessageController,
          onSlotStatusChanged: onSlotStatusChanged,
          onStatusMessageChanged: onStatusMessageChanged,
        ),
        const SizedBox(height: 16),
        PinnedNoticeSection(
          notice: state.pinnedNotice,
          onEdit: onEditPinned,
        ),
        const SizedBox(height: 20),
        GeneralNoticesSection(
          notices: state.generalNotices,
          onAdd: onAddNotice,
          onToggleActive: onToggleActive,
          onEdit: onEditNotice,
          onDelete: onDeleteNotice,
        ),
      ],
    );
  }
}

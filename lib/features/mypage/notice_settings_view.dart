import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:art_port/features/mypage/notice_settings_actions.dart';
import 'package:art_port/features/mypage/notice_settings_providers.dart';
import 'package:art_port/features/mypage/widgets/mypage_save_footer_button.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/notice_settings_form.dart';
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
  var _initialized = false;

  @override
  void dispose() {
    _statusMessageController.dispose();
    super.dispose();
  }

  void _syncControllers(NoticeSettingsState state) {
    if (state.isLoaded && !_initialized) {
      _statusMessageController.text = state.statusMessage;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticeSettingsProvider);
    final notifier = ref.read(noticeSettingsProvider.notifier);
    _syncControllers(state);

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      header: NoticeSettingsHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: NoticeSettingsForm(
        state: state,
        statusMessageController: _statusMessageController,
        onSlotStatusChanged: notifier.updateSlotStatus,
        onStatusMessageChanged: notifier.updateStatusMessage,
        onEditPinned: () => NoticeSettingsActions.editPinnedNotice(context, ref),
        onAddNotice: () => NoticeSettingsActions.addNotice(context, ref),
        onToggleActive: (id, value) {
          final notice = notifier.findGeneralNotice(id);
          if (notice != null && notice.isActive != value) {
            notifier.toggleGeneralNoticeActive(id);
          }
        },
        onEditNotice: (id) => NoticeSettingsActions.editNotice(context, ref, id),
        onDeleteNotice: (id, title) =>
            NoticeSettingsActions.confirmDeleteNotice(context, ref, id, title),
      ),
      footer: MyPageSaveFooterButton(
        label: '설정 저장하기',
        borderRadius: 28,
        isSaving: state.isSaving,
        onPressed: () => NoticeSettingsActions.save(context, ref),
      ),
    );
  }
}

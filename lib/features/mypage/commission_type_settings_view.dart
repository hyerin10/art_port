import 'package:art_port/features/mypage/commission_type_form_screen.dart';
import 'package:art_port/features/mypage/commission_type_settings_actions.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:art_port/features/mypage/widgets/commission_type_add_button.dart';
import 'package:art_port/features/mypage/widgets/commission_type_card.dart';
import 'package:art_port/features/mypage/widgets/commission_type_empty_state.dart';
import 'package:art_port/features/mypage/widgets/commission_type_settings_header.dart';
import 'package:art_port/features/mypage/widgets/commission_type_settings_info_banner.dart';
import 'package:art_port/features/mypage/widgets/mypage_save_footer_button.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 타입 설정 메인 화면
class CommissionTypeSettingsView extends ConsumerWidget {
  const CommissionTypeSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commissionTypeSettingsProvider);
    final notifier = ref.read(commissionTypeSettingsProvider.notifier);

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      header: CommissionTypeSettingsHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          const CommissionTypeSettingsInfoBanner(),
          const SizedBox(height: 16),
          CommissionTypeAddButton(
            onTap: () => CommissionTypeFormScreen.openAdd(context),
          ),
          const SizedBox(height: 16),
          if (state.types.isEmpty)
            const CommissionTypeEmptyState()
          else
            ...[
              for (var i = 0; i < state.types.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                CommissionTypeCard(
                  type: state.types[i],
                  onToggleActive: (value) {
                    if (value != state.types[i].isActive) {
                      notifier.toggleActive(state.types[i].id);
                    }
                  },
                  onEdit: () => CommissionTypeFormScreen.openEdit(
                    context,
                    state.types[i].id,
                  ),
                  onDelete: () => CommissionTypeSettingsActions.confirmDelete(
                    context,
                    ref,
                    state.types[i].id,
                    state.types[i].name,
                  ),
                ),
              ],
            ],
        ],
      ),
      footer: MyPageSaveFooterButton(
        label: '모든 변경사항 저장',
        enabled: state.hasChanges && !state.isSaving,
        isSaving: state.isSaving,
        onPressed: () => CommissionTypeSettingsActions.saveAll(context, ref),
      ),
    );
  }
}

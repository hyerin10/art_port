import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/commission_type_form_actions.dart';
import 'package:art_port/features/mypage/commission_type_form_controllers.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:art_port/features/mypage/widgets/commission_type_form_body.dart';
import 'package:art_port/features/mypage/widgets/commission_type_form_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_save_footer_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 타입 추가/수정 폼 화면
class CommissionTypeFormView extends ConsumerStatefulWidget {
  const CommissionTypeFormView({
    super.key,
    this.editingTypeId,
  });

  final String? editingTypeId;

  @override
  ConsumerState<CommissionTypeFormView> createState() =>
      _CommissionTypeFormViewState();
}

class _CommissionTypeFormViewState extends ConsumerState<CommissionTypeFormView> {
  final _controllers = CommissionTypeFormControllers();

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(commissionTypeFormProvider(widget.editingTypeId));
    final notifier =
        ref.read(commissionTypeFormProvider(widget.editingTypeId).notifier);
    _controllers.syncFrom(form);

    final title = form.isEditMode ? '커미션 타입 수정' : '새 타입 추가';
    final submitLabel = form.isEditMode ? '수정 완료' : '타입 추가';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommissionTypeFormHeader(
            title: title,
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: CommissionTypeFormBody(
              form: form,
              controllers: _controllers,
              notifier: notifier,
              onPickSampleImage: (index) => CommissionTypeFormActions.pickSampleImage(
                context,
                ref,
                widget.editingTypeId,
                index,
              ),
            ),
          ),
          MyPageSaveFooterButton(
            label: submitLabel,
            enabled: form.isValid,
            borderRadius: 28,
            showShadow: false,
            onPressed: () => CommissionTypeFormActions.submit(
              context,
              ref,
              widget.editingTypeId,
            ),
          ),
        ],
      ),
    );
  }
}

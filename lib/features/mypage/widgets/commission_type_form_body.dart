import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/commission_type_form_controllers.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:art_port/features/mypage/widgets/commission_type_sample_upload_grid.dart';
import 'package:art_port/features/mypage/widgets/settings_multiline_text_field.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 커미션 타입 추가/수정 폼 본문
class CommissionTypeFormBody extends StatelessWidget {
  const CommissionTypeFormBody({
    super.key,
    required this.form,
    required this.controllers,
    required this.notifier,
    required this.onPickSampleImage,
  });

  final CommissionTypeFormState form;
  final CommissionTypeFormControllers controllers;
  final CommissionTypeFormNotifier notifier;
  final ValueChanged<int> onPickSampleImage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsTextField(
            controller: controllers.name,
            label: '타입 이름 *',
            hintText: '예: Full Body Character',
            onChanged: notifier.updateName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            controller: controllers.price,
            label: '시작 가격 (원) *',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: notifier.updateStartingPrice,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            controller: controllers.workPeriod,
            label: '예상 작업 기간',
            hintText: '7-14일',
            onChanged: notifier.updateWorkPeriod,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            controller: controllers.totalSlots,
            label: '총 슬롯 수',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: notifier.updateTotalSlots,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          const Text(
            '설명',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          SettingsMultilineTextField(
            controller: controllers.description,
            maxLength: 1000,
            currentLength: form.description.length,
            onChanged: notifier.updateDescription,
            minLines: 4,
          ),
          const SizedBox(height: 28),
          const Text(
            '샘플 이미지 (최대 3장)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CommissionTypeSampleUploadGrid(
            sampleImages: form.sampleImages,
            onUploadTap: onPickSampleImage,
            onRemove: notifier.removeSampleImage,
          ),
          const SizedBox(height: 8),
          const Text(
            '이 타입의 작업 샘플을 업로드해주세요',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:art_port/features/mypage/services/profile_image_picker.dart';
import 'package:art_port/features/mypage/widgets/commission_type_sample_upload_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _workPeriodController = TextEditingController();
  final _totalSlotsController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _workPeriodController.dispose();
    _totalSlotsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncControllers(CommissionTypeFormState form) {
    if (!_initialized) {
      _nameController.text = form.name;
      _priceController.text = form.startingPrice;
      _workPeriodController.text = form.workPeriod;
      _totalSlotsController.text = form.totalSlots;
      _descriptionController.text = form.description;
      _initialized = true;
    }
  }

  Future<void> _pickSampleImage(int index) async {
    final path = await showImageSourceBottomSheet(context, galleryOnly: true);
    if (path != null && mounted) {
      ref
          .read(commissionTypeFormProvider(widget.editingTypeId).notifier)
          .setSampleImage(index, path);
    }
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    final success = ref
        .read(commissionTypeFormProvider(widget.editingTypeId).notifier)
        .submit();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(commissionTypeFormProvider(widget.editingTypeId));
    final notifier =
        ref.read(commissionTypeFormProvider(widget.editingTypeId).notifier);
    _syncControllers(form);

    final title = form.isEditMode ? '커미션 타입 수정' : '새 타입 추가';
    final submitLabel = form.isEditMode ? '수정 완료' : '타입 추가';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _FormHeader(
            title: title,
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LabeledField(
                    label: '타입 이름',
                    required: true,
                    child: _FormTextField(
                      controller: _nameController,
                      hintText: '예: Full Body Character',
                      onChanged: notifier.updateName,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LabeledField(
                    label: '시작 가격 (원)',
                    required: true,
                    child: _FormTextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: notifier.updateStartingPrice,
                      textInputAction: TextInputAction.next,
                      prefix: const Text(
                        '₩',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LabeledField(
                    label: '예상 작업 기간',
                    child: _FormTextField(
                      controller: _workPeriodController,
                      hintText: '7-14일',
                      onChanged: notifier.updateWorkPeriod,
                      textInputAction: TextInputAction.next,
                      prefix: const Icon(
                        Icons.schedule_outlined,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LabeledField(
                    label: '총 슬롯 수',
                    child: _FormTextField(
                      controller: _totalSlotsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: notifier.updateTotalSlots,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LabeledField(
                    label: '설명',
                    child: _FormTextField(
                      controller: _descriptionController,
                      hintText: '포함 내용, 옵션, 파일 형식 등을 설명해주세요...',
                      onChanged: notifier.updateDescription,
                      minLines: 4,
                      maxLines: null,
                    ),
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
                    onUploadTap: _pickSampleImage,
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
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: form.isValid ? _onSubmit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFB0A8F8),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    submitLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded, size: 24),
                      color: AppColors.textPrimary,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.required = false,
  });

  final String label;
  final Widget child;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.prefix,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final int minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: minLines > 1 ? 16 : 16,
        ),
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: prefix,
              )
            : null,
        prefixIconConstraints: prefix != null
            ? const BoxConstraints(minWidth: 36, minHeight: 24)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/commission/commission_apply_providers.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/commission/widgets/commission_apply_header.dart';
import 'package:art_port/features/commission/widgets/commission_reference_upload_grid.dart';
import 'package:art_port/features/auth/widgets/login_required_dialog.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/services/profile_image_picker.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxRequestLength = 1000;
const _maxReferenceImages = 6;

class CommissionApplyView extends ConsumerStatefulWidget {
  const CommissionApplyView({super.key, required this.args});

  final CommissionApplyArgs args;

  @override
  ConsumerState<CommissionApplyView> createState() => _CommissionApplyViewState();
}

class _CommissionApplyViewState extends ConsumerState<CommissionApplyView> {
  final _requestController = TextEditingController();
  var _usagePurpose = CommissionUsagePurpose.personal;
  DateTime? _desiredDeadline;
  final List<String> _referenceImagePaths = [];
  var _isSubmitting = false;

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _requestController.text.trim().isNotEmpty && !_isSubmitting;

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickReferenceImages() async {
    final remaining = _maxReferenceImages - _referenceImagePaths.length;
    if (remaining <= 0) return;

    final paths = await ProfileImagePicker.pickMultipleFromGallery();
    if (!mounted || paths.isEmpty) return;

    setState(() {
      _referenceImagePaths.addAll(paths.take(remaining));
    });
  }

  void _removeReferenceImage(int index) {
    setState(() => _referenceImagePaths.removeAt(index));
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _desiredDeadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _desiredDeadline = picked);
    }
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    final isLoggedIn = ref.read(authProvider);
    if (!isLoggedIn) {
      await showLoginRequiredDialog(context);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final submission = CommissionApplySubmission(
      commissionId: widget.args.commissionId,
      commissionTitle: widget.args.commissionTitle,
      artistName: widget.args.artistName,
      selectedOption: widget.args.selectedOption,
      requestContent: _requestController.text.trim(),
      referenceImagePaths: List.unmodifiable(_referenceImagePaths),
      usagePurpose: _usagePurpose,
      desiredDeadline: _desiredDeadline,
      submittedAt: DateTime.now(),
    );

    ref.read(commissionApplySubmissionsProvider.notifier).submit(submission);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '커미션 신청서가 제출되었습니다.',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final requestLength = _requestController.text.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommissionApplyHeader(onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SelectedOptionCard(option: widget.args.selectedOption),
                  const SizedBox(height: 24),
                  _RequestContentField(
                    controller: _requestController,
                    length: requestLength,
                    maxLength: _maxRequestLength,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('참고 이미지 (최대 6장)'),
                  const SizedBox(height: 12),
                  CommissionReferenceUploadGrid(
                    imagePaths: _referenceImagePaths,
                    onUploadTap: _pickReferenceImages,
                    onRemove: _removeReferenceImage,
                    maxImages: _maxReferenceImages,
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('사용 용도'),
                  const SizedBox(height: 12),
                  _UsagePurposeSelector(
                    selected: _usagePurpose,
                    onSelected: (purpose) =>
                        setState(() => _usagePurpose = purpose),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('희망 마감일'),
                  const SizedBox(height: 12),
                  _DeadlineField(
                    valueLabel: _desiredDeadline != null
                        ? _formatDate(_desiredDeadline!)
                        : null,
                    onTap: _pickDeadline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _SubmitBar(
        enabled: _canSubmit,
        isSubmitting: _isSubmitting,
        onSubmit: _onSubmit,
      ),
    );
  }
}

class _SelectedOptionCard extends StatelessWidget {
  const _SelectedOptionCard({required this.option});

  final CommissionPriceOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '선택한 옵션',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.displayLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Text(
            option.priceLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    if (!required) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
          height: 1.2,
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.highlight,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestContentField extends StatelessWidget {
  const _RequestContentField({
    required this.controller,
    required this.length,
    required this.maxLength,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int length;
  final int maxLength;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('요청 내용', required: true),
        const SizedBox(height: 12),
        Stack(
          children: [
            TextField(
              controller: controller,
              onChanged: onChanged,
              maxLines: 6,
              maxLength: maxLength,
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.55,
              ),
              decoration: InputDecoration(
                hintText: '캐릭터, 포즈, 분위기 등을 자세히 설명해주세요...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.55,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 10,
              child: Text(
                '$length/$maxLength',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UsagePurposeSelector extends StatelessWidget {
  const _UsagePurposeSelector({
    required this.selected,
    required this.onSelected,
  });

  final CommissionUsagePurpose selected;
  final ValueChanged<CommissionUsagePurpose> onSelected;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < CommissionUsagePurpose.values.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _UsagePurposeChip(
                purpose: CommissionUsagePurpose.values[i],
                isSelected: selected == CommissionUsagePurpose.values[i],
                onTap: () => onSelected(CommissionUsagePurpose.values[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UsagePurposeChip extends StatelessWidget {
  const _UsagePurposeChip({
    required this.purpose,
    required this.isSelected,
    required this.onTap,
  });

  final CommissionUsagePurpose purpose;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Material(
        color: isSelected ? AppColors.primarySoft : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Center(
                child: Text(
                  purpose.displayLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({required this.valueLabel, required this.onTap});

  final String? valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = valueLabel != null;

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasValue ? valueLabel! : '연도-월-일',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasValue
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    height: 1.2,
                  ),
                ),
              ),
              const Icon(
                Icons.event_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.enabled,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: enabled && !isSubmitting ? onSubmit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.chipBackground,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '신청서 제출하기',
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

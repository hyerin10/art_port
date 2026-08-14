import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/inquiry_navigation.dart';
import 'package:art_port/features/mypage/inquiry_providers.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_save_footer_button.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/settings_multiline_text_field.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InquiryFormScreen extends StatelessWidget {
  const InquiryFormScreen({super.key});

  static void open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const InquiryFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _InquiryFormView();
  }
}

class _InquiryFormView extends ConsumerStatefulWidget {
  const _InquiryFormView();

  @override
  ConsumerState<_InquiryFormView> createState() => _InquiryFormViewState();
}

class _InquiryFormViewState extends ConsumerState<_InquiryFormView> {
  static const _maxContent = 1000;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  var _category = 'order';
  var _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _contentController.text.trim().isNotEmpty && !_isSubmitting;

  Future<void> _submit() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      AppToast.show(ScaffoldMessenger.of(context), message: '로그인이 필요합니다.');
      return;
    }

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '문의 내용을 입력해 주세요.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final title = _titleController.text.trim();
      final created = await ref.read(supportRepositoryProvider).create(
            userId: userId,
            category: _category,
            title: title.isEmpty ? null : title,
            content: content,
          );
      invalidateSupportQueries(ref);
      if (!mounted) return;
      InquiryNavigation.openCreated(context, created.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '문의 등록에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyPageSubScreenScaffold(
      header: InquiryHeader(
        title: '새 문의',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text(
            '문의 유형',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in SupportInquiryConstants.categories)
                ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category.id,
                  onSelected: (_) => setState(() => _category = category.id),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _category == category.id
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  side: BorderSide(
                    color: _category == category.id
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsTextField(
            controller: _titleController,
            label: '제목 (선택)',
            hintText: '문의 제목을 입력해 주세요',
          ),
          const SizedBox(height: 20),
          const Text(
            '문의 내용',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SettingsMultilineTextField(
            controller: _contentController,
            maxLength: _maxContent,
            currentLength: _contentController.text.length,
            minLines: 6,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      footer: MyPageSaveFooterButton(
        label: '문의 등록하기',
        enabled: _canSubmit,
        isSaving: _isSubmitting,
        onPressed: _submit,
      ),
    );
  }
}

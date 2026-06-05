import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:flutter/material.dart';

/// 일반 공지사항 작성/수정 다이얼로그
class NoticeFormDialog extends StatefulWidget {
  const NoticeFormDialog({
    super.key,
    this.existing,
  });

  final GeneralNotice? existing;

  bool get isEditMode => existing != null;

  static Future<GeneralNotice?> show(
    BuildContext context, {
    GeneralNotice? existing,
  }) {
    return showDialog<GeneralNotice>(
      context: context,
      builder: (_) => NoticeFormDialog(existing: existing),
    );
  }

  @override
  State<NoticeFormDialog> createState() => _NoticeFormDialogState();
}

class _NoticeFormDialogState extends State<NoticeFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    return title.isNotEmpty &&
        content.isNotEmpty &&
        title.length <= GeneralNotice.maxTitle &&
        content.length <= GeneralNotice.maxContent;
  }

  void _submit() {
    if (!_isValid) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (widget.isEditMode) {
      Navigator.pop(
        context,
        widget.existing!.copyWith(title: title, content: content),
      );
    } else {
      Navigator.pop(
        context,
        GeneralNotice(
          id: 'notice-${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          content: content,
          createdAt: DateTime.now(),
          isActive: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditMode ? '공지 수정' : '새 공지 작성'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '제목',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                maxLength: GeneralNotice.maxTitle,
                decoration: InputDecoration(
                  hintText: '공지 제목을 입력하세요',
                  filled: true,
                  fillColor: AppColors.chipBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              const Text(
                '내용',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _contentController,
                maxLength: GeneralNotice.maxContent,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '공지 내용을 입력하세요',
                  filled: true,
                  fillColor: AppColors.chipBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _isValid ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isEditMode ? '수정' : '추가'),
        ),
      ],
    );
  }
}

/// 상단 고정 공지 편집 다이얼로그
class PinnedNoticeFormDialog extends StatefulWidget {
  const PinnedNoticeFormDialog({
    super.key,
    required this.existing,
  });

  final PinnedNotice existing;

  static Future<PinnedNotice?> show(
    BuildContext context, {
    required PinnedNotice existing,
  }) {
    return showDialog<PinnedNotice>(
      context: context,
      builder: (_) => PinnedNoticeFormDialog(existing: existing),
    );
  }

  @override
  State<PinnedNoticeFormDialog> createState() => _PinnedNoticeFormDialogState();
}

class _PinnedNoticeFormDialogState extends State<PinnedNoticeFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bulletsController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existing.title);
    _bulletsController = TextEditingController(
      text: widget.existing.bulletPoints.join('\n'),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bulletsController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final title = _titleController.text.trim();
    final bullets = _parseBullets();
    return title.isNotEmpty &&
        title.length <= PinnedNotice.maxTitle &&
        bullets.isNotEmpty &&
        bullets.length <= PinnedNotice.maxBulletPoints;
  }

  List<String> _parseBullets() {
    return _bulletsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  void _submit() {
    if (!_isValid) return;

    Navigator.pop(
      context,
      widget.existing.copyWith(
        title: _titleController.text.trim(),
        bulletPoints: _parseBullets(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('상단 고정 공지 편집'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '제목',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                maxLength: PinnedNotice.maxTitle,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.chipBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              const Text(
                '항목 (한 줄에 하나씩)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bulletsController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '작업 기간: 기본 7-14일 소요',
                  filled: true,
                  fillColor: AppColors.chipBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _isValid ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

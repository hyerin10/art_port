import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/primary_pill_button.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/general_notice_card.dart';
import 'package:flutter/material.dart';

/// 일반 공지사항 섹션
class GeneralNoticesSection extends StatelessWidget {
  const GeneralNoticesSection({
    super.key,
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
            const Expanded(child: FormSectionTitle('일반 공지사항')),
            PrimaryPillButton(
              label: '+ 새 공지',
              fullWidth: false,
              elevation: 0,
              onTap: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (notices.isEmpty)
          const GeneralNoticesEmptyState()
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

/// 일반 공지사항 빈 상태
class GeneralNoticesEmptyState extends StatelessWidget {
  const GeneralNoticesEmptyState({super.key});

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

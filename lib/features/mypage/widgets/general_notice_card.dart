import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:flutter/material.dart';

/// 일반 공지사항 카드
class GeneralNoticeCard extends StatelessWidget {
  const GeneralNoticeCard({
    super.key,
    required this.notice,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final GeneralNotice notice;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final inactiveOpacity = notice.isActive ? 1.0 : 0.55;

    return Opacity(
      opacity: inactiveOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notice.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notice.formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: notice.isActive,
                    onChanged: onToggleActive,
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notice.preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _HalfActionButton(
                      icon: Icons.edit_outlined,
                      label: '수정',
                      backgroundColor: AppColors.chipBackground,
                      foregroundColor: AppColors.textPrimary,
                      onTap: onEdit,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HalfActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: '삭제',
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFEF4444),
                      onTap: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HalfActionButton extends StatelessWidget {
  const _HalfActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: foregroundColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

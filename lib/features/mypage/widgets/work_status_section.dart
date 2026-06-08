import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:flutter/material.dart';

/// 현재 작업 현황 섹션
class WorkStatusSection extends StatelessWidget {
  const WorkStatusSection({
    super.key,
    required this.slotStatus,
    required this.statusMessageController,
    required this.onSlotStatusChanged,
    required this.onStatusMessageChanged,
  });

  final WorkSlotStatus slotStatus;
  final TextEditingController statusMessageController;
  final ValueChanged<WorkSlotStatus> onSlotStatusChanged;
  final ValueChanged<String> onStatusMessageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '현재 작업 현황',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < WorkSlotStatus.values.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: SlotStatusChip(
                    status: WorkSlotStatus.values[i],
                    isSelected: slotStatus == WorkSlotStatus.values[i],
                    onTap: () => onSlotStatusChanged(WorkSlotStatus.values[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SettingsTextField(
            controller: statusMessageController,
            label: '상태 메시지',
            hintText: '현재 대기 시간: 약 2주',
            onChanged: onStatusMessageChanged,
          ),
        ],
      ),
    );
  }
}

/// 작업 슬롯 상태 단일 선택 칩
class SlotStatusChip extends StatelessWidget {
  const SlotStatusChip({
    super.key,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final WorkSlotStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _dotColor {
    switch (status) {
      case WorkSlotStatus.open:
        return AppColors.onlineStatus;
      case WorkSlotStatus.closed:
        return AppColors.error;
      case WorkSlotStatus.resting:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.background : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

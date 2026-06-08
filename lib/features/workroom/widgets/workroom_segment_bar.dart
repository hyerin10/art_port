import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';

/// 작업실 하위 탭 전환 (채팅 / 주문 현황)
class WorkroomSegmentBar extends StatelessWidget {
  const WorkroomSegmentBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final WorkroomSubTab selected;
  final ValueChanged<WorkroomSubTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: '채팅',
              icon: Icons.chat_bubble_outline_rounded,
              isSelected: selected == WorkroomSubTab.chats,
              onTap: () => onSelect(WorkroomSubTab.chats),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: '주문 현황',
              icon: Icons.inventory_2_outlined,
              isSelected: selected == WorkroomSubTab.orders,
              onTap: () => onSelect(WorkroomSubTab.orders),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? AppColors.textPrimary : AppColors.textMuted;
    final iconColor =
        isSelected ? AppColors.textPrimary : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

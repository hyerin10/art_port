import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 다중 선택 옵션 칩 목록
class SelectableOptionChips extends StatelessWidget {
  const SelectableOptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (_) => onToggle(option),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  selected.contains(option) ? Colors.white : AppColors.textPrimary,
            ),
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: selected.contains(option)
                  ? AppColors.primary
                  : AppColors.borderLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          ),
      ],
    );
  }
}

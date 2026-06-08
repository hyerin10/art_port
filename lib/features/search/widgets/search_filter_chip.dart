import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/widgets/search_dropdown_arrow_icon.dart';
import 'package:flutter/material.dart';

class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showDropdownArrow = false,
    this.leading,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showDropdownArrow;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? AppColors.primaryLight : AppColors.chipBackground;
    final fg = isActive ? AppColors.primary : AppColors.textPrimary;
    final arrowColor =
        isActive ? AppColors.primary : AppColors.textSecondary;
    final border = isActive
        ? Border.all(color: AppColors.primary.withValues(alpha: 0.35))
        : Border.all(color: Colors.transparent);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            leading != null ? 10 : 12,
            8,
            showDropdownArrow ? 8 : 12,
            8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1.2,
                ),
              ),
              if (showDropdownArrow) ...[
                const SizedBox(width: 2),
                SearchDropdownArrowIcon(color: arrowColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

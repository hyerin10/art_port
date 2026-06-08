import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/features/search/widgets/search_dropdown_arrow_icon.dart';
import 'package:flutter/material.dart';

class SearchResultsSummaryBar extends StatelessWidget {
  const SearchResultsSummaryBar({
    super.key,
    required this.count,
    required this.sort,
    required this.onSortTap,
  });

  final int count;
  final SearchSortOption sort;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '총 $count개의 커미션',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSortTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sort.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              const SearchDropdownArrowIcon(color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

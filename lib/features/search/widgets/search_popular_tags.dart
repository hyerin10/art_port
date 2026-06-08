import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/widgets/search_scroll_behavior.dart';
import 'package:flutter/material.dart';

class SearchPopularTags extends StatelessWidget {
  const SearchPopularTags({
    super.key,
    required this.tags,
    required this.selectedQuery,
    required this.onTagTap,
  });

  final List<String> tags;
  final String selectedQuery;
  final ValueChanged<String> onTagTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '연관 인기 태그',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ScrollConfiguration(
          behavior: const SearchScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < tags.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _PopularTagChip(
                    label: tags[i],
                    isSelected: selectedQuery == tags[i],
                    onTap: () => onTagTap(tags[i]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularTagChip extends StatelessWidget {
  const _PopularTagChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryLight : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  )
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

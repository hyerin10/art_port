import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:flutter/material.dart';

class SearchSortSheet extends StatelessWidget {
  const SearchSortSheet({
    super.key,
    required this.current,
    required this.onSelect,
  });

  final SearchSortOption current;
  final ValueChanged<SearchSortOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '정렬 기준',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          for (final option in SearchSortOption.values)
            SearchSortTile(
              option: option,
              current: current,
              onSelect: onSelect,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class SearchSortTile extends StatelessWidget {
  const SearchSortTile({
    super.key,
    required this.option,
    required this.current,
    required this.onSelect,
  });

  final SearchSortOption option;
  final SearchSortOption current;
  final ValueChanged<SearchSortOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = option == current;
    return ListTile(
      title: Text(
        option.label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
          : null,
      onTap: () => onSelect(option),
    );
  }
}

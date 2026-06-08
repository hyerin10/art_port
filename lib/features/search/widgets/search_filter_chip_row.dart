import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/search_filter_overlay.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/features/search/widgets/search_filter_chip.dart';
import 'package:art_port/features/search/widgets/search_filter_reset_button.dart';
import 'package:art_port/features/search/widgets/search_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchFilterChipRow extends ConsumerWidget {
  const SearchFilterChipRow({
    super.key,
    required this.filter,
    required this.overlay,
    required this.onReset,
    required this.onPriceTap,
    required this.onDeadlineTap,
    required this.onAgeTap,
  });

  final SearchFilterState filter;
  final SearchFilterOverlayController overlay;
  final VoidCallback onReset;
  final VoidCallback onPriceTap;
  final VoidCallback onDeadlineTap;
  final VoidCallback onAgeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchFilterProvider.notifier);
    final openFilter = overlay.openFilter;

    return ScrollConfiguration(
      behavior: const SearchScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SearchFilterResetButton(
              onTap: onReset,
              isActive: filter.hasActiveFilters,
            ),
            const SizedBox(width: 8),
            SearchFilterChip(
              label: '신청 가능',
              leading: const Icon(
                Icons.description_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              isActive: filter.availableOnly,
              onTap: notifier.toggleAvailableOnly,
            ),
            const SizedBox(width: 8),
            SearchFilterChip(
              label: '슬롯 남음',
              leading: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.onlineStatus,
                  shape: BoxShape.circle,
                ),
              ),
              isActive: filter.slotsRemainingOnly,
              onTap: notifier.toggleSlotsRemainingOnly,
            ),
            const SizedBox(width: 8),
            SearchFilterChip(
              key: overlay.priceChipKey,
              label: '가격',
              showDropdownArrow: true,
              isActive: filter.hasPriceFilter ||
                  openFilter == SearchFilterOverlayKind.price,
              onTap: onPriceTap,
            ),
            const SizedBox(width: 8),
            SearchFilterChip(
              key: overlay.deadlineChipKey,
              label: '마감 기한',
              showDropdownArrow: true,
              isActive: filter.hasDeadlineFilter ||
                  openFilter == SearchFilterOverlayKind.deadline,
              onTap: onDeadlineTap,
            ),
            const SizedBox(width: 8),
            SearchFilterChip(
              key: overlay.ageChipKey,
              label: '열람 가능 연령',
              showDropdownArrow: true,
              isActive: filter.hasAgeFilter ||
                  openFilter == SearchFilterOverlayKind.age,
              onTap: onAgeTap,
            ),
          ],
        ),
      ),
    );
  }
}

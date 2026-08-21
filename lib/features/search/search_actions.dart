import 'package:art_port/features/search/search_constants.dart';
import 'package:art_port/features/search/search_filter_overlay.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/features/search/widgets/filters/age_filter_popup.dart';
import 'package:art_port/features/search/widgets/filters/deadline_filter_popup.dart';
import 'package:art_port/features/search/widgets/filters/price_filter_popup.dart';
import 'package:art_port/features/search/widgets/search_sort_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 검색 화면 액션 헬퍼
abstract final class SearchActions {
  static void showSortSheet(
    BuildContext context,
    WidgetRef ref,
    SearchSortOption current, {
    VoidCallback? onBeforeShow,
  }) {
    onBeforeShow?.call();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SearchSortSheet(
        current: current,
        onSelect: (option) {
          ref.read(searchFilterProvider.notifier).setSort(option);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  static void applyTagSearch({
    required WidgetRef ref,
    required TextEditingController controller,
    required SearchFilterOverlayController overlay,
    required String tag,
  }) {
    final currentQuery = ref.read(searchFilterProvider).query;
    final isSelected = currentQuery == tag;

    if (isSelected) {
      controller.clear();
      ref.read(searchFilterProvider.notifier).setQuery('');
    } else {
      controller.text = tag;
      controller.selection = TextSelection.collapsed(offset: tag.length);
      ref.read(searchFilterProvider.notifier).setQuery(tag);
    }
    overlay.hide();
  }

  static void resetAllFilters({
    required WidgetRef ref,
    required TextEditingController controller,
    required SearchFilterOverlayController overlay,
  }) {
    overlay.hide();
    controller.clear();
    ref.read(searchFilterProvider.notifier).resetFilters();
  }

  static void togglePriceFilter({
    required BuildContext context,
    required WidgetRef ref,
    required SearchFilterOverlayController overlay,
  }) {
    final filter = ref.read(searchFilterProvider);
    overlay.toggle(
      context: context,
      kind: SearchFilterOverlayKind.price,
      anchorKey: overlay.priceChipKey,
      popupWidth: kSearchPricePopupWidth,
      popup: PriceFilterPopup(
        filter: filter,
        onClose: overlay.hide,
        onApply: (minMan, maxMan) {
          ref
              .read(searchFilterProvider.notifier)
              .setPriceRange(minMan: minMan, maxMan: maxMan);
          overlay.hide();
        },
        onPreset: (preset) {
          ref.read(searchFilterProvider.notifier).applyPricePreset(preset);
          overlay.hide();
        },
      ),
    );
  }

  static void toggleDeadlineFilter({
    required BuildContext context,
    required WidgetRef ref,
    required SearchFilterOverlayController overlay,
  }) {
    final filter = ref.read(searchFilterProvider);
    overlay.toggle(
      context: context,
      kind: SearchFilterOverlayKind.deadline,
      anchorKey: overlay.deadlineChipKey,
      popupWidth: kSearchDeadlinePopupWidth,
      popup: DeadlineFilterPopup(
        selected: filter.deadline,
        onSelect: (value) {
          ref.read(searchFilterProvider.notifier).setDeadline(value);
          overlay.hide();
        },
      ),
    );
  }

  static void toggleAgeFilter({
    required BuildContext context,
    required WidgetRef ref,
    required SearchFilterOverlayController overlay,
  }) {
    final filter = ref.read(searchFilterProvider);
    overlay.toggle(
      context: context,
      kind: SearchFilterOverlayKind.age,
      anchorKey: overlay.ageChipKey,
      popupWidth: kSearchAgePopupWidth,
      popup: AgeFilterPopup(
        selected: filter.ageRating,
        onSelect: (value) {
          ref.read(searchFilterProvider.notifier).setAgeRating(value);
          overlay.hide();
        },
      ),
    );
  }
}

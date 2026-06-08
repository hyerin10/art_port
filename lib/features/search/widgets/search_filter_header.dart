import 'package:art_port/features/search/search_actions.dart';
import 'package:art_port/features/search/search_filter_overlay.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/features/search/widgets/search_bar.dart';
import 'package:art_port/features/search/widgets/search_filter_chip_row.dart';
import 'package:art_port/features/search/widgets/search_popular_tags.dart';
import 'package:art_port/features/search/widgets/search_results_summary_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 검색바 · 인기 태그 · 필터 칩 · 결과 요약
class SearchFilterHeader extends ConsumerWidget {
  const SearchFilterHeader({
    super.key,
    required this.searchController,
    required this.overlay,
  });

  final TextEditingController searchController;
  final SearchFilterOverlayController overlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(searchResultCountProvider);
    final filter = ref.watch(searchFilterProvider);
    final popularTags = ref.watch(searchPopularTagsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchQueryBar(
            controller: searchController,
            onChanged: (value) =>
                ref.read(searchFilterProvider.notifier).setQuery(value),
          ),
          const SizedBox(height: 14),
          SearchPopularTags(
            tags: popularTags,
            selectedQuery: filter.query,
            onTagTap: (tag) => SearchActions.applyTagSearch(
              ref: ref,
              controller: searchController,
              overlay: overlay,
              tag: tag,
            ),
          ),
          const SizedBox(height: 12),
          SearchFilterChipRow(
            filter: filter,
            overlay: overlay,
            onReset: () => SearchActions.resetAllFilters(
              ref: ref,
              controller: searchController,
              overlay: overlay,
            ),
            onPriceTap: () => SearchActions.togglePriceFilter(
              context: context,
              ref: ref,
              overlay: overlay,
            ),
            onDeadlineTap: () => SearchActions.toggleDeadlineFilter(
              context: context,
              ref: ref,
              overlay: overlay,
            ),
            onAgeTap: () => SearchActions.toggleAgeFilter(
              context: context,
              ref: ref,
              overlay: overlay,
            ),
          ),
          const SizedBox(height: 14),
          SearchResultsSummaryBar(
            count: count,
            sort: filter.sort,
            onSortTap: () => SearchActions.showSortSheet(
              context,
              ref,
              filter.sort,
              onBeforeShow: overlay.hide,
            ),
          ),
        ],
      ),
    );
  }
}

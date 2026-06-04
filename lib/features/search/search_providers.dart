import 'package:art_port/features/search/models/search_commission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchSortOption {
  latest,
  popular,
  priceLow,
  priceHigh,
}

class SearchFilterState {
  const SearchFilterState({
    this.query = '',
    this.availableOnly = false,
    this.slotsRemainingOnly = false,
    this.sort = SearchSortOption.latest,
  });

  final String query;
  final bool availableOnly;
  final bool slotsRemainingOnly;
  final SearchSortOption sort;

  SearchFilterState copyWith({
    String? query,
    bool? availableOnly,
    bool? slotsRemainingOnly,
    SearchSortOption? sort,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      availableOnly: availableOnly ?? this.availableOnly,
      slotsRemainingOnly: slotsRemainingOnly ?? this.slotsRemainingOnly,
      sort: sort ?? this.sort,
    );
  }
}

final searchFilterProvider =
    NotifierProvider<SearchFilterNotifier, SearchFilterState>(
  SearchFilterNotifier.new,
);

class SearchFilterNotifier extends Notifier<SearchFilterState> {
  @override
  SearchFilterState build() => const SearchFilterState();

  void setQuery(String query) => state = state.copyWith(query: query);

  void toggleAvailableOnly() =>
      state = state.copyWith(availableOnly: !state.availableOnly);

  void toggleSlotsRemainingOnly() =>
      state = state.copyWith(slotsRemainingOnly: !state.slotsRemainingOnly);

  void setSort(SearchSortOption sort) => state = state.copyWith(sort: sort);
}

final searchLikedIdsProvider =
    NotifierProvider<SearchLikedIdsNotifier, Set<String>>(
  SearchLikedIdsNotifier.new,
);

class SearchLikedIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {
      for (final item in SearchDummyData.commissions)
        if (item.isLiked) item.id,
    };
  }

  void toggle(String id) {
    final next = Set<String>.from(state);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
  }

  bool isLiked(String id) => state.contains(id);
}

/// 전체 커미션 목록 (추후 API 교체)
final searchCommissionsProvider = Provider<List<SearchCommissionItem>>(
  (ref) => SearchDummyData.commissions,
);

/// 필터·검색어·정렬이 적용된 결과
final filteredSearchResultsProvider =
    Provider<List<SearchCommissionItem>>((ref) {
  final all = ref.watch(searchCommissionsProvider);
  final filter = ref.watch(searchFilterProvider);

  var results = all.where((item) {
    if (!item.matchesQuery(filter.query)) return false;
    if (filter.availableOnly && !item.isAvailable) return false;
    if (filter.slotsRemainingOnly && !item.hasSlot) return false;
    return true;
  }).toList();

  switch (filter.sort) {
    case SearchSortOption.latest:
      results.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    case SearchSortOption.popular:
      results.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    case SearchSortOption.priceLow:
      results.sort((a, b) => a.startPriceWon.compareTo(b.startPriceWon));
    case SearchSortOption.priceHigh:
      results.sort((a, b) => b.startPriceWon.compareTo(a.startPriceWon));
  }

  return results;
});

final searchResultCountProvider = Provider<int>(
  (ref) => ref.watch(filteredSearchResultsProvider).length,
);

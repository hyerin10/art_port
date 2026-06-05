import 'package:art_port/features/search/models/search_commission.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchSortOption {
  latest,
  popular,
  priceLow,
  priceHigh,
}

/// 가격 빠른 선택 프리셋 (`만` 단위)
class SearchPricePreset {
  const SearchPricePreset({
    required this.label,
    required this.minMan,
    required this.maxMan,
  });

  final String label;
  final int minMan;
  final int maxMan;

  static const presets = [
    SearchPricePreset(
      label: '1천 이상 5천 이하',
      minMan: 1,
      maxMan: 5,
    ),
    SearchPricePreset(
      label: '5천 이상 1만 이하',
      minMan: 5,
      maxMan: 10,
    ),
    SearchPricePreset(
      label: '1만 이상 3만 이하',
      minMan: 10,
      maxMan: 30,
    ),
    SearchPricePreset(
      label: '3만 이상 5만 이하',
      minMan: 30,
      maxMan: 50,
    ),
    SearchPricePreset(
      label: '5만 이상 10만 이하',
      minMan: 50,
      maxMan: 100,
    ),
  ];
}

class SearchFilterState {
  const SearchFilterState({
    this.query = '',
    this.availableOnly = false,
    this.slotsRemainingOnly = false,
    this.sort = SearchSortOption.latest,
    this.priceMinMan,
    this.priceMaxMan,
    this.deadline,
    this.ageRating,
  });

  final String query;
  final bool availableOnly;
  final bool slotsRemainingOnly;
  final SearchSortOption sort;
  final int? priceMinMan;
  final int? priceMaxMan;
  final SearchDeadlineFilter? deadline;
  final SearchAgeFilter? ageRating;

  bool get hasPriceFilter => priceMinMan != null || priceMaxMan != null;
  bool get hasDeadlineFilter => deadline != null;
  bool get hasAgeFilter => ageRating != null;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      availableOnly ||
      slotsRemainingOnly ||
      hasPriceFilter ||
      hasDeadlineFilter ||
      hasAgeFilter ||
      sort != SearchSortOption.latest;

  SearchFilterState copyWith({
    String? query,
    bool? availableOnly,
    bool? slotsRemainingOnly,
    SearchSortOption? sort,
    int? priceMinMan,
    int? priceMaxMan,
    bool clearPriceMin = false,
    bool clearPriceMax = false,
    SearchDeadlineFilter? deadline,
    bool clearDeadline = false,
    SearchAgeFilter? ageRating,
    bool clearAgeRating = false,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      availableOnly: availableOnly ?? this.availableOnly,
      slotsRemainingOnly: slotsRemainingOnly ?? this.slotsRemainingOnly,
      sort: sort ?? this.sort,
      priceMinMan: clearPriceMin ? null : (priceMinMan ?? this.priceMinMan),
      priceMaxMan: clearPriceMax ? null : (priceMaxMan ?? this.priceMaxMan),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      ageRating: clearAgeRating ? null : (ageRating ?? this.ageRating),
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

  void setPriceRange({int? minMan, int? maxMan}) {
    state = state.copyWith(
      priceMinMan: minMan,
      priceMaxMan: maxMan,
      clearPriceMin: minMan == null,
      clearPriceMax: maxMan == null,
    );
  }

  void applyPricePreset(SearchPricePreset preset) {
    state = state.copyWith(
      priceMinMan: preset.minMan,
      priceMaxMan: preset.maxMan,
    );
  }

  void setDeadline(SearchDeadlineFilter? value) {
    if (value == null) {
      state = state.copyWith(clearDeadline: true);
    } else {
      state = state.copyWith(deadline: value);
    }
  }

  void setAgeRating(SearchAgeFilter? value) {
    if (value == null) {
      state = state.copyWith(clearAgeRating: true);
    } else {
      state = state.copyWith(ageRating: value);
    }
  }

  /// 검색어·칩 필터·정렬을 기본값으로 되돌린다.
  void resetFilters() => state = const SearchFilterState();
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

/// 연관 인기 태그 (추후 API·검색어 기반 동적 노출)
final searchPopularTagsProvider = Provider<List<String>>(
  (ref) => SearchPopularTags.labels,
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
    if (filter.hasPriceFilter &&
        !item.matchesPriceRange(
          minMan: filter.priceMinMan,
          maxMan: filter.priceMaxMan,
        )) {
      return false;
    }
    if (filter.deadline != null &&
        !item.matchesDeadline(filter.deadline!)) {
      return false;
    }
    if (filter.ageRating != null && !item.matchesAge(filter.ageRating!)) {
      return false;
    }
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

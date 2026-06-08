import 'package:art_port/features/search/search_filter_overlay.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/features/search/widgets/search_empty_state.dart';
import 'package:art_port/features/search/widgets/search_filter_header.dart';
import 'package:art_port/features/search/widgets/search_results_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 검색(Search) 탭 — 동적 필터 피드
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  late final TextEditingController _searchController;
  late final SearchFilterOverlayController _overlay;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _overlay = SearchFilterOverlayController(onChanged: () => setState(() {}));
  }

  @override
  void dispose() {
    _overlay.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(filteredSearchResultsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchFilterHeader(
          searchController: _searchController,
          overlay: _overlay,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: results.isEmpty
              ? const SearchEmptyState()
              : SearchResultsGrid(results: results),
        ),
      ],
    );
  }
}

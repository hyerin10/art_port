import 'package:art_port/features/commission/widgets/commission_grid_card.dart';
import 'package:art_port/features/search/models/search_commission.dart';
import 'package:art_port/features/search/widgets/search_scroll_behavior.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResultsGrid extends ConsumerWidget {
  const SearchResultsGrid({super.key, required this.results});

  final List<SearchCommissionItem> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(likedCommissionIdsProvider);

    return ScrollConfiguration(
      behavior: const SearchScrollBehavior(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          return CommissionGridCard(
            data: CommissionCardDisplayData.fromSearch(item),
            isLiked: likedIds.contains(item.id),
          );
        },
      ),
    );
  }
}

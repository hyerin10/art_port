import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/models/search_commission.dart';
import 'package:art_port/features/search/search_providers.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(filteredSearchResultsProvider);
    final count = ref.watch(searchResultCountProvider);
    final filter = ref.watch(searchFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(
                controller: _searchController,
                onChanged: (value) =>
                    ref.read(searchFilterProvider.notifier).setQuery(value),
              ),
              const SizedBox(height: 12),
              _FilterChipRow(filter: filter),
              const SizedBox(height: 14),
              _ResultsSummaryBar(
                count: count,
                sort: filter.sort,
                onSortTap: () => _showSortMenu(context, filter.sort),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: results.isEmpty
              ? const _SearchEmptyState()
              : ScrollConfiguration(
                  behavior: const _SearchScrollBehavior(),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return _SearchCommissionCard(item: results[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showSortMenu(BuildContext context, SearchSortOption current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
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
              _SortTile(
                label: '최신순',
                option: SearchSortOption.latest,
                current: current,
                onSelect: _selectSort,
              ),
              _SortTile(
                label: '인기순',
                option: SearchSortOption.popular,
                current: current,
                onSelect: _selectSort,
              ),
              _SortTile(
                label: '가격 낮은순',
                option: SearchSortOption.priceLow,
                current: current,
                onSelect: _selectSort,
              ),
              _SortTile(
                label: '가격 높은순',
                option: SearchSortOption.priceHigh,
                current: current,
                onSelect: _selectSort,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _selectSort(SearchSortOption option) {
    ref.read(searchFilterProvider.notifier).setSort(option);
    Navigator.of(context).pop();
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.label,
    required this.option,
    required this.current,
    required this.onSelect,
  });

  final String label;
  final SearchSortOption option;
  final SearchSortOption current;
  final ValueChanged<SearchSortOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = option == current;
    return ListTile(
      title: Text(
        label,
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

class _SearchScrollBehavior extends ScrollBehavior {
  const _SearchScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ─── Search Bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '태그, 작가명, 키워드로 검색',
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 22,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.chipBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────

class _FilterChipRow extends ConsumerWidget {
  const _FilterChipRow({required this.filter});

  final SearchFilterState filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchFilterProvider.notifier);

    return ScrollConfiguration(
      behavior: const _SearchScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: '📄 신청 가능',
              isActive: filter.availableOnly,
              onTap: notifier.toggleAvailableOnly,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: '🟢 슬롯 남음',
              isActive: filter.slotsRemainingOnly,
              onTap: notifier.toggleSlotsRemainingOnly,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: '가격',
              showDropdownArrow: true,
              isActive: filter.sort == SearchSortOption.priceLow ||
                  filter.sort == SearchSortOption.priceHigh,
              onTap: () {
                final next = filter.sort == SearchSortOption.priceLow
                    ? SearchSortOption.priceHigh
                    : SearchSortOption.priceLow;
                notifier.setSort(next);
              },
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: '마감 기한',
              showDropdownArrow: true,
              isActive: false,
              onTap: () {
                // TODO: 마감 기한 필터 바텀시트
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showDropdownArrow = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showDropdownArrow;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? AppColors.primaryLight : AppColors.chipBackground;
    final fg = isActive ? AppColors.primary : AppColors.textPrimary;
    final arrowColor =
        isActive ? AppColors.primary : AppColors.textSecondary;
    final border = isActive
        ? Border.all(color: AppColors.primary.withValues(alpha: 0.35))
        : Border.all(color: Colors.transparent);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            12,
            8,
            showDropdownArrow ? 8 : 12,
            8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1.2,
                ),
              ),
              if (showDropdownArrow) ...[
                const SizedBox(width: 2),
                _DropdownArrowIcon(color: arrowColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 필터·정렬 드롭다운용 얇은 하향 화살표
class _DropdownArrowIcon extends StatelessWidget {
  const _DropdownArrowIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.expand_more_rounded,
      size: 18,
      color: color,
    );
  }
}

// ─── Summary Bar ──────────────────────────────────────────────────────────────

class _ResultsSummaryBar extends StatelessWidget {
  const _ResultsSummaryBar({
    required this.count,
    required this.sort,
    required this.onSortTap,
  });

  final int count;
  final SearchSortOption sort;
  final VoidCallback onSortTap;

  static String _sortLabel(SearchSortOption sort) {
    return switch (sort) {
      SearchSortOption.latest => '최신순',
      SearchSortOption.popular => '인기순',
      SearchSortOption.priceLow => '가격 낮은순',
      SearchSortOption.priceHigh => '가격 높은순',
    };
  }

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
                _sortLabel(sort),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              const _DropdownArrowIcon(color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Commission Card ──────────────────────────────────────────────────────────

class _SearchCommissionCard extends ConsumerWidget {
  const _SearchCommissionCard({required this.item});

  final SearchCommissionItem item;

  static const int _maxVisibleTags = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(searchLikedIdsProvider);
    final isLiked = likedIds.contains(item.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.primarySoft,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                if (item.hasSlot)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.onlineStatus,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '슬롯 있음',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _LikeButton(
                    isLiked: isLiked,
                    onTap: () => ref
                        .read(searchLikedIdsProvider.notifier)
                        .toggle(item.id),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.chipBackground,
                    backgroundImage: NetworkImage(item.artistAvatarUrl),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              _TagRow(tags: item.tags),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    item.priceLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.likeCountLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final visible = tags.take(_SearchCommissionCard._maxVisibleTags).toList();
    final extra = tags.length - visible.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final tag in visible) _TagChip(label: tag),
        if (extra > 0) _TagChip(label: '+$extra'),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.1,
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.isLiked,
    required this.onTap,
  });

  final bool isLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: isLiked ? AppColors.primary : Colors.white,
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '조건에 맞는 커미션이 없습니다.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

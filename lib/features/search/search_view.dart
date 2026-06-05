import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/commission/commission_detail_screen.dart';
import 'package:art_port/features/search/models/search_commission.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 드롭다운 필터 팝업 — 칩 하단 간격 · 화면 가장자리 여백
const double _kFilterPopupGapY = 8;
const double _kFilterPopupEdgeInset = 8;

/// 우측 드롭다운 칩(가격·마감·연령) 팝업 너비
const double _kPricePopupWidth = 280;
const double _kDeadlinePopupWidth = 200;
const double _kAgePopupWidth = 220;

/// 검색(Search) 탭 — 동적 필터 피드
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

enum _FilterOverlayKind { price, deadline, age }

class _SearchViewState extends ConsumerState<SearchView> {
  late final TextEditingController _searchController;

  final GlobalKey _priceChipKey = GlobalKey();
  final GlobalKey _deadlineChipKey = GlobalKey();
  final GlobalKey _ageChipKey = GlobalKey();

  OverlayEntry? _filterOverlay;
  _FilterOverlayKind? _openFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _removeFilterOverlay();
    _searchController.dispose();
    super.dispose();
  }

  void _removeFilterOverlay() {
    _filterOverlay?.remove();
    _filterOverlay = null;
    _openFilter = null;
  }

  /// 칩 [bottomRight] ↔ 팝업 [topRight] 우측 정렬 (가로 스크롤 좌표 보정)
  ({double left, double top})? _popupPositionForAnchor({
    required GlobalKey anchorKey,
    required double popupWidth,
    required double screenWidth,
  }) {
    final anchorBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (anchorBox == null || !anchorBox.hasSize) return null;

    final origin = anchorBox.localToGlobal(Offset.zero);
    final size = anchorBox.size;

    final top = origin.dy + size.height + _kFilterPopupGapY;
    var left = origin.dx + size.width - popupWidth;
    left = left.clamp(
      _kFilterPopupEdgeInset,
      screenWidth - popupWidth - _kFilterPopupEdgeInset,
    );

    return (left: left, top: top);
  }

  void _toggleFilterOverlay({
    required _FilterOverlayKind kind,
    required GlobalKey anchorKey,
    required Widget popup,
    required double popupWidth,
  }) {
    if (_openFilter == kind) {
      _removeFilterOverlay();
      return;
    }
    _removeFilterOverlay();
    _openFilter = kind;

    _filterOverlay = OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;
        final position = _popupPositionForAnchor(
          anchorKey: anchorKey,
          popupWidth: popupWidth,
          screenWidth: screenWidth,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeFilterOverlay,
                behavior: HitTestBehavior.translucent,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            if (position != null)
              Positioned(
                left: position.left,
                top: position.top,
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Material(
                    color: Colors.transparent,
                    child: popup,
                  ),
                ),
              ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_filterOverlay!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterOverlay?.markNeedsBuild();
    });
  }

  void _applyTagSearch(String tag) {
    _searchController.text = tag;
    _searchController.selection = TextSelection.collapsed(offset: tag.length);
    ref.read(searchFilterProvider.notifier).setQuery(tag);
    _removeFilterOverlay();
  }

  void _resetAllFilters() {
    _removeFilterOverlay();
    _searchController.clear();
    ref.read(searchFilterProvider.notifier).resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(filteredSearchResultsProvider);
    final count = ref.watch(searchResultCountProvider);
    final filter = ref.watch(searchFilterProvider);
    final popularTags = ref.watch(searchPopularTagsProvider);

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
              const SizedBox(height: 14),
              _RelatedPopularTags(
                tags: popularTags,
                selectedQuery: filter.query,
                onTagTap: _applyTagSearch,
              ),
              const SizedBox(height: 12),
              _FilterChipRow(
                filter: filter,
                priceChipKey: _priceChipKey,
                deadlineChipKey: _deadlineChipKey,
                ageChipKey: _ageChipKey,
                openFilter: _openFilter,
                onReset: _resetAllFilters,
                onPriceTap: () => _toggleFilterOverlay(
                  kind: _FilterOverlayKind.price,
                  anchorKey: _priceChipKey,
                  popupWidth: _kPricePopupWidth,
                  popup: _PriceFilterPopup(
                    filter: filter,
                    onClose: _removeFilterOverlay,
                    onApply: (minMan, maxMan) {
                      ref
                          .read(searchFilterProvider.notifier)
                          .setPriceRange(minMan: minMan, maxMan: maxMan);
                      _removeFilterOverlay();
                    },
                    onPreset: (preset) {
                      ref
                          .read(searchFilterProvider.notifier)
                          .applyPricePreset(preset);
                      _removeFilterOverlay();
                    },
                  ),
                ),
                onDeadlineTap: () => _toggleFilterOverlay(
                  kind: _FilterOverlayKind.deadline,
                  anchorKey: _deadlineChipKey,
                  popupWidth: _kDeadlinePopupWidth,
                  popup: _DeadlineFilterPopup(
                    selected: filter.deadline,
                    onSelect: (value) {
                      ref
                          .read(searchFilterProvider.notifier)
                          .setDeadline(value);
                      _removeFilterOverlay();
                    },
                  ),
                ),
                onAgeTap: () => _toggleFilterOverlay(
                  kind: _FilterOverlayKind.age,
                  anchorKey: _ageChipKey,
                  popupWidth: _kAgePopupWidth,
                  popup: _AgeFilterPopup(
                    selected: filter.ageRating,
                    onSelect: (value) {
                      ref
                          .read(searchFilterProvider.notifier)
                          .setAgeRating(value);
                      _removeFilterOverlay();
                    },
                  ),
                ),
              ),
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
    _removeFilterOverlay();
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

// ─── 연관 인기 태그 ───────────────────────────────────────────────────────────

class _RelatedPopularTags extends StatelessWidget {
  const _RelatedPopularTags({
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
          behavior: const _SearchScrollBehavior(),
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

// ─── Sort tile ────────────────────────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
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
  const _FilterChipRow({
    required this.filter,
    required this.priceChipKey,
    required this.deadlineChipKey,
    required this.ageChipKey,
    required this.openFilter,
    required this.onReset,
    required this.onPriceTap,
    required this.onDeadlineTap,
    required this.onAgeTap,
  });

  final SearchFilterState filter;
  final GlobalKey priceChipKey;
  final GlobalKey deadlineChipKey;
  final GlobalKey ageChipKey;
  final _FilterOverlayKind? openFilter;
  final VoidCallback onReset;
  final VoidCallback onPriceTap;
  final VoidCallback onDeadlineTap;
  final VoidCallback onAgeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(searchFilterProvider.notifier);

    return ScrollConfiguration(
      behavior: const _SearchScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterResetButton(
              onTap: onReset,
              isActive: filter.hasActiveFilters,
            ),
            const SizedBox(width: 8),
            _FilterChip(
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
            _FilterChip(
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
            _FilterChip(
              key: priceChipKey,
              label: '가격',
              showDropdownArrow: true,
              isActive: filter.hasPriceFilter ||
                  openFilter == _FilterOverlayKind.price,
              onTap: onPriceTap,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              key: deadlineChipKey,
              label: '마감 기한',
              showDropdownArrow: true,
              isActive: filter.hasDeadlineFilter ||
                  openFilter == _FilterOverlayKind.deadline,
              onTap: onDeadlineTap,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              key: ageChipKey,
              label: '열람 가능 연령',
              showDropdownArrow: true,
              isActive: filter.hasAgeFilter ||
                  openFilter == _FilterOverlayKind.age,
              onTap: onAgeTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// 필터 칩 행 맨 앞 — 전체 필터 초기화
class _FilterResetButton extends StatelessWidget {
  const _FilterResetButton({
    required this.onTap,
    required this.isActive,
  });

  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isActive ? AppColors.primary : AppColors.textSecondary;

    return Tooltip(
      message: '필터 초기화',
      child: Material(
        color: isActive ? AppColors.primaryLight : AppColors.chipBackground,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.showDropdownArrow = false,
    this.leading,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool showDropdownArrow;
  final Widget? leading;

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
            leading != null ? 10 : 12,
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
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 6),
              ],
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

// ─── Filter popup shell ───────────────────────────────────────────────────────

class _FilterPopupShell extends StatelessWidget {
  const _FilterPopupShell({
    required this.child,
    required this.width,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;

  static BoxDecoration decoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: decoration(),
      child: child,
    );
  }
}

// ─── 가격 필터 팝업 ───────────────────────────────────────────────────────────

class _PriceFilterPopup extends StatefulWidget {
  const _PriceFilterPopup({
    required this.filter,
    required this.onClose,
    required this.onApply,
    required this.onPreset,
  });

  final SearchFilterState filter;
  final VoidCallback onClose;
  final void Function(int? minMan, int? maxMan) onApply;
  final ValueChanged<SearchPricePreset> onPreset;

  @override
  State<_PriceFilterPopup> createState() => _PriceFilterPopupState();
}

class _PriceFilterPopupState extends State<_PriceFilterPopup> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: '${widget.filter.priceMinMan ?? 0}',
    );
    _maxController = TextEditingController(
      text: widget.filter.priceMaxMan != null
          ? '${widget.filter.priceMaxMan}'
          : '∞',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  int? _parseMan(String text, {required bool isMax}) {
    final trimmed = text.trim();
    if (isMax && (trimmed.isEmpty || trimmed == '∞')) return null;
    return int.tryParse(trimmed);
  }

  void _submitCustom() {
    final min = _parseMan(_minController.text, isMax: false) ?? 0;
    final max = _parseMan(_maxController.text, isMax: true);
    widget.onApply(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return _FilterPopupShell(
      width: _kPricePopupWidth,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _PriceManField(controller: _minController)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '만 ~',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: _PriceManField(controller: _maxController)),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '만',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _submitCustom,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '선택',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final preset in SearchPricePreset.presets)
            _FilterListTile(
              label: preset.label,
              onTap: () => widget.onPreset(preset),
            ),
        ],
      ),
    );
  }
}

class _PriceManField extends StatelessWidget {
  const _PriceManField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9∞]')),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.chipBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

// ─── 마감 기한 필터 팝업 ─────────────────────────────────────────────────────

class _DeadlineFilterPopup extends StatelessWidget {
  const _DeadlineFilterPopup({
    required this.selected,
    required this.onSelect,
  });

  final SearchDeadlineFilter? selected;
  final ValueChanged<SearchDeadlineFilter> onSelect;

  static const _options = [
    (SearchDeadlineFilter.sameDay, '당일 마감'),
    (SearchDeadlineFilter.within7, '7일 이내'),
    (SearchDeadlineFilter.within14, '14일 이내'),
    (SearchDeadlineFilter.over14, '14일 이상'),
  ];

  @override
  Widget build(BuildContext context) {
    return _FilterPopupShell(
      width: _kDeadlinePopupWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in _options)
            _FilterListTile(
              label: label,
              isSelected: selected == value,
              onTap: () => onSelect(value),
            ),
        ],
      ),
    );
  }
}

// ─── 열람 가능 연령 필터 팝업 ───────────────────────────────────────────────

class _AgeFilterPopup extends StatelessWidget {
  const _AgeFilterPopup({
    required this.selected,
    required this.onSelect,
  });

  final SearchAgeFilter? selected;
  final ValueChanged<SearchAgeFilter> onSelect;

  static const _options = [
    (SearchAgeFilter.allAges, '전체이용가'),
    (SearchAgeFilter.adultNoGore, '성인 (유혈 제외)'),
    (SearchAgeFilter.adultWithGore, '성인 (유혈 포함)'),
  ];

  @override
  Widget build(BuildContext context) {
    return _FilterPopupShell(
      width: _kAgePopupWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in _options)
            _FilterListTile(
              label: label,
              isSelected: selected == value,
              onTap: () => onSelect(value),
            ),
        ],
      ),
    );
  }
}

class _FilterListTile extends StatelessWidget {
  const _FilterListTile({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
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
    final likedIds = ref.watch(likedCommissionIdsProvider);
    final isLiked = likedIds.contains(item.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CommissionDetailScreen.open(
          context,
          commissionId: item.id,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
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
                            .read(likedCommissionIdsProvider.notifier)
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
        ),
      ),
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

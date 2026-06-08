import 'package:art_port/features/search/models/search_commission.dart';
import 'package:art_port/features/search/search_constants.dart';
import 'package:art_port/features/search/widgets/filters/filter_list_tile.dart';
import 'package:art_port/features/search/widgets/filters/filter_popup_shell.dart';
import 'package:flutter/material.dart';

class AgeFilterPopup extends StatelessWidget {
  const AgeFilterPopup({
    super.key,
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
    return FilterPopupShell(
      width: kSearchAgePopupWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in _options)
            FilterListTile(
              label: label,
              isSelected: selected == value,
              onTap: () => onSelect(value),
            ),
        ],
      ),
    );
  }
}

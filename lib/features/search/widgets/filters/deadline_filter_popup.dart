import 'package:art_port/features/search/models/search_commission.dart';
import 'package:art_port/features/search/search_constants.dart';
import 'package:art_port/features/search/widgets/filters/filter_list_tile.dart';
import 'package:art_port/features/search/widgets/filters/filter_popup_shell.dart';
import 'package:flutter/material.dart';

class DeadlineFilterPopup extends StatelessWidget {
  const DeadlineFilterPopup({
    super.key,
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
    return FilterPopupShell(
      width: kSearchDeadlinePopupWidth,
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

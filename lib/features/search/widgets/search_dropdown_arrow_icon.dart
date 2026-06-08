import 'package:flutter/material.dart';

class SearchDropdownArrowIcon extends StatelessWidget {
  const SearchDropdownArrowIcon({super.key, required this.color});

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

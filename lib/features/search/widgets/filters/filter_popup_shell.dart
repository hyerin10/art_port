import 'package:flutter/material.dart';

class FilterPopupShell extends StatelessWidget {
  const FilterPopupShell({
    super.key,
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

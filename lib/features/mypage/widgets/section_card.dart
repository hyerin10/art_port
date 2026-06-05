import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 섹션 제목 + 라운드 카드 컨테이너
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _buildChildrenWithDividers(children),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(List<Widget> items) {
    if (items.isEmpty) return items;

    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight,
            indent: 64,
          ),
        );
      }
    }
    return result;
  }
}

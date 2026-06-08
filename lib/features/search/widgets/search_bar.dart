import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SearchQueryBar extends StatelessWidget {
  const SearchQueryBar({
    super.key,
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

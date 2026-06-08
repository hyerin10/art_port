import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 글자 수 표시가 있는 멀티라인 입력 필드
class SettingsMultilineTextField extends StatelessWidget {
  const SettingsMultilineTextField({
    super.key,
    required this.controller,
    required this.maxLength,
    required this.currentLength,
    required this.onChanged,
    this.minLines = 4,
  });

  final TextEditingController controller;
  final int maxLength;
  final int currentLength;
  final ValueChanged<String> onChanged;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: null,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.chipBackground,
            contentPadding: const EdgeInsets.all(16),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$currentLength/$maxLength',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

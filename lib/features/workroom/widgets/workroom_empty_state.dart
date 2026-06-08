import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 작업실 목록이 비어 있을 때 표시
class WorkroomEmptyState extends StatelessWidget {
  const WorkroomEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

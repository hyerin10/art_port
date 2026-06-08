import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 작업실 상단 타이틀 + 세그먼트 바
class WorkroomHeader extends StatelessWidget {
  const WorkroomHeader({super.key, required this.segmentBar});

  final Widget segmentBar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '작업실',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          segmentBar,
        ],
      ),
    );
  }
}

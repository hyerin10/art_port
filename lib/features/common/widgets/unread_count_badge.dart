import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 읽지 않은 메시지 수 뱃지
class UnreadCountBadge extends StatelessWidget {
  const UnreadCountBadge({
    super.key,
    required this.count,
    this.backgroundColor = AppColors.notificationBadge,
  });

  final int count;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

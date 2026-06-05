import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 커미션 상세 상단 앱바 — 뒤로가기 + 타이틀 + 좋아요/공유
class CommissionDetailHeader extends StatelessWidget {
  const CommissionDetailHeader({
    super.key,
    required this.onBack,
    required this.isLiked,
    required this.onLikeTap,
    required this.onShareTap,
  });

  final VoidCallback onBack;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback onShareTap;

  static const double _sideSlotWidth = 96;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                SizedBox(
                  width: _sideSlotWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: AppColors.textPrimary,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    '커미션 상세',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(
                  width: _sideSlotWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onLikeTap,
                        icon: Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 22,
                        ),
                        color:
                            isLiked ? AppColors.primary : AppColors.textPrimary,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      IconButton(
                        onPressed: onShareTap,
                        icon: const Icon(Icons.ios_share_rounded, size: 22),
                        color: AppColors.textPrimary,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 작가 프로필 서브 헤더 — 뒤로가기, 타이틀
class ArtistProfileSubHeader extends StatelessWidget {
  const ArtistProfileSubHeader({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

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
                    '작가 프로필',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: _sideSlotWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

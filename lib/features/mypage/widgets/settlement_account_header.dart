import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 정산 계좌 관리 화면 헤더
class SettlementAccountHeader extends StatelessWidget {
  const SettlementAccountHeader({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 12),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
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
                    const Expanded(
                      child: Text(
                        '정산 계좌 관리',
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
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
          ],
        ),
      ),
    );
  }
}

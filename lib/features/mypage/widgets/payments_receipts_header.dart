import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 결제 내역 관리 화면 헤더
class PaymentsReceiptsHeader extends StatelessWidget {
  const PaymentsReceiptsHeader({
    super.key,
    required this.onBack,
    required this.title,
  });

  final VoidCallback onBack;
  final String title;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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

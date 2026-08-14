import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 하단 고정 액션 버튼 바
class OrderDetailActionBar extends StatelessWidget {
  const OrderDetailActionBar({
    super.key,
    required this.onGoToChat,
    required this.onPrimary,
    this.primaryLabel = '👁️ 현재 시안 보기',
    this.enabled = true,
    this.isBusy = false,
  });

  final VoidCallback onGoToChat;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final bool enabled;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 35,
              child: OutlinedButton(
                onPressed: enabled ? onGoToChat : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.borderLight),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '💬 채팅방으로 이동',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 65,
              child: FilledButton(
                onPressed: enabled ? onPrimary : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        primaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

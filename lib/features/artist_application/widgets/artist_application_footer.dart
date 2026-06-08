import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 신청 폼 하단 네비게이션 (이전 / 다음·신청하기 / 임시저장)
class ArtistApplicationFooter extends StatelessWidget {
  const ArtistApplicationFooter({
    super.key,
    required this.showPrevious,
    required this.isNextEnabled,
    required this.isLastStep,
    required this.onPrevious,
    required this.onNext,
    required this.onSaveDraft,
  });

  final bool showPrevious;
  final bool isNextEnabled;
  final bool isLastStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSaveDraft;

  static const _gradientStart = Color(0xFF7C4DFF);
  static const _gradientEnd = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showPrevious) ...[
                  Expanded(
                    child: _OutlineButton(
                      label: '이전',
                      icon: Icons.chevron_left_rounded,
                      iconAfter: false,
                      onTap: onPrevious,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: showPrevious ? 1 : 1,
                  child: _PrimaryButton(
                    label: isLastStep ? '신청하기' : '다음',
                    icon: isLastStep ? null : Icons.chevron_right_rounded,
                    enabled: isNextEnabled,
                    onTap: isNextEnabled ? onNext : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onSaveDraft,
              icon: const Icon(
                Icons.save_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
              label: const Text(
                '임시저장',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.iconAfter,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool iconAfter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!iconAfter) ...[
                Icon(icon, size: 20, color: AppColors.textPrimary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (iconAfter) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 20, color: AppColors.textPrimary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: enabled
                ? const LinearGradient(
                    colors: [
                      ArtistApplicationFooter._gradientStart,
                      ArtistApplicationFooter._gradientEnd,
                    ],
                  )
                : null,
            color: enabled ? null : AppColors.chipBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : AppColors.textMuted,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    icon,
                    size: 20,
                    color: enabled ? Colors.white : AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

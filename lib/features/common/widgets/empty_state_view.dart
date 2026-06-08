import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum EmptyStateActionPlacement { inline, bottom }

/// 아이콘 + 제목 + 부제 + 선택적 CTA가 있는 공용 빈 상태 위젯
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionPlacement = EmptyStateActionPlacement.inline,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateActionPlacement actionPlacement;

  @override
  Widget build(BuildContext context) {
    final content = _EmptyStateContent(
      icon: icon,
      title: title,
      subtitle: subtitle,
      actionLabel: actionPlacement == EmptyStateActionPlacement.inline
          ? actionLabel
          : null,
      onAction:
          actionPlacement == EmptyStateActionPlacement.inline ? onAction : null,
    );

    if (actionPlacement == EmptyStateActionPlacement.bottom &&
        actionLabel != null &&
        onAction != null) {
      return Column(
        children: [
          Expanded(child: Center(child: content)),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
            child: _EmptyStateActionButton(
              label: actionLabel!,
              onTap: onAction!,
            ),
          ),
        ],
      );
    }

    return Center(child: content);
  }
}

class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 44,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 32),
            _EmptyStateActionButton(
              label: actionLabel!,
              onTap: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyStateActionButton extends StatelessWidget {
  const _EmptyStateActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

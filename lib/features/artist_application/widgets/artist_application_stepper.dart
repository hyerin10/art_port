import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_application/models/artist_application_data.dart';
import 'package:flutter/material.dart';

/// 4단계 프로세스 바
class ArtistApplicationStepper extends StatelessWidget {
  const ArtistApplicationStepper({
    super.key,
    required this.currentStep,
  });

  final ArtistApplicationStep currentStep;

  static const _activeColor = AppColors.primary;
  static const _completedBg = Color(0xFFEDE9FE);
  static const _inactiveBg = Color(0xFFF3F4F6);
  static const _inactiveFg = AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    final steps = ArtistApplicationStep.values;
    final currentIndex = currentStep.index;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= currentIndex
                          ? _activeColor.withValues(alpha: 0.4)
                          : AppColors.borderLight,
                    ),
                  ),
                _StepCircle(
                  step: steps[i],
                  isActive: i == currentIndex,
                  isCompleted: i < currentIndex,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      steps[i].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            i == currentIndex ? FontWeight.w700 : FontWeight.w600,
                        color: i <= currentIndex ? _activeColor : _inactiveFg,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == currentIndex
                            ? _activeColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.step,
    required this.isActive,
    required this.isCompleted,
  });

  final ArtistApplicationStep step;
  final bool isActive;
  final bool isCompleted;

  IconData get _icon {
    switch (step) {
      case ArtistApplicationStep.basicInfo:
        return Icons.palette_outlined;
      case ArtistApplicationStep.portfolio:
        return Icons.image_outlined;
      case ArtistApplicationStep.commission:
        return Icons.payments_outlined;
      case ArtistApplicationStep.terms:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = isActive ? 40.0 : 34.0;

    Color bg;
    Color fg;
    if (isCompleted) {
      bg = ArtistApplicationStepper._completedBg;
      fg = ArtistApplicationStepper._activeColor;
    } else if (isActive) {
      bg = ArtistApplicationStepper._activeColor;
      fg = Colors.white;
    } else {
      bg = ArtistApplicationStepper._inactiveBg;
      fg = ArtistApplicationStepper._inactiveFg;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: ArtistApplicationStepper._activeColor
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : _icon,
        size: isActive ? 20 : 16,
        color: fg,
      ),
    );
  }
}

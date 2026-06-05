import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:flutter/material.dart';

/// 5단계 주문 진행 스텝 바
class OrderProgressStepBar extends StatelessWidget {
  const OrderProgressStepBar({
    super.key,
    required this.currentStepIndex,
  });

  final int currentStepIndex;

  static const _steps = OrderProgressStep.values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;
            final isCompleted = lineIndex < currentStepIndex;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 22),
                color: isCompleted ? AppColors.primary : AppColors.borderLight,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final step = _steps[stepIndex];
          return _StepNode(
            stepNumber: stepIndex + 1,
            label: step.label,
            state: _stepState(stepIndex),
          );
        }),
      ),
    );
  }

  _StepState _stepState(int stepIndex) {
    if (stepIndex < currentStepIndex) return _StepState.completed;
    if (stepIndex == currentStepIndex) return _StepState.current;
    return _StepState.upcoming;
  }
}

enum _StepState { completed, current, upcoming }

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.stepNumber,
    required this.label,
    required this.state,
  });

  final int stepNumber;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _StepState.completed;
    final isCurrent = state == _StepState.current;

    final circleColor = isCompleted || isCurrent
        ? (isCurrent ? AppColors.primary : AppColors.primary)
        : AppColors.chipBackground;
    final labelColor = isCompleted || isCurrent
        ? AppColors.primary
        : AppColors.textMuted;
    final labelWeight =
        isCurrent ? FontWeight.w700 : FontWeight.w600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isCurrent)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              Container(
                width: isCurrent ? 28 : 24,
                height: isCurrent ? 28 : 24,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: isCurrent ? 13 : 11,
                          fontWeight: FontWeight.w700,
                          color: isCompleted || isCurrent
                              ? Colors.white
                              : AppColors.textMuted,
                          height: 1,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: labelWeight,
            color: labelColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

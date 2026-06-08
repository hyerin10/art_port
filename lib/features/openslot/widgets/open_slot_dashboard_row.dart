import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/openslot/models/slot_model.dart';
import 'package:art_port/features/openslot/open_slot_colors.dart';
import 'package:flutter/material.dart';

/// 대시보드 요약 카드 3열
class OpenSlotDashboardRow extends StatelessWidget {
  const OpenSlotDashboardRow({super.key, required this.stats});

  final OpenSlotDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _DashboardCard(
              value: '${stats.activeSlotCount}',
              label: '활성 슬롯',
              valueColor: OpenSlotColors.activeSlotFg,
              backgroundColor: OpenSlotColors.activeSlotBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DashboardCard(
              value: '${stats.ordersInProgress}',
              label: '진행 중인 주문',
              valueColor: OpenSlotColors.ordersFg,
              backgroundColor: OpenSlotColors.ordersBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DashboardCard(
              value: stats.earningsLabel,
              label: '이번 달 정산 금액',
              valueColor: OpenSlotColors.earningsFg,
              backgroundColor: OpenSlotColors.earningsBg,
            ),
          ),
        ],
      ),
    );
  }
}

/// 대시보드 로딩 플레이스홀더
class OpenSlotDashboardPlaceholder extends StatelessWidget {
  const OpenSlotDashboardPlaceholder({super.key});

  static const double _cardHeight = 96;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _placeholderBox()),
          const SizedBox(width: 10),
          Expanded(child: _placeholderBox()),
          const SizedBox(width: 10),
          Expanded(child: _placeholderBox()),
        ],
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      height: _cardHeight,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.backgroundColor,
  });

  final String value;
  final String label;
  final Color valueColor;
  final Color backgroundColor;

  static const double _cardHeight = 96;
  static const double _valueLineHeight = 32;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _valueLineHeight,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      height: 1.0,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

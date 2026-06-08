import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';

class SalesStatisticsCard extends StatelessWidget {
  const SalesStatisticsCard({
    super.key,
    required this.dailySales,
    required this.weeklyTotal,
    required this.weekdayLabels,
  });

  final List<int> dailySales;
  final int weeklyTotal;
  final List<String> weekdayLabels;

  @override
  Widget build(BuildContext context) {
    final maxSales =
        dailySales.isEmpty ? 1 : dailySales.reduce((a, b) => a > b ? a : b);
    final highlightIndex =
        dailySales.isEmpty ? -1 : dailySales.indexOf(maxSales);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                '이번 달 매출 통계',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(dailySales.length, (index) {
                final sales = dailySales[index];
                final barHeight =
                    maxSales > 0 ? (sales / maxSales) * 72.0 : 0.0;
                final isHighlight = index == highlightIndex;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barHeight.clamp(4.0, 72.0),
                          decoration: BoxDecoration(
                            color: isHighlight
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekdayLabels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isHighlight ? FontWeight.w700 : FontWeight.w500,
                            color: isHighlight
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이번 주 총 매출',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                CurrencyFormatter.formatWonSymbol(weeklyTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

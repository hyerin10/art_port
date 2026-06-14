import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 출금 신청 유의사항 박스
class WithdrawalNoticeBox extends StatelessWidget {
  const WithdrawalNoticeBox({super.key});

  static const _background = Color(0xFFF4F4F4);

  static const _notices = [
    '본 플랫폼은 2주에 한 번 수동 정산으로 일괄 지급됩니다.',
    '신청 완료 후에는 취소가 불가능합니다.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _notices.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  Text(
                    '• ${_notices[i]}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

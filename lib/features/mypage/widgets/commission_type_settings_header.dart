import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:flutter/material.dart';

/// 커미션 타입 설정 화면 헤더 — InquiryHeader와 동일한 레이아웃 재사용
class CommissionTypeSettingsHeader extends StatelessWidget {
  const CommissionTypeSettingsHeader({
    super.key,
    required this.onBack,
    this.onNotificationTap,
    this.onFilterTap,
  });

  final VoidCallback onBack;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return InquiryHeader(
      title: '커미션 타입 설정',
      onBack: onBack,
      onNotificationTap: onNotificationTap,
      onFilterTap: onFilterTap,
    );
  }
}

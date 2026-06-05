import 'package:flutter/material.dart';

/// ArtPort 디자인 시스템 색상 상수
abstract final class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  /// 메인 브랜드 컬러 (활성화 버튼 등)
  static const Color primary = Color(0xFF7D3CED);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primarySoft = Color(0xFFF5F3FF);

  /// 성공 / 인증 완료 / 안전 상태
  static const Color success = Color(0xFF15A34A);

  /// 에러 / 경고 / 유효성 실패 상태
  static const Color error = Color(0xFFF26667);

  /// 포인트 배지 또는 하이라이트
  static const Color highlight = Color(0xFFEC4899);

  /// 안내 메시지 및 서브 링크 포인트
  static const Color info = Color(0xFF00ACC1);

  static const Color chipBackground = Color(0xFFF3F4F6);
  static const Color notificationBadge = highlight;
  static const Color onlineStatus = success;

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0A000000);

  /// 1:1 채팅방
  static const Color chatBackground = Color(0xFFF3F4F6);
  static const Color chatOutgoing = Color(0xFF6C5CE7);
  static const Color commissionStatusBar = Color(0xFFFF9500);
  static const Color attachmentCameraBg = Color(0xFFEDE9FE);
  static const Color attachmentGalleryBg = Color(0xFFFCE7F3);
  static const Color attachmentFileBg = Color(0xFFCCFBF1);
}

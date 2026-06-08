import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 슬롯 관리 화면 전용 색상 (대시보드 파스텔 등)
abstract final class OpenSlotColors {
  static const activeSlotFg = AppColors.primary;
  static const activeSlotBg = AppColors.primarySoft;

  static const ordersFg = AppColors.highlight;
  static const ordersBg = Color(0xFFFFF0F5);

  static const earningsFg = AppColors.info;
  static const earningsBg = Color(0xFFE0F7FA);

  static const recruitingFg = AppColors.success;
  static const recruitingBg = Color(0xFFDCFCE7);

  static const fullFg = AppColors.textSecondary;
  static const fullBg = AppColors.chipBackground;

  static const progressTrack = AppColors.chipBackground;
  static const progressFull = Color(0xFF4B5563);

  static const editActionBg = Color(0xFFEEF2FF);
  static const deleteActionBg = AppColors.attachmentGalleryBg;
  static const deleteActionIcon = AppColors.error;
}

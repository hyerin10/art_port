import 'package:flutter/material.dart';

/// DB에 저장된 avatarUrl이 있으면 사용하고, 없으면 빈 문자열(기본 아바타 UI).
String resolveProfileAvatarUrl(String? dbAvatarUrl, [String localAvatarUrl = '']) {
  final fromDb = dbAvatarUrl?.trim() ?? '';
  if (fromDb.isNotEmpty) return fromDb;
  return localAvatarUrl.trim();
}

/// 고객 프로필 데이터 (추후 API 연동)
class ClientProfileData {
  const ClientProfileData({
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final String name;
  final String email;
  final String avatarUrl;

  ClientProfileData copyWith({
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return ClientProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// 작가 프로필 데이터 (추후 API 연동)
class ArtistProfileData {
  const ArtistProfileData({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
  });

  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;

  ArtistProfileData copyWith({
    String? name,
    String? avatarUrl,
    double? rating,
    int? reviewCount,
  }) {
    return ArtistProfileData(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

/// 작가 수익 및 매출 데이터 (추후 API 연동)
class ArtistEarningsData {
  const ArtistEarningsData({
    required this.withdrawableAmount,
    required this.weeklySalesTotal,
    required this.dailySales,
  });

  /// 출금 가능 수익금 (원)
  final int withdrawableAmount;

  /// 이번 주 총 매출 (원)
  final int weeklySalesTotal;

  /// 월~일 요일별 매출 (7개)
  final List<int> dailySales;

  ArtistEarningsData copyWith({
    int? withdrawableAmount,
    int? weeklySalesTotal,
    List<int>? dailySales,
  }) {
    return ArtistEarningsData(
      withdrawableAmount: withdrawableAmount ?? this.withdrawableAmount,
      weeklySalesTotal: weeklySalesTotal ?? this.weeklySalesTotal,
      dailySales: dailySales ?? this.dailySales,
    );
  }
}

/// 메뉴 아이템 정의
class MyPageMenuItem {
  const MyPageMenuItem({
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;
}

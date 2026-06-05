import 'package:art_port/features/mypage/artist_portfolio_edit_screen.dart';
import 'package:art_port/features/mypage/commission_type_settings_screen.dart';
import 'package:art_port/features/mypage/notice_settings_screen.dart';
import 'package:art_port/features/mypage/followed_artists_screen.dart';
import 'package:art_port/features/mypage/inquiry_list_screen.dart';
import 'package:art_port/features/mypage/liked_works_screen.dart';
import 'package:art_port/features/mypage/payments_receipts_screen.dart';
import 'package:art_port/features/mypage/models/mypage_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이페이지 표시 여부
final showMyPageProvider = NotifierProvider<ShowMyPageNotifier, bool>(
  ShowMyPageNotifier.new,
);

class ShowMyPageNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;

  void close() => state = false;

  void toggle() => state = !state;
}

/// 고객 프로필 (추후 API 연동)
final clientProfileProvider = NotifierProvider<ClientProfileNotifier, ClientProfileData>(
  ClientProfileNotifier.new,
);

class ClientProfileNotifier extends Notifier<ClientProfileData> {
  @override
  ClientProfileData build() {
    return const ClientProfileData(
      name: '김하늘',
      email: 'haneul.kim@email.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
    );
  }

  void onEditProfilePhoto() {
    // TODO: 프로필 사진 수정 API 연동
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}

/// 작가 프로필 (추후 API 연동)
final artistProfileProvider = NotifierProvider<ArtistProfileNotifier, ArtistProfileData>(
  ArtistProfileNotifier.new,
);

class ArtistProfileNotifier extends Notifier<ArtistProfileData> {
  @override
  ArtistProfileData build() {
    return const ArtistProfileData(
      name: '하늘작가',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
      rating: 4.9,
      reviewCount: 42,
    );
  }

  void onEditProfilePhoto() {
    // TODO: 프로필 사진 수정 API 연동
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }
}

/// 작가 수익 데이터 (추후 API 연동)
final artistEarningsProvider = Provider<ArtistEarningsData>((ref) {
  return const ArtistEarningsData(
    withdrawableAmount: 1250000,
    weeklySalesTotal: 320000,
    dailySales: [45000, 62000, 38000, 71000, 95000, 52000, 47000],
  );
});

/// 휴식 모드 상태 (추후 API 연동)
final restModeProvider = NotifierProvider<RestModeNotifier, bool>(
  RestModeNotifier.new,
);

class RestModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle(bool value) {
    state = value;
    // TODO: 휴식 모드 API 연동
  }
}

/// 고객 마이페이지 메뉴 액션
final clientMyPageActionsProvider = Provider<ClientMyPageActions>((ref) {
  return ClientMyPageActions(ref);
});

class ClientMyPageActions {
  ClientMyPageActions(this.ref);

  final Ref ref;

  void onLikedWorks(BuildContext context) {
    LikedWorksScreen.open(context);
  }

  void onFollowedArtists(BuildContext context) {
    FollowedArtistsScreen.open(context);
  }

  void onPaymentsAndReceipts(BuildContext context) {
    PaymentsReceiptsScreen.open(context);
  }

  void onInquiry(BuildContext context) {
    InquiryListScreen.open(context);
  }
}

/// 작가 마이페이지 메뉴 액션
final artistMyPageActionsProvider = Provider<ArtistMyPageActions>((ref) {
  return ArtistMyPageActions(ref);
});

class ArtistMyPageActions {
  ArtistMyPageActions(this.ref);

  final Ref ref;

  void onEditProfilePortfolio(BuildContext context) {
    ArtistPortfolioEditScreen.open(context);
  }

  void onCommissionTypeSettings(BuildContext context) {
    CommissionTypeSettingsScreen.open(context);
  }

  void onNoticeSettings(BuildContext context) {
    NoticeSettingsScreen.open(context);
  }

  void onRequestWithdrawal() {
    // TODO: 출금 신청 API 연동
  }

  void onSettlementAccount() {
    // TODO: 정산 계좌 관리 화면으로 이동
  }
}

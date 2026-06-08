import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작가 승인 상태
enum ArtistApprovalStatus {
  /// 미신청 — 오픈 슬롯/워크룸 탭에서 신청 진입 화면 표시
  notApplied,

  /// 심사 중 — 신청서 제출 완료
  pending,

  /// 승인 완료 — 슬롯 관리/작업실 정상 이용
  approved,
}

final artistApprovalStatusProvider =
    NotifierProvider<ArtistApprovalStatusNotifier, ArtistApprovalStatus>(
  ArtistApprovalStatusNotifier.new,
);

class ArtistApprovalStatusNotifier extends Notifier<ArtistApprovalStatus> {
  @override
  ArtistApprovalStatus build() => ArtistApprovalStatus.notApplied;

  bool get isApprovedArtist => state == ArtistApprovalStatus.approved;

  void markPending() {
    state = ArtistApprovalStatus.pending;
  }

  void markApproved() {
    state = ArtistApprovalStatus.approved;
  }

  void reset() {
    state = ArtistApprovalStatus.notApplied;
  }
}

import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/artist_application/data/artist_application_providers.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작가 승인 상태
enum ArtistApprovalStatus {
  /// 미신청 — 작가 신청 진입 화면 표시
  notApplied,

  /// 심사 중 — 신청서 제출 완료
  pending,

  /// 승인 완료 — artistProfileId 보유
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

/// 로그인 사용자의 작가 프로필·신청 상태를 서버 기준으로 동기화합니다.
Future<void> refreshArtistApprovalStatus(
  T Function<T>(ProviderListenable<T> provider) read,
) async {
  final user = read(authProvider);
  if (user == null) {
    read(artistApprovalStatusProvider.notifier).reset();
    return;
  }

  if (user.hasArtistProfile) {
    read(artistApprovalStatusProvider.notifier).markApproved();
    return;
  }

  try {
    final application =
        await read(artistApplicationRepositoryProvider).getMyApplication();

    if (application.isPending) {
      read(artistApprovalStatusProvider.notifier).markPending();
    } else {
      read(artistApprovalStatusProvider.notifier).reset();
    }
  } on ApiException catch (e) {
    if (e.code == 'ARTIST_APPLICATION_NOT_FOUND' || e.status == 404) {
      read(artistApprovalStatusProvider.notifier).reset();
      return;
    }
  } catch (_) {
    read(artistApprovalStatusProvider.notifier).reset();
  }
}

final hasArtistProfileProvider = Provider<bool>((ref) {
  return ref.watch(authProvider)?.hasArtistProfile ?? false;
});

final hasClientProfileProvider = Provider<bool>((ref) {
  return ref.watch(authProvider)?.hasClientProfile ?? false;
});

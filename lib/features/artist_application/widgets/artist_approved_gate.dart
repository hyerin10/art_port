import 'package:art_port/features/artist_application/artist_application_entry_view.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작가 승인 게이트 임시 비활성화 (true면 '작가로 활동하세요' 화면 생략)
const kBypassArtistApprovalGate = true;

/// 작가 모드에서 승인된 작가만 실제 콘텐츠를 보여주고,
/// 미승인 시 작가 활동 신청 진입 화면을 표시합니다.
class ArtistApprovedGate extends ConsumerWidget {
  const ArtistApprovedGate({
    super.key,
    required this.entryTab,
    required this.approvedChild,
  });

  final ArtistApplicationEntryTab entryTab;
  final Widget approvedChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtistMode = ref.watch(appModeProvider);

    if (!isArtistMode || kBypassArtistApprovalGate) {
      return approvedChild;
    }

    final status = ref.watch(artistApprovalStatusProvider);
    if (status == ArtistApprovalStatus.approved) {
      return approvedChild;
    }

    return ArtistApplicationEntryView(tab: entryTab);
  }
}

import 'package:art_port/features/artist_application/artist_application_entry_view.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작가 모드에서 작가 프로필이 있을 때만 실제 콘텐츠를 보여주고,
/// 없으면 작가 활동 신청 진입 화면을 표시합니다.
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

    if (!isArtistMode) {
      return approvedChild;
    }

    final user = ref.watch(authProvider);
    if (user?.hasArtistProfile == true) {
      return approvedChild;
    }

    return ArtistApplicationEntryView(tab: entryTab);
  }
}

import 'package:art_port/features/auth/domain/user.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 후 로컬 프로필을 사용자 정보와 동기화합니다.
void syncSessionSideEffects(WidgetRef ref, User user) {
  _syncSession(ref.read, user);
}

void syncSessionSideEffectsFromRef(Ref ref, User user) {
  _syncSession(ref.read, user);
}

void _syncSession(T Function<T>(ProviderListenable<T> provider) read, User user) {
  read(clientProfileProvider.notifier).syncFromUser(user);
  if (user.hasArtistProfile) {
    read(artistProfileProvider.notifier).syncFromUser(user);
  }
}

/// 서버에서 최신 사용자·작가 신청 상태를 가져와 세션에 반영합니다.
Future<void> refreshCurrentUser(WidgetRef ref) async {
  final current = ref.read(authProvider);
  if (current == null) return;

  try {
    final user = await ref.read(userRepositoryProvider).getUser(current.id);
    ref.read(authProvider.notifier).update(user);
    syncSessionSideEffects(ref, user);
    await refreshArtistApprovalStatus(ref.read);
  } catch (_) {
    // 조회 실패 시 로그인 시 받은 세션 정보를 유지합니다.
  }
}

Future<void> refreshCurrentUserFromRef(Ref ref) async {
  final current = ref.read(authProvider);
  if (current == null) return;

  try {
    final user = await ref.read(userRepositoryProvider).getUser(current.id);
    ref.read(authProvider.notifier).update(user);
    syncSessionSideEffectsFromRef(ref, user);
    await refreshArtistApprovalStatus(ref.read);
  } catch (_) {
    // 조회 실패 시 로그인 시 받은 세션 정보를 유지합니다.
  }
}

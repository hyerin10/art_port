import 'package:art_port/features/auth/presentation/auth_session_effects.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작 시 토큰 기반 세션 복원.
final authBootstrapProvider = FutureProvider<void>((ref) async {
  final user = await ref.read(authProvider.notifier).restoreSession();
  if (user == null) return;
  syncSessionSideEffectsFromRef(ref, user);
  await refreshArtistApprovalStatus(ref.read);
});

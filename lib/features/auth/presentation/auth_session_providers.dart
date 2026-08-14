import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/auth/data/user_repository.dart';
import 'package:art_port/features/auth/domain/user.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:art_port/providers/auth_provider.dart'
    show authProvider, isLoggedInProvider;
export 'package:art_port/providers/artist_status_provider.dart'
    show hasArtistProfileProvider, hasClientProfileProvider;

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

/// 로그인된 사용자 정보.
final currentUserProvider = Provider<User?>((ref) => ref.watch(authProvider));

/// API `?userId=` 파라미터용.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider)?.id;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider)?.isAdmin ?? false;
});

/// 로그인 사용자의 작가 프로필 UUID. 없으면 null.
final currentArtistProfileIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider)?.artistProfileId;
});

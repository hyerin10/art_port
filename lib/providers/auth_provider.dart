import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/auth/data/dto/auth_response_dto.dart';
import 'package:art_port/features/auth/domain/user.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인된 사용자. `null`이면 비로그인 상태.
final authProvider = NotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  bool get isLoggedIn => state != null;

  /// 저장된 토큰으로 세션을 복원합니다.
  Future<User?> restoreSession() async {
    final storage = ref.read(tokenStorageProvider);
    if (!await storage.hasTokens()) return null;

    try {
      final user = await ref.read(authRepositoryProvider).getMe();
      state = user;
      _syncEmailVerified(user);
      return user;
    } catch (_) {
      await storage.clear();
      state = null;
      ref.read(isEmailVerifiedProvider.notifier).reset();
      return null;
    }
  }

  Future<void> applySession(AuthSession session) async {
    await ref.read(tokenStorageProvider).saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
    state = session.user;
    _syncEmailVerified(session.user);
  }

  void signIn(User user) {
    state = user;
    _syncEmailVerified(user);
  }

  void update(User user) {
    state = user;
    _syncEmailVerified(user);
  }

  Future<void> signOut() async {
    final storage = ref.read(tokenStorageProvider);
    final refreshToken = await storage.readRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await ref.read(authRepositoryProvider).logout(refreshToken);
      } catch (_) {
        // 서버 로그아웃 실패해도 로컬 세션은 정리합니다.
      }
    }

    await storage.clear();
    state = null;
    ref.read(isEmailVerifiedProvider.notifier).reset();
    ref.read(artistApprovalStatusProvider.notifier).reset();
  }

  void _syncEmailVerified(User user) {
    if (user.isEmailVerified) {
      ref.read(isEmailVerifiedProvider.notifier).markVerified();
    } else {
      ref.read(isEmailVerifiedProvider.notifier).reset();
    }
  }
}

/// 로그인 여부.
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

/// 이메일 인증 완료 여부.
final isEmailVerifiedProvider = NotifierProvider<IsEmailVerifiedNotifier, bool>(
  IsEmailVerifiedNotifier.new,
);

class IsEmailVerifiedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markVerified() => state = true;

  void reset() => state = false;
}

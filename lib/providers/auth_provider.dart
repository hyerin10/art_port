import 'package:art_port/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인된 사용자. `null`이면 비로그인 상태.
final authProvider = NotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  bool get isLoggedIn => state != null;

  void signIn(User user) {
    state = user;
    if (user.isEmailVerified) {
      ref.read(isEmailVerifiedProvider.notifier).markVerified();
    }
  }

  void update(User user) {
    state = user;
    if (user.isEmailVerified) {
      ref.read(isEmailVerifiedProvider.notifier).markVerified();
    }
  }

  void signOut() {
    state = null;
    ref.read(isEmailVerifiedProvider.notifier).reset();
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

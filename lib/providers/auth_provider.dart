import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역 로그인 상태. `true` = 로그인됨.
final authProvider = NotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  bool get isLoggedIn => state;

  void signIn() => state = true;

  void signOut() {
    state = false;
    ref.read(isEmailVerifiedProvider.notifier).reset();
  }
}

/// 이메일 인증 완료 여부. `true` = 인증됨.
final isEmailVerifiedProvider = NotifierProvider<IsEmailVerifiedNotifier, bool>(
  IsEmailVerifiedNotifier.new,
);

class IsEmailVerifiedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markVerified() => state = true;

  void reset() => state = false;
}

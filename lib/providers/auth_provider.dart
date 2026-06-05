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

  void signOut() => state = false;
}

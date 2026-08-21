import 'package:art_port/core/config/google_auth_config.dart';
import 'package:art_port/features/auth/auth_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService();
});

/// Google Sign-In으로 백엔드 검증용 idToken을 가져옵니다.
///
/// `google_sign_in` 6.x(레거시 Sign-In API)를 사용합니다.
/// 7.x Credential Manager는 에뮬레이터에서
/// `GetCredentialResponse error` / No credentials available 이 자주 납니다.
class GoogleSignInService {
  GoogleSignIn? _client;

  GoogleSignIn _signInClient() {
    if (!GoogleAuthConfig.isConfigured) {
      throw const GoogleSignInConfigException();
    }
    final serverClientId = GoogleAuthConfig.serverClientId;
    debugPrint(
      'GoogleSignIn: serverClientId configured '
      '(…${serverClientId.substring(serverClientId.length - 12)})',
    );
    return _client ??= GoogleSignIn(
      serverClientId: serverClientId,
      scopes: const ['email', 'profile'],
    );
  }

  /// 사용자가 취소하면 `null`을 반환합니다.
  Future<String?> getIdToken() async {
    final client = _signInClient();

    try {
      final account = await client.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        debugPrint('GoogleSignIn: idToken이 비어 있습니다. serverClientId/SHA-1을 확인하세요.');
        throw const GoogleSignInTokenException();
      }
      return idToken;
    } on PlatformException catch (e) {
      debugPrint('GoogleSignIn PlatformException: ${e.code} ${e.message}');
      rethrow;
    }
  }
}

class GoogleSignInConfigException implements Exception {
  const GoogleSignInConfigException();

  String get message => AuthMessages.googleSignInNotConfigured;

  @override
  String toString() => 'GoogleSignInConfigException: $message';
}

class GoogleSignInTokenException implements Exception {
  const GoogleSignInTokenException();

  String get message => AuthMessages.googleSignInTokenMissing;

  @override
  String toString() => 'GoogleSignInTokenException: $message';
}

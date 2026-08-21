/// Google Sign-In / 백엔드 토큰 검증용 설정.
///
/// Android에서 백엔드 검증용 **idToken**을 받으려면 Web OAuth Client ID를
/// [serverClientId]로 넘겨야 합니다. 서버 `GOOGLE_CLIENT_IDS`에도 동일 ID가
/// 포함되어야 합니다.
///
/// 로컬 설정: `secrets/dart_defines.json.example`을 복사해
/// `secrets/dart_defines.json`에 Web Client ID를 넣고 실행합니다.
///
/// ```bash
/// cp secrets/dart_defines.json.example secrets/dart_defines.json
/// flutter run --dart-define-from-file=secrets/dart_defines.json
/// ```
abstract final class GoogleAuthConfig {
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static bool get isConfigured => serverClientId.isNotEmpty;
}

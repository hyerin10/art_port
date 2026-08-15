import 'dart:io';

import 'package:flutter/foundation.dart';

/// API 서버 설정.
abstract final class ApiConfig {
  static const int defaultPort = 5000;

  /// Android 에뮬레이터는 `localhost` 대신 `10.0.2.2`를 사용합니다.
  /// 실기기 테스트 시 PC IP로 교체하세요.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$defaultPort';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$defaultPort';
    }
    return 'http://localhost:$defaultPort';
  }

  /// 서버가 내려준 `localhost`/`127.0.0.1`(포트 무관, 예: 8080) URL을
  /// 현재 디바이스에서 도달 가능한 [baseUrl] 호스트·포트로 바꿉니다.
  static String resolveMediaUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    final baseUri = Uri.parse(baseUrl);

    if (trimmed.startsWith('/')) {
      return '$baseUri$trimmed';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return trimmed;
    }

    final host = uri.host.toLowerCase();
    if (host != 'localhost' && host != '127.0.0.1') {
      return trimmed;
    }

    return uri
        .replace(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.hasPort ? baseUri.port : null,
        )
        .toString();
  }
}

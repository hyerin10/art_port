import 'dart:io';

import 'package:flutter/foundation.dart';

/// API 서버 설정.
abstract final class ApiConfig {
  static const int defaultPort = 8080;

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
}

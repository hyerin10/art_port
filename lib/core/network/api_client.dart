import 'dart:convert';

import 'package:art_port/core/config/api_config.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/api_response.dart';
import 'package:http/http.dart' as http;

/// 액세스 토큰 조회 콜백.
typedef AccessTokenProvider = Future<String?> Function();

/// 토큰 갱신 콜백. 성공 시 `true`.
typedef TokenRefresher = Future<bool> Function();

/// HTTP 클라이언트 — 공통 헤더·JWT·응답 파싱·에러 처리.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    AccessTokenProvider? accessTokenProvider,
    TokenRefresher? tokenRefresher,
  }) : _httpClient = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConfig.baseUrl,
       _accessTokenProvider = accessTokenProvider,
       _tokenRefresher = tokenRefresher;

  final http.Client _httpClient;
  final String _baseUrl;
  final AccessTokenProvider? _accessTokenProvider;
  final TokenRefresher? _tokenRefresher;

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 갱신 요청이 동시에 여러 번 나가지 않도록 공유 Future.
  Future<bool>? _refreshInFlight;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _requestObject(
      'GET',
      path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  /// `data`가 배열인 목록 API용.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _requestObjectList(
      'GET',
      path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _requestObject(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  /// 본문 없는 성공(204 등)용 POST.
  Future<void> postEmpty(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    await _requestData(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      allowEmptyData: true,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _requestObject(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  /// 본문 없는 성공(204 등)용 PATCH.
  Future<void> patchEmpty(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    await _requestData(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      allowEmptyData: true,
      authenticated: authenticated,
    );
  }

  /// `data`가 배열인 PATCH 응답용.
  Future<List<Map<String, dynamic>>> patchList(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return _requestObjectList(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<void> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    await _requestData(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      allowEmptyData: true,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> _requestObject(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool allowEmptyData = false,
    bool authenticated = true,
  }) async {
    final data = await _requestData(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      allowEmptyData: allowEmptyData,
      authenticated: authenticated,
    );
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (allowEmptyData && data == null) {
      return {};
    }
    throw ApiException.unexpected('응답 데이터 형식이 올바르지 않습니다.');
  }

  Future<List<Map<String, dynamic>>> _requestObjectList(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final data = await _requestData(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      allowEmptyData: true,
      authenticated: authenticated,
    );
    if (data == null) {
      return const [];
    }
    if (data is! List) {
      throw ApiException.unexpected('목록 응답 형식이 올바르지 않습니다.');
    }

    final items = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        throw ApiException.unexpected('목록 항목 형식이 올바르지 않습니다.');
      }
      items.add(item);
    }
    return items;
  }

  Future<Object?> _requestData(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool allowEmptyData = false,
    bool authenticated = true,
    bool allowRefreshRetry = true,
  }) async {
    final response = await _send(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );

    final shouldRetry = authenticated &&
        allowRefreshRetry &&
        _tokenRefresher != null &&
        _isUnauthorizedTokenError(response);

    if (shouldRetry) {
      final refreshed = await _refreshOnce();
      if (refreshed) {
        return _requestData(
          method,
          path,
          body: body,
          queryParameters: queryParameters,
          allowEmptyData: allowEmptyData,
          authenticated: authenticated,
          allowRefreshRetry: false,
        );
      }
    }

    return _parseResponse(response, allowEmptyData: allowEmptyData);
  }

  Future<bool> _refreshOnce() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final refresher = _tokenRefresher;
    if (refresher == null) return Future.value(false);

    final future = () async {
      try {
        return await refresher();
      } finally {
        _refreshInFlight = null;
      }
    }();
    _refreshInFlight = future;
    return future;
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.isNotEmpty == true
          ? queryParameters
          : null,
    );

    final headers = Map<String, String>.from(_jsonHeaders);
    final accessTokenProvider = _accessTokenProvider;
    if (authenticated && accessTokenProvider != null) {
      final token = await accessTokenProvider();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      switch (method) {
        case 'GET':
          return await _httpClient.get(uri, headers: headers);
        case 'POST':
          return await _httpClient.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PATCH':
          return await _httpClient.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          return await _httpClient.delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
        default:
          throw ApiException.unexpected('지원하지 않는 HTTP 메서드입니다.');
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException.network();
    }
  }

  bool _isUnauthorizedTokenError(http.Response response) {
    if (response.statusCode != 401) return false;
    if (response.body.isEmpty) return true;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return true;
      if (decoded['success'] != false) return true;
      final error = decoded['error'];
      if (error is! Map<String, dynamic>) return true;
      final code = error['code'] as String?;
      return code == 'EXPIRED_TOKEN' ||
          code == 'INVALID_TOKEN' ||
          code == 'UNAUTHORIZED';
    } catch (_) {
      return true;
    }
  }

  Object? _parseResponse(
    http.Response response, {
    required bool allowEmptyData,
  }) {
    if (response.statusCode == 204 || response.body.isEmpty) {
      if (allowEmptyData) return null;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException.unexpected('서버 응답을 해석할 수 없습니다.');
    }

    if (decoded['success'] == false) {
      final errorJson = decoded['error'];
      if (errorJson is Map<String, dynamic>) {
        throw ApiException.fromErrorBody(ApiErrorBody.fromJson(errorJson));
      }
      throw ApiException.unexpected();
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        code: 'HTTP_${response.statusCode}',
        status: response.statusCode,
        message: '요청 처리 중 오류가 발생했습니다.',
      );
    }

    return decoded['data'];
  }

  void close() => _httpClient.close();
}

import 'dart:convert';

import 'package:art_port/core/config/api_config.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/api_response.dart';
import 'package:http/http.dart' as http;

/// HTTP 클라이언트 — 공통 헤더·응답 파싱·에러 처리.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _httpClient;
  final String _baseUrl;

  static const _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _request('GET', path, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
    );
  }

  Future<void> delete(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    await _request(
      'DELETE',
      path,
      queryParameters: queryParameters,
      allowEmptyData: true,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    bool allowEmptyData = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters?.isNotEmpty == true
          ? queryParameters
          : null,
    );

    late http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _httpClient.get(uri, headers: _headers);
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'PATCH':
          response = await _httpClient.patch(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          );
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: _headers);
        default:
          throw ApiException.unexpected('지원하지 않는 HTTP 메서드입니다.');
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException.network();
    }

    if (response.statusCode == 204 || response.body.isEmpty) {
      if (allowEmptyData) return {};
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {};
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

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (allowEmptyData) {
      return {};
    }
    throw ApiException.unexpected('응답 데이터 형식이 올바르지 않습니다.');
  }

  void close() => _httpClient.close();
}

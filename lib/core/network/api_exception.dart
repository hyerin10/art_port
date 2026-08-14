import 'package:art_port/core/network/api_response.dart';

/// API 호출 실패 시 발생하는 예외.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.status,
    required this.message,
    this.fieldErrors = const [],
  });

  final String code;
  final int status;
  final String message;
  final List<ApiFieldError> fieldErrors;

  factory ApiException.fromErrorBody(ApiErrorBody error) {
    return ApiException(
      code: error.code,
      status: error.status,
      message: error.message,
      fieldErrors: error.errors,
    );
  }

  factory ApiException.network([String? detail]) {
    return ApiException(
      code: 'NETWORK_ERROR',
      status: 0,
      message: detail ?? '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.',
    );
  }

  factory ApiException.unexpected([String? detail]) {
    return ApiException(
      code: 'UNEXPECTED_ERROR',
      status: 0,
      message: detail ?? '예기치 않은 오류가 발생했습니다.',
    );
  }

  /// UI에 표시할 한국어 메시지.
  String get displayMessage {
    switch (code) {
      case 'DUPLICATE_EMAIL':
        return '이미 사용 중인 이메일입니다.';
      case 'USER_NOT_FOUND':
        return '사용자를 찾을 수 없습니다.';
      case 'INVALID_CREDENTIALS':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'USER_INACTIVE':
        return '비활성화된 계정입니다. 고객센터에 문의해주세요.';
      case 'NETWORK_ERROR':
        return message;
      case 'INVALID_INPUT':
        if (fieldErrors.isNotEmpty) {
          return fieldErrors.first.reason;
        }
        return message;
      default:
        return message;
    }
  }

  @override
  String toString() => 'ApiException($code, $status): $message';
}

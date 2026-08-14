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
      case 'ARTIST_PROFILE_NOT_FOUND':
        return '작가 프로필을 찾을 수 없습니다.';
      case 'COMMISSION_TYPE_NOT_FOUND':
        return '커미션을 찾을 수 없습니다.';
      case 'INVALID_CREDENTIALS':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'USER_INACTIVE':
        return '비활성화된 계정입니다. 고객센터에 문의해주세요.';
      case 'FOLLOW_NOT_FOUND':
        return '팔로우 정보를 찾을 수 없습니다.';
      case 'CHAT_ROOM_NOT_FOUND':
        return '채팅방을 찾을 수 없습니다.';
      case 'ORDER_NOT_FOUND':
        return '주문을 찾을 수 없습니다.';
      case 'REVIEW_NOT_FOUND':
        return '리뷰를 찾을 수 없습니다.';
      case 'FORBIDDEN':
        return '이 작업을 수행할 권한이 없습니다.';
      case 'DUPLICATE_RESOURCE':
        return '이미 처리된 요청입니다.';
      case 'BAD_REQUEST':
        return message.isNotEmpty ? message : '잘못된 요청입니다.';
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

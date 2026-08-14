/// API 공통 성공/실패 응답 래퍼.
class ApiErrorBody {
  const ApiErrorBody({
    required this.status,
    required this.code,
    required this.message,
    this.errors = const [],
  });

  final int status;
  final String code;
  final String message;
  final List<ApiFieldError> errors;

  factory ApiErrorBody.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    return ApiErrorBody(
      status: json['status'] as int? ?? 500,
      code: json['code'] as String? ?? 'INTERNAL_SERVER_ERROR',
      message: json['message'] as String? ?? '알 수 없는 오류가 발생했습니다.',
      errors: rawErrors is List
          ? rawErrors
              .whereType<Map<String, dynamic>>()
              .map(ApiFieldError.fromJson)
              .toList()
          : const [],
    );
  }
}

class ApiFieldError {
  const ApiFieldError({
    required this.field,
    required this.value,
    required this.reason,
  });

  final String field;
  final String value;
  final String reason;

  factory ApiFieldError.fromJson(Map<String, dynamic> json) {
    return ApiFieldError(
      field: json['field'] as String? ?? '',
      value: json['value']?.toString() ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

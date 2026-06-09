/// 결제 카드 입력 유효성 검사
abstract final class PaymentCardValidators {
  static String? cardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '카드 번호를 입력해 주세요.';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16) {
      return '올바른 카드 번호 16자리를 입력해 주세요.';
    }

    return null;
  }

  static String? expiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '유효기간을 입력해 주세요.';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 4) {
      return '올바른 유효기간을 입력해 주세요.';
    }

    final month = int.tryParse(digits.substring(0, 2));
    final year = int.tryParse(digits.substring(2, 4));

    if (month == null || year == null || month < 1 || month > 12) {
      return '올바른 유효기간을 입력해 주세요.';
    }

    final now = DateTime.now();
    final currentYy = now.year % 100;
    final currentMm = now.month;

    if (year < currentYy || (year == currentYy && month < currentMm)) {
      return '올바른 유효기간을 입력해 주세요.';
    }

    return null;
  }

  static String? cvc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVC 번호를 입력해 주세요.';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 3) {
      return 'CVC는 3자리 숫자여야 합니다.';
    }

    return null;
  }
}

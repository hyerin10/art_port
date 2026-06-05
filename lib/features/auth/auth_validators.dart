abstract final class AuthValidators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phoneRegex = RegExp(r'^\d{10,11}$');
  static final _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  static bool isValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  static bool isValidPhone(String value) =>
      !hasInvalidPhoneCharacters(value) && _phoneRegex.hasMatch(value);

  /// 숫자 이외의 문자(하이픈, 영문, 한글, 특수문자 등) 포함 여부
  static bool hasInvalidPhoneCharacters(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'[^0-9]').hasMatch(value);
  }

  static bool isValidPassword(String value) => _passwordRegex.hasMatch(value);

  static String formatPhone(String raw) {
    if (hasInvalidPhoneCharacters(raw)) return raw;

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length > 11 ? digits.substring(0, 11) : digits;
  }
}

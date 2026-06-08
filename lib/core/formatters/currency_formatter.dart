/// 원화 금액 표시 포맷
abstract final class CurrencyFormatter {
  static String formatComma(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  /// 예: `50,000원`
  static String formatWon(int won) => '${formatComma(won)}원';

  /// 예: `50,000원 ~`
  static String formatWonWithSuffix(int won, {String suffix = ' ~'}) =>
      '${formatWon(won)}$suffix';

  /// 예: `₩50,000~`
  static String formatWonKrw(int won, {String suffix = '~'}) =>
      '₩${formatComma(won)}$suffix';

  /// 예: `₩ 1,250,000`
  static String formatWonSymbol(int won) => '₩ ${formatComma(won)}';
}

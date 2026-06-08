import 'package:art_port/core/formatters/currency_formatter.dart';

/// 커미션 가격 옵션
class CommissionPriceOption {
  const CommissionPriceOption({
    required this.label,
    required this.priceWon,
    this.subtitle,
    this.isPopular = false,
  });

  final String label;
  final String? subtitle;
  final int priceWon;
  final bool isPopular;

  String get priceLabel => CurrencyFormatter.formatWonWithSuffix(priceWon);

  String get displayLabel =>
      subtitle != null ? '$label ($subtitle)' : label;
}

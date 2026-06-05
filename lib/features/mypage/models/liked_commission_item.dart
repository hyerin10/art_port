import 'package:art_port/features/commission/models/commission_detail.dart';

/// 찜한 작품 목록 카드용 데이터 모델
class LikedCommissionItem {
  const LikedCommissionItem({
    required this.id,
    required this.imageUrl,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.title,
    required this.tags,
    required this.priceLabel,
  });

  final String id;
  final String imageUrl;
  final String artistName;
  final String artistAvatarUrl;
  final String title;
  final List<String> tags;
  final String priceLabel;

  factory LikedCommissionItem.fromDetail(CommissionDetail detail) {
    final priceWon = detail.priceOptions.isNotEmpty
        ? detail.priceOptions.first.priceWon
        : 0;

    return LikedCommissionItem(
      id: detail.id,
      imageUrl: detail.imageUrls.first,
      artistName: detail.artistName,
      artistAvatarUrl: detail.artistAvatarUrl,
      title: detail.title,
      tags: detail.tags,
      priceLabel: _formatPriceLabel(priceWon),
    );
  }

  static String _formatPriceLabel(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '₩${buf.toString()}~';
  }
}

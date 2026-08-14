import 'package:art_port/features/review/data/dto/review_dto.dart';
import 'package:art_port/features/workroom/models/workroom_commission_order.dart';

class ReviewListItem {
  const ReviewListItem({
    required this.review,
    required this.title,
    required this.counterpartName,
    required this.counterpartAvatarUrl,
  });

  final ReviewDto review;
  final String title;
  final String counterpartName;
  final String counterpartAvatarUrl;

  String get dateLabel {
    final local = review.createdAt.toLocal();
    return formatWorkroomRelativeTime(local);
  }

  String get contentText {
    final text = review.content?.trim();
    if (text == null || text.isEmpty) return '내용 없는 리뷰입니다.';
    return text;
  }
}

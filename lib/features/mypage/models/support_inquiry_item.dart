/// 1:1 문의(고객센터) 목록 아이템
class SupportInquiryItem {
  const SupportInquiryItem({
    required this.id,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;

  String get timeAgoLabel => _formatTimeAgo(lastMessageAt);

  SupportInquiryItem copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return SupportInquiryItem(
      id: id,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  static String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (messageDay == yesterday) return '어제';

    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}월 ${dateTime.day}일';
  }
}

/// ArtPort 고객센터 상수
abstract final class SupportInquiryConstants {
  static const String centerName = 'ArtPort 고객센터';
  static const String centerAvatarAsset = 'assets/branding/art_port_icon.png';
}

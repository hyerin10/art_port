/// 탐색 탭 갤러리·슬롯용 더미 데이터 모델
class CommissionSample {
  const CommissionSample({
    required this.id,
    required this.imageUrl,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.startPriceWon,
    required this.likeCount,
    required this.tags,
    required this.aspectRatio,
    this.isLiked = false,
  });

  final String id;
  final String imageUrl;
  final String artistName;
  final String artistAvatarUrl;
  final int startPriceWon;
  final int likeCount;
  final List<String> tags;
  final double aspectRatio;
  final bool isLiked;

  String get priceLabel {
    if (startPriceWon >= 10000) {
      final formatted = _formatWon(startPriceWon);
      return '$formatted~';
    }
    return '$startPriceWon원~';
  }

  String get likeCountLabel {
    if (likeCount >= 1000) {
      final k = likeCount / 1000;
      return k >= 10 ? '${k.toStringAsFixed(0)}k' : '${k.toStringAsFixed(1)}k';
    }
    return '$likeCount';
  }

  static String _formatWon(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()}원';
  }
}

class LiveSlotSample {
  const LiveSlotSample({
    required this.commissionId,
    required this.artistName,
    required this.categoryTag,
    required this.priceWon,
    required this.slotsLeft,
    required this.avatarUrl,
    required this.artworkUrl,
  });

  /// 상세 페이지 라우팅용 커미션 ID
  final String commissionId;
  final String artistName;
  final String categoryTag;
  final int priceWon;
  final int slotsLeft;
  final String avatarUrl;
  final String artworkUrl;

  String get priceLabel => CommissionSample._formatWon(priceWon);
  String get statusLabel => '🟢 $slotsLeft슬롯 남음';
}

/// 탐색 탭 플레이스홀더 데이터
abstract final class ExploreDummyData {
  static const featuredBannerImage =
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=400&fit=crop';

  static const liveSlots = [
    LiveSlotSample(
      commissionId: 'live-slot-choco',
      artistName: '초코쌤',
      categoryTag: '두상/LD',
      priceWon: 25000,
      slotsLeft: 2,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&h=80&fit=crop',
      artworkUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=500&fit=crop',
    ),
    LiveSlotSample(
      commissionId: 'live-slot-miyu',
      artistName: '미유_Miyu',
      categoryTag: 'SD/치비',
      priceWon: 15000,
      slotsLeft: 1,
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop',
      artworkUrl:
          'https://images.unsplash.com/photo-1608889825105-e1125f4c28d2?w=400&h=480&fit=crop',
    ),
    LiveSlotSample(
      commissionId: 'live-slot-neoneo',
      artistName: '네오네오',
      categoryTag: '버튜버/Live2D',
      priceWon: 120000,
      slotsLeft: 3,
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop',
      artworkUrl:
          'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=400&h=520&fit=crop',
    ),
    LiveSlotSample(
      commissionId: 'live-slot-pixel',
      artistName: '하늘픽셀',
      categoryTag: '픽셀아트/로그',
      priceWon: 18000,
      slotsLeft: 2,
      avatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop',
      artworkUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
    ),
  ];

  static const categoryTags = [
    '#LD',
    '#SD',
    '#치비',
    '#반실사',
    '#캐릭터디자인',
    '#빠른마감',
    '#풀채색',
    '#두상',
    '#흉상',
    '#전신',
    '#로그',
    '#버튜버',
    '#일러스트',
    '#상업용',
    '#비상업용',
  ];

  static const gallerySamples = [
    CommissionSample(
      id: '1',
      imageUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=560&fit=crop',
      artistName: '초코쌤',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&h=80&fit=crop',
      startPriceWon: 35000,
      likeCount: 234,
      tags: ['#LD', '#풀채색'],
      aspectRatio: 0.72,
    ),
    CommissionSample(
      id: '2',
      imageUrl:
          'https://images.unsplash.com/photo-1608889825105-e1125f4c28d2?w=400&h=320&fit=crop',
      artistName: '미유_Miyu',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop',
      startPriceWon: 15000,
      likeCount: 1200,
      tags: ['#SD', '#치비'],
      aspectRatio: 1.25,
      isLiked: true,
    ),
    CommissionSample(
      id: '3',
      imageUrl:
          'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=400&h=520&fit=crop',
      artistName: '네오네오',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop',
      startPriceWon: 85000,
      likeCount: 89,
      tags: ['#버튜버', '#Live2D'],
      aspectRatio: 0.78,
    ),
    CommissionSample(
      id: '4',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop',
      artistName: '하늘픽셀',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop',
      startPriceWon: 18000,
      likeCount: 567,
      tags: ['#픽셀아트', '#로그'],
      aspectRatio: 1.0,
    ),
    CommissionSample(
      id: '5',
      imageUrl:
          'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=400&h=640&fit=crop',
      artistName: '루나린',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
      startPriceWon: 45000,
      likeCount: 310,
      tags: ['#반실사', '#전신'],
      aspectRatio: 0.65,
    ),
    CommissionSample(
      id: '6',
      imageUrl:
          'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=400&h=300&fit=crop',
      artistName: '사쿠라펜',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=80&h=80&fit=crop',
      startPriceWon: 22000,
      likeCount: 445,
      tags: ['#일러스트', '#두상'],
      aspectRatio: 1.35,
    ),
    CommissionSample(
      id: '7',
      imageUrl:
          'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=500&fit=crop',
      artistName: '모모캔',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=80&h=80&fit=crop',
      startPriceWon: 30000,
      likeCount: 78,
      tags: ['#캐릭터디자인', '#상업용'],
      aspectRatio: 0.82,
    ),
    CommissionSample(
      id: '8',
      imageUrl:
          'https://images.unsplash.com/photo-1515405295579-fa46feb02847?w=400&h=480&fit=crop',
      artistName: '별빛작가',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop',
      startPriceWon: 55000,
      likeCount: 892,
      tags: ['#흉상', '#풀채색'],
      aspectRatio: 0.88,
      isLiked: true,
    ),
  ];
}

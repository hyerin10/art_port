// 검색 탭 커미션 카드 데이터 모델

/// 마감 기한 필터 (남은 일수 기준)
enum SearchDeadlineFilter {
  sameDay,
  within7,
  within14,
  over14,
}

/// 열람 가능 연령 필터
enum SearchAgeFilter {
  allAges,
  adultNoGore,
  adultWithGore,
}

class SearchCommissionItem {
  const SearchCommissionItem({
    required this.id,
    required this.imageUrl,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.title,
    required this.tags,
    required this.startPriceWon,
    required this.likeCount,
    required this.hasSlot,
    required this.isAvailable,
    required this.sortOrder,
    required this.daysUntilDeadline,
    required this.ageRating,
    this.isLiked = false,
  });

  final String id;
  final String imageUrl;
  final String artistName;
  final String artistAvatarUrl;
  final String title;
  final List<String> tags;
  final int startPriceWon;
  final int likeCount;
  final bool hasSlot;
  final bool isAvailable;
  final int sortOrder;
  final int daysUntilDeadline;
  final SearchAgeFilter ageRating;
  final bool isLiked;

  bool matchesDeadline(SearchDeadlineFilter filter) {
    return switch (filter) {
      SearchDeadlineFilter.sameDay => daysUntilDeadline <= 0,
      SearchDeadlineFilter.within7 => daysUntilDeadline <= 7,
      SearchDeadlineFilter.within14 => daysUntilDeadline <= 14,
      SearchDeadlineFilter.over14 => daysUntilDeadline >= 14,
    };
  }

  bool matchesAge(SearchAgeFilter filter) => ageRating == filter;

  bool matchesPriceRange({int? minMan, int? maxMan}) {
    final minWon = minMan != null ? minMan * 10000 : null;
    final maxWon = maxMan != null ? maxMan * 10000 : null;
    if (minWon != null && startPriceWon < minWon) return false;
    if (maxWon != null && startPriceWon > maxWon) return false;
    return true;
  }

  String get priceLabel {
    final formatted = _formatWon(startPriceWon);
    return '$formatted~';
  }

  String get likeCountLabel => '$likeCount';

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().replaceAll('#', '');
    if (title.toLowerCase().contains(q)) return true;
    if (artistName.toLowerCase().contains(q)) return true;
    for (final tag in tags) {
      final t = tag.toLowerCase().replaceAll('#', '');
      if (t.contains(q) || q.contains(t)) return true;
    }
    return false;
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

/// 검색창 하단 '연관 인기 태그' 더미 데이터
abstract final class SearchPopularTags {
  static const labels = [
    '#LD',
    '#오마카세',
    '#SD',
    '#그림커미션',
    '#빠른마감',
    '#전신',
    '#두상',
  ];
}

abstract final class SearchDummyData {
  static const _avatar1 =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&h=80&fit=crop';
  static const _avatar2 =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop';
  static const _avatar3 =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop';
  static const _avatar4 =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop';
  static const _img1 =
      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=520&fit=crop';
  static const _img2 =
      'https://images.unsplash.com/photo-1608889825105-e1125f4c28d2?w=400&h=480&fit=crop';
  static const _img3 =
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&h=500&fit=crop';
  static const _img4 =
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=400&h=460&fit=crop';
  static const _img5 =
      'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=400&h=540&fit=crop';
  static const _img6 =
      'https://images.unsplash.com/photo-1612036782180-6f0b6cd7d37c?w=400&h=470&fit=crop';
  static const _img7 =
      'https://images.unsplash.com/photo-1618172193622-7e56f403d4f8?w=400&h=510&fit=crop';
  static const _img8 =
      'https://images.unsplash.com/photo-1620641788421-7aad1b1ad12b?w=400&h=490&fit=crop';

  static const commissions = [
    SearchCommissionItem(
      id: 'search-1',
      imageUrl: _img1,
      artistName: '초코쌤',
      artistAvatarUrl: _avatar1,
      title: '일러스트 한 장 타입',
      tags: ['#LD', '#오마카세', '#반신샷'],
      startPriceWon: 35000,
      likeCount: 234,
      hasSlot: true,
      isAvailable: true,
      sortOrder: 0,
      daysUntilDeadline: 0,
      ageRating: SearchAgeFilter.allAges,
    ),
    SearchCommissionItem(
      id: 'search-2',
      imageUrl: _img2,
      artistName: '미유_Miyu',
      artistAvatarUrl: _avatar2,
      title: 'MD/SD 커미션',
      tags: ['#SD', '#캐릭터', '#굿즈'],
      startPriceWon: 20000,
      likeCount: 189,
      hasSlot: true,
      isAvailable: true,
      sortOrder: 1,
      daysUntilDeadline: 5,
      ageRating: SearchAgeFilter.allAges,
      isLiked: true,
    ),
    SearchCommissionItem(
      id: 'search-3',
      imageUrl: _img3,
      artistName: '네오네오',
      artistAvatarUrl: _avatar3,
      title: '애니메이션 두상 커미션',
      tags: ['#두상', '#애니풍'],
      startPriceWon: 45000,
      likeCount: 412,
      hasSlot: false,
      isAvailable: true,
      sortOrder: 2,
      daysUntilDeadline: 12,
      ageRating: SearchAgeFilter.adultNoGore,
    ),
    SearchCommissionItem(
      id: 'search-4',
      imageUrl: _img4,
      artistName: '루나픽셀',
      artistAvatarUrl: _avatar4,
      title: '전신 일러스트 (배경 포함)',
      tags: ['#전신', '#배경', '#판타지'],
      startPriceWon: 80000,
      likeCount: 567,
      hasSlot: true,
      isAvailable: false,
      sortOrder: 3,
      daysUntilDeadline: 20,
      ageRating: SearchAgeFilter.adultWithGore,
    ),
    SearchCommissionItem(
      id: 'search-5',
      imageUrl: _img5,
      artistName: '별하늘님',
      artistAvatarUrl: _avatar1,
      title: 'LD 미소녀 일러스트',
      tags: ['#LD', '#미소녀', '#파스텔'],
      startPriceWon: 55000,
      likeCount: 301,
      hasSlot: true,
      isAvailable: true,
      sortOrder: 4,
      daysUntilDeadline: 3,
      ageRating: SearchAgeFilter.allAges,
    ),
    SearchCommissionItem(
      id: 'search-6',
      imageUrl: _img6,
      artistName: '하늘조각',
      artistAvatarUrl: _avatar2,
      title: '치비 SD 캐릭터 분양',
      tags: ['#SD', '#치비'],
      startPriceWon: 18000,
      likeCount: 156,
      hasSlot: true,
      isAvailable: true,
      sortOrder: 5,
      daysUntilDeadline: 7,
      ageRating: SearchAgeFilter.allAges,
    ),
    SearchCommissionItem(
      id: 'search-7',
      imageUrl: _img7,
      artistName: '소라드로우',
      artistAvatarUrl: _avatar3,
      title: '반신 일러스트 커미션',
      tags: ['#반신', '#일러스트', '#오마카세', '#감성'],
      startPriceWon: 42000,
      likeCount: 278,
      hasSlot: false,
      isAvailable: false,
      sortOrder: 6,
      daysUntilDeadline: 14,
      ageRating: SearchAgeFilter.adultNoGore,
    ),
    SearchCommissionItem(
      id: 'search-8',
      imageUrl: _img8,
      artistName: '민트캣',
      artistAvatarUrl: _avatar4,
      title: '굿즈용 투명 배경 일러',
      tags: ['#굿즈', '#투명배경'],
      startPriceWon: 30000,
      likeCount: 198,
      hasSlot: true,
      isAvailable: true,
      sortOrder: 7,
      daysUntilDeadline: 30,
      ageRating: SearchAgeFilter.adultWithGore,
    ),
  ];
}

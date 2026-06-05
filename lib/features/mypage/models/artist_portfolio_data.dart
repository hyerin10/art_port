/// 포트폴리오 이미지 항목
class PortfolioImageItem {
  const PortfolioImageItem({
    required this.id,
    this.localPath,
    this.networkUrl,
  });

  final String id;
  final String? localPath;
  final String? networkUrl;

  String? get displaySource => localPath ?? networkUrl;

  PortfolioImageItem copyWith({
    String? id,
    String? localPath,
    String? networkUrl,
    bool clearLocalPath = false,
    bool clearNetworkUrl = false,
  }) {
    return PortfolioImageItem(
      id: id ?? this.id,
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      networkUrl: clearNetworkUrl ? null : (networkUrl ?? this.networkUrl),
    );
  }
}

/// 아티스트 프로필/포트폴리오 편집 폼 상태
class ArtistPortfolioEditState {
  const ArtistPortfolioEditState({
    this.backgroundLocalPath,
    this.backgroundNetworkUrl,
    this.avatarLocalPath,
    this.avatarNetworkUrl,
    required this.nickname,
    required this.oneLineIntro,
    required this.portfolioImages,
    required this.selectedStyles,
    required this.selectedTools,
    required this.detailedIntro,
    required this.workNotice,
    required this.twitterHandle,
    required this.instagramHandle,
    required this.websiteUrl,
    this.activePortfolioIndex,
    this.isSaving = false,
  });

  static const int maxPortfolioCount = 12;
  static const int maxOneLineIntro = 100;
  static const int maxDetailedIntro = 1000;
  static const int maxWorkNotice = 500;

  static const List<String> styleOptions = [
    '애니메이션',
    '세미 리얼',
    'SD 캐릭터',
    '게임 컨셉아트',
    '웹툰',
    '인물화',
  ];

  static const List<String> toolOptions = [
    'Clip Studio',
    'Photoshop',
    'Procreate',
    'iPad',
    'SAI',
    'MediBang',
  ];

  final String? backgroundLocalPath;
  final String? backgroundNetworkUrl;
  final String? avatarLocalPath;
  final String? avatarNetworkUrl;
  final String nickname;
  final String oneLineIntro;
  final List<PortfolioImageItem> portfolioImages;
  final Set<String> selectedStyles;
  final Set<String> selectedTools;
  final String detailedIntro;
  final String workNotice;
  final String twitterHandle;
  final String instagramHandle;
  final String websiteUrl;
  final int? activePortfolioIndex;
  final bool isSaving;

  ArtistPortfolioEditState copyWith({
    String? backgroundLocalPath,
    String? backgroundNetworkUrl,
    String? avatarLocalPath,
    String? avatarNetworkUrl,
    String? nickname,
    String? oneLineIntro,
    List<PortfolioImageItem>? portfolioImages,
    Set<String>? selectedStyles,
    Set<String>? selectedTools,
    String? detailedIntro,
    String? workNotice,
    String? twitterHandle,
    String? instagramHandle,
    String? websiteUrl,
    int? activePortfolioIndex,
    bool clearActivePortfolioIndex = false,
    bool? isSaving,
    bool clearBackgroundLocalPath = false,
    bool clearBackgroundNetworkUrl = false,
    bool clearAvatarLocalPath = false,
    bool clearAvatarNetworkUrl = false,
  }) {
    return ArtistPortfolioEditState(
      backgroundLocalPath: clearBackgroundLocalPath
          ? null
          : (backgroundLocalPath ?? this.backgroundLocalPath),
      backgroundNetworkUrl: clearBackgroundNetworkUrl
          ? null
          : (backgroundNetworkUrl ?? this.backgroundNetworkUrl),
      avatarLocalPath:
          clearAvatarLocalPath ? null : (avatarLocalPath ?? this.avatarLocalPath),
      avatarNetworkUrl: clearAvatarNetworkUrl
          ? null
          : (avatarNetworkUrl ?? this.avatarNetworkUrl),
      nickname: nickname ?? this.nickname,
      oneLineIntro: oneLineIntro ?? this.oneLineIntro,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      selectedStyles: selectedStyles ?? this.selectedStyles,
      selectedTools: selectedTools ?? this.selectedTools,
      detailedIntro: detailedIntro ?? this.detailedIntro,
      workNotice: workNotice ?? this.workNotice,
      twitterHandle: twitterHandle ?? this.twitterHandle,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      activePortfolioIndex: clearActivePortfolioIndex
          ? null
          : (activePortfolioIndex ?? this.activePortfolioIndex),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'oneLineIntro': oneLineIntro,
      'backgroundImage': backgroundLocalPath ?? backgroundNetworkUrl,
      'avatarImage': avatarLocalPath ?? avatarNetworkUrl,
      'portfolioImages': portfolioImages
          .map((item) => item.localPath ?? item.networkUrl)
          .toList(),
      'selectedStyles': selectedStyles.toList(),
      'selectedTools': selectedTools.toList(),
      'detailedIntro': detailedIntro,
      'workNotice': workNotice,
      'sns': {
        'twitter': twitterHandle,
        'instagram': instagramHandle,
        'website': websiteUrl,
      },
    };
  }
}

/// 작가 활동 신청 폼 단계
enum ArtistApplicationStep {
  basicInfo,
  portfolio,
  commission,
  terms,
}

extension ArtistApplicationStepX on ArtistApplicationStep {
  int get index => ArtistApplicationStep.values.indexOf(this);

  String get label {
    switch (this) {
      case ArtistApplicationStep.basicInfo:
        return '기본 정보';
      case ArtistApplicationStep.portfolio:
        return '포트폴리오';
      case ArtistApplicationStep.commission:
        return '커미션 설정';
      case ArtistApplicationStep.terms:
        return '약관 동의';
    }
  }

  String get titleKo {
    switch (this) {
      case ArtistApplicationStep.basicInfo:
        return '기본 정보 및 정산';
      case ArtistApplicationStep.portfolio:
        return '포트폴리오 및 스타일';
      case ArtistApplicationStep.commission:
        return '커미션 설정 및 안내';
      case ArtistApplicationStep.terms:
        return '약관 동의 및 신청';
    }
  }

  String get titleEn {
    switch (this) {
      case ArtistApplicationStep.basicInfo:
        return 'Artist Profile & Settlement';
      case ArtistApplicationStep.portfolio:
        return 'Portfolio & Style';
      case ArtistApplicationStep.commission:
        return 'Commission Pricing & Guidelines';
      case ArtistApplicationStep.terms:
        return 'Agreement & Submit';
    }
  }
}

/// 커미션 타입 항목
class CommissionTypeEntry {
  const CommissionTypeEntry({
    this.typeName = '',
    this.basePrice = '',
    this.description = '',
  });

  final String typeName;
  final String basePrice;
  final String description;

  CommissionTypeEntry copyWith({
    String? typeName,
    String? basePrice,
    String? description,
  }) {
    return CommissionTypeEntry(
      typeName: typeName ?? this.typeName,
      basePrice: basePrice ?? this.basePrice,
      description: description ?? this.description,
    );
  }

  bool get isValid =>
      typeName.trim().isNotEmpty && basePrice.trim().isNotEmpty;
}

/// 작가 활동 신청 폼 데이터
class ArtistApplicationData {
  const ArtistApplicationData({
    this.artistName = '',
    this.bankName,
    this.accountNumber = '',
    this.accountHolder = '',
    this.portfolioImagePaths = const [],
    this.verificationFilePaths = const [],
    this.styleTags = const {},
    this.commissionTypes = const [CommissionTypeEntry()],
    this.maxWorkDays = 14,
    this.roughRevisionCount = 2,
    this.finalRevisionCount = 1,
    this.nonCommercial = true,
    this.commercialStreaming = false,
    this.copyrightTransfer = false,
    this.termsAgreed = false,
  });

  final String artistName;
  final String? bankName;
  final String accountNumber;
  final String accountHolder;
  final List<String> portfolioImagePaths;
  final List<String> verificationFilePaths;
  final Set<String> styleTags;
  final List<CommissionTypeEntry> commissionTypes;
  final int maxWorkDays;
  final int roughRevisionCount;
  final int finalRevisionCount;
  final bool nonCommercial;
  final bool commercialStreaming;
  final bool copyrightTransfer;
  final bool termsAgreed;

  static const styleTagOptions = [
    '캐릭터',
    '배경',
    '웹툰',
    '세미 리얼',
    'SD/LD',
    '애니메',
    '인물화',
    '컨셉 아트',
  ];

  static const bankOptions = [
    'KB국민은행',
    '신한은행',
    '우리은행',
    '하나은행',
    'NH농협은행',
    'IBK기업은행',
    '카카오뱅크',
    '토스뱅크',
    'SC제일은행',
    '씨티은행',
    'KDB산업은행',
    '새마을금고',
    '신협',
    '우체국',
  ];

  static const termsText = '''
제1조 (목적)
본 약관은 ArtPort(이하 '플랫폼')에서 작가로 활동하는 회원(이하 '작가')의 권리와 의무, 서비스 이용 조건을 규정함을 목적으로 합니다.

제2조 (저작권)
1. 작가가 창작한 결과물의 저작권은 원칙적으로 작가에게 귀속됩니다.
2. 의뢰인과 작가 간 별도 합의가 있는 경우, 해당 합의 내용을 우선 적용합니다.
3. 플랫폼은 서비스 운영 및 홍보 목적으로 작가의 포트폴리오를 제한적으로 노출할 수 있습니다.

제3조 (정산)
1. 작가는 플랫폼에 등록한 정산 계좌로 대금을 수령합니다.
2. 정산은 거래 완료 후 플랫폼 정책에 따른 주기로 지급됩니다.
3. 작가는 정확한 계좌 정보를 제공할 의무가 있습니다.

제4조 (작가의 의무)
1. 작가는 허위 포트폴리오 또는 타인의 작업물을 등록해서는 안 됩니다.
2. 작가는 약속된 기한 내에 성실히 작업을 수행해야 합니다.
3. 작가는 의뢰인과의 분쟁 발생 시 플랫폼의 중재 절차에 협조해야 합니다.

제5조 (플랫폼의 권리)
1. 플랫폼은 작가 신청서를 심사하여 승인 여부를 결정할 수 있습니다.
2. 약관 위반 시 작가 활동 자격을 제한하거나 해지할 수 있습니다.
''';

  ArtistApplicationData copyWith({
    String? artistName,
    String? bankName,
    bool clearBankName = false,
    String? accountNumber,
    String? accountHolder,
    List<String>? portfolioImagePaths,
    List<String>? verificationFilePaths,
    Set<String>? styleTags,
    List<CommissionTypeEntry>? commissionTypes,
    int? maxWorkDays,
    int? roughRevisionCount,
    int? finalRevisionCount,
    bool? nonCommercial,
    bool? commercialStreaming,
    bool? copyrightTransfer,
    bool? termsAgreed,
  }) {
    return ArtistApplicationData(
      artistName: artistName ?? this.artistName,
      bankName: clearBankName ? null : (bankName ?? this.bankName),
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      portfolioImagePaths: portfolioImagePaths ?? this.portfolioImagePaths,
      verificationFilePaths:
          verificationFilePaths ?? this.verificationFilePaths,
      styleTags: styleTags ?? this.styleTags,
      commissionTypes: commissionTypes ?? this.commissionTypes,
      maxWorkDays: maxWorkDays ?? this.maxWorkDays,
      roughRevisionCount: roughRevisionCount ?? this.roughRevisionCount,
      finalRevisionCount: finalRevisionCount ?? this.finalRevisionCount,
      nonCommercial: nonCommercial ?? this.nonCommercial,
      commercialStreaming: commercialStreaming ?? this.commercialStreaming,
      copyrightTransfer: copyrightTransfer ?? this.copyrightTransfer,
      termsAgreed: termsAgreed ?? this.termsAgreed,
    );
  }

  bool isStepValid(ArtistApplicationStep step) {
    switch (step) {
      case ArtistApplicationStep.basicInfo:
        return artistName.trim().isNotEmpty &&
            bankName != null &&
            bankName!.isNotEmpty &&
            accountNumber.trim().isNotEmpty &&
            RegExp(r'^\d+$').hasMatch(accountNumber.trim()) &&
            accountHolder.trim().isNotEmpty;
      case ArtistApplicationStep.portfolio:
        return portfolioImagePaths.length >= 3 &&
            portfolioImagePaths.length <= 5 &&
            verificationFilePaths.isNotEmpty &&
            styleTags.isNotEmpty;
      case ArtistApplicationStep.commission:
        return commissionTypes.any((t) => t.isValid) &&
            (nonCommercial || commercialStreaming || copyrightTransfer);
      case ArtistApplicationStep.terms:
        return termsAgreed;
    }
  }
}

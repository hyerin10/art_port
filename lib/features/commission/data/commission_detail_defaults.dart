import 'package:art_port/features/commission/models/commission_price_option.dart';

/// 커미션 상세 더미/매핑용 기본값
abstract final class CommissionDetailDefaults {
  static const workScopeItems = [
    '캐릭터 1인 기준 가격입니다',
    '배경은 단색 또는 간단한 효과로 제공됩니다',
    '상업용 사용 시 추가 요금이 발생합니다',
  ];

  static const revisionPolicyItems = [
    '러프 단계: 무제한 수정',
    '채색 단계: 2회 수정 가능',
    '완성 후: 색감 조정만 가능',
  ];

  static const noticeText =
      '커미션 신청 전 작가의 약관을 꼭 확인해주세요. 결제는 작가와 협의 후 진행됩니다.';

  static String introText(String artistName) =>
      '안녕하세요! $artistName입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.';

  static List<CommissionPriceOption> priceOptions(int startPrice) {
    return [
      CommissionPriceOption(
        label: '두상',
        subtitle: 'Bust',
        priceWon: startPrice,
        isPopular: true,
      ),
      CommissionPriceOption(
        label: '흉상',
        subtitle: 'Half Body',
        priceWon: (startPrice * 1.5).round(),
      ),
      CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: startPrice * 2,
      ),
    ];
  }

  static String alternateImage(String id, int index) {
    const pool = [
      'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=800&h=800&fit=crop',
    ];
    return pool[(id.hashCode.abs() + index) % pool.length];
  }
}

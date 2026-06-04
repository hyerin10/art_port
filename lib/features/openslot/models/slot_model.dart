// 커미션 슬롯 데이터 모델

class SlotModel {
  const SlotModel({
    required this.id,
    required this.title,
    required this.subType,
    required this.priceWon,
    required this.currentSlots,
    required this.maxSlots,
    required this.durationDays,
  });

  final String id;
  final String title;
  final String subType;
  final int priceWon;
  final int currentSlots;
  final int maxSlots;
  final int durationDays;

  bool get isFull => currentSlots >= maxSlots;

  double get fillRatio {
    if (maxSlots <= 0) return 0;
    return (currentSlots.clamp(0, maxSlots)) / maxSlots;
  }

  String get priceLabel => '₩ ${_formatWon(priceWon)} ~';

  String get slotsLabel => '$currentSlots/$maxSlots 슬롯';

  String get durationLabel => '$durationDays일 소요';

  SlotModel copyWith({
    String? id,
    String? title,
    String? subType,
    int? priceWon,
    int? currentSlots,
    int? maxSlots,
    int? durationDays,
  }) {
    return SlotModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subType: subType ?? this.subType,
      priceWon: priceWon ?? this.priceWon,
      currentSlots: currentSlots ?? this.currentSlots,
      maxSlots: maxSlots ?? this.maxSlots,
      durationDays: durationDays ?? this.durationDays,
    );
  }

  static String _formatWon(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class OpenSlotDashboardStats {
  const OpenSlotDashboardStats({
    required this.activeSlotCount,
    required this.ordersInProgress,
    required this.monthlyEarningsWon,
  });

  final int activeSlotCount;
  final int ordersInProgress;
  final int monthlyEarningsWon;

  String get earningsLabel {
    final s = monthlyEarningsWon.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()}원';
  }
}

abstract final class SlotDummyData {
  static const initialSlots = [
    SlotModel(
      id: 'slot-1',
      title: 'LD 미소녀 일러스트 커미션',
      subType: '두상/흉상',
      priceWon: 35000,
      currentSlots: 1,
      maxSlots: 3,
      durationDays: 5,
    ),
    SlotModel(
      id: 'slot-2',
      title: '귀여운 SD 캐릭터 분양',
      subType: '전신/로그',
      priceWon: 20000,
      currentSlots: 3,
      maxSlots: 5,
      durationDays: 3,
    ),
    SlotModel(
      id: 'slot-3',
      title: '애니메이션 두상 커미션',
      subType: '두상',
      priceWon: 30000,
      currentSlots: 0,
      maxSlots: 2,
      durationDays: 4,
    ),
    SlotModel(
      id: 'slot-4',
      title: '전신 캐릭터 아트',
      subType: '전신',
      priceWon: 65000,
      currentSlots: 2,
      maxSlots: 2,
      durationDays: 7,
    ),
  ];
}

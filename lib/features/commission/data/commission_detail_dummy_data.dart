import 'package:art_port/features/commission/data/commission_detail_defaults.dart';
import 'package:art_port/features/commission/data/commission_detail_mapper.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/search/models/search_commission.dart';

/// 커미션 상세 더미 데이터 — ID 기반 조회
abstract final class CommissionDetailDummyData {
  static const _pixelDreams = CommissionDetail(
    id: 'pixel-dreams',
    title: '세미리얼 초상화',
    imageUrls: [
      'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=800&h=800&fit=crop',
    ],
    hasSlotOpen: true,
    artistName: 'PixelDreams',
    artistAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
    artistProfileId: '',
    rating: 4.9,
    reviewCount: 128,
    tags: ['#MD', '#세미리얼', '#감성'],
    estimatedDays: 14,
    completedCount: 156,
    responseRatePercent: 98,
    priceOptions: [
      CommissionPriceOption(
        label: '두상',
        subtitle: 'Bust',
        priceWon: 50000,
        isPopular: true,
      ),
      CommissionPriceOption(
        label: '흉상',
        subtitle: 'Half Body',
        priceWon: 75000,
      ),
      CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: 100000,
      ),
    ],
    introText: '안녕하세요! PixelDreams입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
    workScopeItems: CommissionDetailDefaults.workScopeItems,
    revisionPolicyItems: CommissionDetailDefaults.revisionPolicyItems,
    noticeText: CommissionDetailDefaults.noticeText,
  );

  static const _neoNeo = CommissionDetail(
    id: 'live-slot-neoneo',
    title: '애니메이션 두상 커미션',
    imageUrls: [
      'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=800&h=800&fit=crop',
    ],
    hasSlotOpen: true,
    artistName: '네오네오',
    artistAvatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop',
    artistProfileId: '',
    rating: 4.9,
    reviewCount: 133,
    tags: ['#두상', '#애니풍'],
    estimatedDays: 12,
    completedCount: 217,
    responseRatePercent: 91,
    priceOptions: [
      CommissionPriceOption(
        label: '두상',
        subtitle: 'Bust',
        priceWon: 45000,
        isPopular: true,
      ),
      CommissionPriceOption(
        label: '흉상',
        subtitle: 'Half Body',
        priceWon: 67500,
      ),
      CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: 90000,
      ),
    ],
    introText: '안녕하세요! 네오네오입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
    workScopeItems: CommissionDetailDefaults.workScopeItems,
    revisionPolicyItems: CommissionDetailDefaults.revisionPolicyItems,
    noticeText: CommissionDetailDefaults.noticeText,
  );

  static final Map<String, CommissionDetail> _overrides = {
    'pixel-dreams': _pixelDreams,
    '1': _pixelDreams.copyWith(id: '1'),
    'search-1': _pixelDreams.copyWith(id: 'search-1', title: '일러스트 한 장 타입'),
    'live-slot-neoneo': _neoNeo,
    'search-3': _neoNeo.copyWith(id: 'search-3'),
  };

  static CommissionDetail? forId(String commissionId) {
    final override = _overrides[commissionId];
    if (override != null) return override;

    for (final slot in ExploreDummyData.liveSlots) {
      if (slot.commissionId == commissionId) {
        return CommissionDetailMapper.fromLiveSlot(slot);
      }
    }

    for (final sample in ExploreDummyData.gallerySamples) {
      if (sample.id == commissionId) {
        return CommissionDetailMapper.fromExploreSample(sample);
      }
    }

    for (final item in SearchDummyData.commissions) {
      if (item.id == commissionId) {
        return CommissionDetailMapper.fromSearchItem(item);
      }
    }

    return null;
  }
}

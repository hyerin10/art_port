import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/artist_profile/artist_profile_screen.dart';
import 'package:art_port/features/commission/commission_detail_screen.dart';
import 'package:art_port/features/commission/data/commission_catalog.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 탐색(Explore) 탭 내부 스크롤 콘텐츠
class ExploreView extends ConsumerWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(commissionCatalogProvider);

    return ApiAsyncBody<CommissionCatalog>(
      value: catalog,
      onRetry: () => ref.invalidate(commissionCatalogProvider),
      errorMessage: '작품 목록을 불러오지 못했습니다.',
      builder: (data) {
        return ScrollConfiguration(
          behavior: const _ArtPortScrollBehavior(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromoBannerCarousel(slides: _promoSlidesFrom(data)),
                const SizedBox(height: 24),
                _LiveSlotsSection(slots: data.liveSlots),
                const SizedBox(height: 28),
                _DiscoverHeader(tags: data.categoryTags),
                const SizedBox(height: 16),
                if (data.gallerySamples.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        '등록된 커미션이 없습니다.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  _TwoColumnGallery(samples: data.gallerySamples),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<_PromoBannerSlide> _promoSlidesFrom(CommissionCatalog data) {
  final images = data.promoBannerImages;
  final featuredArtist = data.artists.isNotEmpty ? data.artists.first : null;
  final urgentSlot = data.liveSlots.isNotEmpty ? data.liveSlots.first : null;
  final seasonSample =
      data.gallerySamples.isNotEmpty ? data.gallerySamples.first : null;

  return [
    _PromoBannerSlide(
      title: '이번 주 주목받는 일러스트레이터',
      subtitle: featuredArtist == null
          ? '당신의 최애캐를 완벽한 퀄리티로 만나보세요'
          : '${featuredArtist.displayName} 작가의 대표작을 만나보세요',
      ctaLabel: '작가 보기',
      imageUrl: images[0],
      onTap: featuredArtist == null
          ? null
          : (context) => ArtistProfileScreen.open(
                context,
                artistId: featuredArtist.id,
              ),
    ),
    _PromoBannerSlide(
      title: '슬롯 마감·오픈 알림',
      subtitle: urgentSlot == null
          ? '지금 열려 있는 커미션 슬롯을 확인해 보세요'
          : '${urgentSlot.artistName} · ${urgentSlot.slotsLeft}슬롯 남음',
      ctaLabel: '슬롯 확인',
      imageUrl: images[1],
      onTap: urgentSlot == null
          ? null
          : (context) => CommissionDetailScreen.open(
                context,
                commissionId: urgentSlot.commissionId,
              ),
    ),
    _PromoBannerSlide(
      title: '시즌 테마 의뢰',
      subtitle: '졸업·기념일·시즌 일러스트, 지금이 타이밍',
      ctaLabel: '테마 둘러보기',
      imageUrl: images[2],
      onTap: seasonSample == null
          ? null
          : (context) => CommissionDetailScreen.open(
                context,
                commissionId: seasonSample.id,
              ),
    ),
  ];
}

class _ArtPortScrollBehavior extends ScrollBehavior {
  const _ArtPortScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ─── Promo Banner Carousel ─────────────────────────────────────────────────

class _PromoBannerSlide {
  const _PromoBannerSlide({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageUrl;
  final void Function(BuildContext context)? onTap;
}

class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel({required this.slides});

  final List<_PromoBannerSlide> slides;

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 196,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _PromoBannerPage(slide: slides[index]);
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = i == _currentPage;
                  return GestureDetector(
                    onTap: () => _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerPage extends StatelessWidget {
  const _PromoBannerPage({required this.slide});

  final _PromoBannerSlide slide;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          slide.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const ColoredBox(color: AppColors.primarySoft),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.62),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                slide.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.3,
                ),
              ),
              const Spacer(),
              if (slide.onTap != null)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => slide.onTap!(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Text(
                        slide.ctaLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandNavy,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Live Slots ─────────────────────────────────────────────────────────────

class _LiveSlotsSection extends StatelessWidget {
  const _LiveSlotsSection({required this.slots});

  final List<LiveSlotSample> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '실시간 슬롯 현황',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: const Text(
                '전체보기 >',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: slots.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _LiveSlotCard(slot: slots[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _LiveSlotCard extends StatelessWidget {
  const _LiveSlotCard({required this.slot});

  final LiveSlotSample slot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => CommissionDetailScreen.open(
          context,
          commissionId: slot.commissionId,
        ),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 148,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  slot.artworkUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.chipBackground,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      slot.priceLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.chipBackground,
                            backgroundImage: NetworkImage(slot.avatarUrl),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              slot.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            slot.categoryTag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            slot.statusLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onlineStatus,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Discover Artworks ──────────────────────────────────────────────────────

class _TwoColumnGallery extends StatelessWidget {
  const _TwoColumnGallery({required this.samples});

  final List<CommissionSample> samples;

  @override
  Widget build(BuildContext context) {
    final leftColumn = <CommissionSample>[];
    final rightColumn = <CommissionSample>[];

    for (var i = 0; i < samples.length; i++) {
      if (i.isEven) {
        leftColumn.add(samples[i]);
      } else {
        rightColumn.add(samples[i]);
      }
    }

    Widget buildColumn(List<CommissionSample> columnSamples) {
      return Column(
        children: [
          for (var i = 0; i < columnSamples.length; i++) ...[
            _GalleryCard(sample: columnSamples[i]),
            if (i < columnSamples.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildColumn(leftColumn)),
        const SizedBox(width: 12),
        Expanded(child: buildColumn(rightColumn)),
      ],
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '작품 탐색',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return _CategoryChip(label: tag);
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryCard extends ConsumerWidget {
  const _GalleryCard({required this.sample});

  final CommissionSample sample;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(likedCommissionIdsProvider).contains(sample.id);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            CommissionDetailScreen.open(context, commissionId: sample.id),
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: sample.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  sample.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.primarySoft,
                    child: Icon(
                      Icons.brush_outlined,
                      color: AppColors.primary.withValues(alpha: 0.5),
                      size: 32,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sample.priceLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: AppColors.chipBackground,
                            backgroundImage: NetworkImage(
                              sample.artistAvatarUrl,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              sample.artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => toggleLikedCommission(
                              ref: ref,
                              context: context,
                              commissionTypeId: sample.id,
                            ),
                            child: Icon(
                              isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 16,
                              color: isLiked
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            sample.likeCountLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

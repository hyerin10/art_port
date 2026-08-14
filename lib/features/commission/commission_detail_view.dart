import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/artist_profile/artist_profile_screen.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/auth/widgets/login_required_dialog.dart';
import 'package:art_port/features/commission/commission_apply_screen.dart';
import 'package:art_port/features/commission/commission_detail_providers.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/commission/widgets/commission_detail_bottom_bar.dart';
import 'package:art_port/features/commission/widgets/commission_detail_header.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:art_port/features/mypage/models/followed_artist.dart';
import 'package:art_port/providers/followed_artists_provider.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _warningBackground = Color(0xFFFFFBE6);
const _warningBorder = Color(0xFFFFF1B8);
const _warningAccent = Color(0xFFD48806);

class CommissionDetailView extends ConsumerStatefulWidget {
  const CommissionDetailView({super.key, required this.commissionId});

  final String commissionId;

  @override
  ConsumerState<CommissionDetailView> createState() =>
      _CommissionDetailViewState();
}

class _CommissionDetailViewState extends ConsumerState<CommissionDetailView> {
  int? _selectedOptionIndex;

  int _defaultOptionIndex(CommissionDetail detail) {
    final popularIndex = detail.priceOptions.indexWhere(
      (option) => option.isPopular,
    );
    return popularIndex >= 0 ? popularIndex : 0;
  }

  Future<void> _onApplyTap(CommissionDetail detail) async {
    final isLoggedIn = ref.read(isLoggedInProvider);
    if (!isLoggedIn) {
      await showLoginRequiredDialog(context);
      return;
    }

    final index = _selectedOptionIndex ?? _defaultOptionIndex(detail);
    if (detail.priceOptions.isEmpty) return;
    final selectedOption = detail.priceOptions[index];

    CommissionApplyScreen.open(
      context,
      args: CommissionApplyArgs(
        commissionId: detail.id,
        commissionTitle: detail.title,
        artistName: detail.artistName,
        selectedOption: selectedOption,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      commissionDetailProvider(widget.commissionId),
    );
    final isLiked = ref
        .watch(likedCommissionIdsProvider)
        .contains(widget.commissionId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ApiAsyncBody(
        value: detailAsync,
        onRetry: () =>
            ref.invalidate(commissionDetailProvider(widget.commissionId)),
        errorMessage: '커미션을 불러오지 못했습니다.',
        builder: (detail) {
          if (detail == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Column(
                children: [
                  CommissionDetailHeader(
                    onBack: () => Navigator.of(context).pop(),
                    isLiked: false,
                    onLikeTap: () {},
                    onShareTap: () {},
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '커미션을 찾을 수 없습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('돌아가기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final selectedIndex =
              _selectedOptionIndex ?? _defaultOptionIndex(detail);
          final selectedOption = detail.priceOptions.isEmpty
              ? const CommissionPriceOption(label: '기본', priceWon: 0)
              : detail.priceOptions[selectedIndex];

          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                CommissionDetailHeader(
                  onBack: () => Navigator.of(context).pop(),
                  isLiked: isLiked,
                  onLikeTap: () => toggleLikedCommission(
                    ref: ref,
                    context: context,
                    commissionTypeId: widget.commissionId,
                  ),
                  onShareTap: () => AppToast.show(
                    ScaffoldMessenger.of(context),
                    message: '공유 링크를 준비 중입니다.',
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      ScrollConfiguration(
                        behavior: const _CommissionDetailScrollBehavior(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 88),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ImageCarousel(detail: detail),
                              _ArtistProfileSection(detail: detail),
                              const _SectionDivider(),
                              _TitleAndTagsSection(detail: detail),
                              const SizedBox(height: 20),
                              _InfoGridSection(detail: detail),
                              const _SectionDivider(),
                              _PriceOptionsSection(
                                options: detail.priceOptions,
                                selectedIndex: selectedIndex,
                                onOptionSelected: (index) => setState(
                                  () => _selectedOptionIndex = index,
                                ),
                              ),
                              const _SectionDivider(),
                              _WorkDescriptionSection(detail: detail),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  24,
                                ),
                                child: _NoticeBox(text: detail.noticeText),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: CommissionDetailBottomBar(
                          selectedOption: selectedOption,
                          onApplyTap: () => _onApplyTap(detail),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: ArtPortBottomNav(
              onTabSelected: (index) {
                ref.read(currentTabProvider.notifier).selectTab(index);
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}

class _CommissionDetailScrollBehavior extends ScrollBehavior {
  const _CommissionDetailScrollBehavior();

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

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, thickness: 1, color: AppColors.borderLight),
    );
  }
}

// ─── Image Carousel ───────────────────────────────────────────────────────────

class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.detail});

  final CommissionDetail detail;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
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
    final images = widget.detail.imageUrls;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            ColoredBox(
              color: AppColors.primarySoft,
              child: Icon(
                Icons.image_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: AppColors.primarySoft,
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                );
              },
            ),
          if (widget.detail.hasSlotOpen)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onlineStatus,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.detail.slotStatusLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final active = index == _currentPage;
                return AnimatedContainer(
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
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Artist Profile ───────────────────────────────────────────────────────────

class _ArtistProfileSection extends ConsumerWidget {
  const _ArtistProfileSection({required this.detail});

  final CommissionDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistId = detail.artistProfileId.isNotEmpty
        ? detail.artistProfileId
        : ArtistCatalog.idForName(detail.artistName);
    final reviewStats = detail.artistUserId.isEmpty
        ? null
        : ref.watch(artistReviewStatsProvider(detail.artistUserId)).valueOrNull;
    // 프로필에 캐시된 reviewCount(시드 23 등) 대신 실제 리뷰 목록 개수를 쓴다.
    final ratingLabel = reviewStats?.detailLabel ??
        (detail.artistUserId.isEmpty
            ? detail.ratingLabel
            : detail.rating.toStringAsFixed(1));
    final followUserId = detail.artistUserId;
    final isSelf =
        followUserId.isNotEmpty &&
        ref.watch(currentUserIdProvider) == followUserId;
    final isFollowing =
        followUserId.isNotEmpty &&
        ref.watch(followedArtistIdsProvider).contains(followUserId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    ArtistProfileScreen.open(context, artistId: artistId),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.chipBackground,
                        backgroundImage: NetworkImage(detail.artistAvatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.artistName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  ratingLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                    height: 1.2,
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
          ),
          if (!isSelf)
            Material(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(isFollowing ? 20 : 10),
              child: InkWell(
                onTap: followUserId.isEmpty
                    ? null
                    : () => toggleFollowedArtist(
                        ref: ref,
                        context: context,
                        followingUserId: followUserId,
                        artistProfileId: detail.artistProfileId,
                      ),
                borderRadius: BorderRadius.circular(isFollowing ? 20 : 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    isFollowing ? '팔로잉' : '팔로우',
                    style: TextStyle(
                      fontSize: isFollowing ? 12 : 13,
                      fontWeight: FontWeight.w700,
                      color: isFollowing
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Title & Tags ───────────────────────────────────────────────────────────

class _TitleAndTagsSection extends StatelessWidget {
  const _TitleAndTagsSection({required this.detail});

  final CommissionDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Info Grid ────────────────────────────────────────────────────────────────

class _InfoGridSection extends StatelessWidget {
  const _InfoGridSection({required this.detail});

  final CommissionDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _InfoCard(
              icon: Icons.schedule_rounded,
              label: '예상 작업일',
              value: detail.estimatedDaysLabel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoCard(
              icon: Icons.check_circle_outline_rounded,
              label: '완료 작업',
              value: detail.completedCountLabel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _InfoCard(
              icon: Icons.shield_outlined,
              label: '응답률',
              value: detail.responseRateLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price Options ────────────────────────────────────────────────────────────

class _PriceOptionsSection extends StatelessWidget {
  const _PriceOptionsSection({
    required this.options,
    required this.selectedIndex,
    required this.onOptionSelected,
  });

  final List<CommissionPriceOption> options;
  final int selectedIndex;
  final ValueChanged<int> onOptionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '가격 옵션',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _PriceOptionCard(
              option: options[i],
              isSelected: i == selectedIndex,
              onTap: () => onOptionSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceOptionCard extends StatelessWidget {
  const _PriceOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CommissionPriceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primarySoft : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              if (option.isPopular) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '인기',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  option.displayLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                option.priceLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Work Description ─────────────────────────────────────────────────────────

class _WorkDescriptionSection extends StatelessWidget {
  const _WorkDescriptionSection({required this.detail});

  final CommissionDetail detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '작업 설명',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            detail.introText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '작업 범위',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          ...detail.workScopeItems.map(_BulletText.new),
          const SizedBox(height: 16),
          const Text(
            '수정 정책',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          ...detail.revisionPolicyItems.map(_BulletText.new),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notice Box ───────────────────────────────────────────────────────────────

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _warningBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _warningBorder),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          children: [
            const TextSpan(
              text: '안내: ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _warningAccent,
              ),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

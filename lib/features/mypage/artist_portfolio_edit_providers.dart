import 'dart:developer' as developer;

import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final artistPortfolioEditProvider =
    NotifierProvider.autoDispose<ArtistPortfolioEditNotifier, ArtistPortfolioEditState>(
  ArtistPortfolioEditNotifier.new,
);

class ArtistPortfolioEditNotifier extends AutoDisposeNotifier<ArtistPortfolioEditState> {
  @override
  ArtistPortfolioEditState build() {
    final profile = ref.read(artistProfileProvider);

    return ArtistPortfolioEditState(
      backgroundNetworkUrl:
          'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800&h=300&fit=crop',
      avatarNetworkUrl: profile.avatarUrl,
      nickname: profile.name,
      oneLineIntro: 'Hi! I specialize in vibrant anime illustrat',
      portfolioImages: const [
        PortfolioImageItem(
          id: 'p1',
          networkUrl:
              'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&h=400&fit=crop',
        ),
        PortfolioImageItem(
          id: 'p2',
          networkUrl:
              'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=400&fit=crop',
        ),
        PortfolioImageItem(
          id: 'p3',
          networkUrl:
              'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=400&fit=crop',
        ),
        PortfolioImageItem(
          id: 'p4',
          networkUrl:
              'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=400&h=400&fit=crop',
        ),
        PortfolioImageItem(
          id: 'p5',
          networkUrl:
              'https://images.unsplash.com/photo-1618172193626-ae7fd5fab9d2?w=400&h=400&fit=crop',
        ),
      ],
      selectedStyles: {'애니메이션', '세미 리얼', 'SD 캐릭터'},
      selectedTools: {'Clip Studio', 'Photoshop', 'iPad'},
      detailedIntro:
          '주로 애니메이션 스타일의 캐릭터 일러스트와 컨셉 아트를 작업하고 있습니다. 게임, 소설, VTuber 관련 작업 경험이 풍부합니다.\n\n정성을 다해 작업하며, 수정 요청에도 적극적으로 대응합니다.',
      workNotice:
          '• 작업 기간: 일반적으로 7-14일 소요\n• 수정 횟수: 스케치 2회, 컬러 1회 포함\n• 저작권: 개인 소장용은 기본 포함, 상업 이용 시 별도 협의\n• 그리지 않는 것: 고어, 실제 인물, 정치적 내용',
      twitterHandle: '@haneul_art',
      instagramHandle: 'haneul.artist',
      websiteUrl: 'https://haneulart.com',
    );
  }

  void updateNickname(String value) {
    state = state.copyWith(nickname: value);
  }

  void updateOneLineIntro(String value) {
    if (value.length > ArtistPortfolioEditState.maxOneLineIntro) return;
    state = state.copyWith(oneLineIntro: value);
  }

  void updateDetailedIntro(String value) {
    if (value.length > ArtistPortfolioEditState.maxDetailedIntro) return;
    state = state.copyWith(detailedIntro: value);
  }

  void updateWorkNotice(String value) {
    if (value.length > ArtistPortfolioEditState.maxWorkNotice) return;
    state = state.copyWith(workNotice: value);
  }

  void updateTwitterHandle(String value) {
    state = state.copyWith(twitterHandle: value);
  }

  void updateInstagramHandle(String value) {
    state = state.copyWith(instagramHandle: value);
  }

  void updateWebsiteUrl(String value) {
    state = state.copyWith(websiteUrl: value);
  }

  void setBackgroundImage(String path) {
    state = state.copyWith(
      backgroundLocalPath: path,
      clearBackgroundNetworkUrl: true,
    );
  }

  void setAvatarImage(String path) {
    state = state.copyWith(
      avatarLocalPath: path,
      clearAvatarNetworkUrl: true,
    );
  }

  void toggleStyle(String style) {
    final next = Set<String>.from(state.selectedStyles);
    if (next.contains(style)) {
      next.remove(style);
    } else {
      next.add(style);
    }
    state = state.copyWith(selectedStyles: next);
  }

  void toggleTool(String tool) {
    final next = Set<String>.from(state.selectedTools);
    if (next.contains(tool)) {
      next.remove(tool);
    } else {
      next.add(tool);
    }
    state = state.copyWith(selectedTools: next);
  }

  void setActivePortfolioIndex(int? index) {
    if (index == state.activePortfolioIndex) {
      state = state.copyWith(clearActivePortfolioIndex: true);
      return;
    }
    state = state.copyWith(activePortfolioIndex: index);
  }

  void clearActivePortfolioIndex() {
    state = state.copyWith(clearActivePortfolioIndex: true);
  }

  void addPortfolioImages(List<String> paths) {
    if (paths.isEmpty) return;

    final remaining =
        ArtistPortfolioEditState.maxPortfolioCount - state.portfolioImages.length;
    if (remaining <= 0) return;

    final toAdd = paths.take(remaining).toList();
    final base = DateTime.now().microsecondsSinceEpoch;
    final newItems = [
      for (var i = 0; i < toAdd.length; i++)
        PortfolioImageItem(
          id: 'local-$base-$i',
          localPath: toAdd[i],
        ),
    ];

    state = state.copyWith(
      portfolioImages: [...state.portfolioImages, ...newItems],
    );
  }

  void removePortfolioImage(String id) {
    final items = [...state.portfolioImages]..removeWhere((item) => item.id == id);
    state = state.copyWith(
      portfolioImages: items,
      clearActivePortfolioIndex: true,
    );
  }

  void setAsFeatured(int index) {
    if (index <= 0 || index >= state.portfolioImages.length) return;
    final items = [...state.portfolioImages];
    final item = items.removeAt(index);
    items.insert(0, item);
    state = state.copyWith(
      portfolioImages: items,
      activePortfolioIndex: 0,
    );
  }

  void reorderPortfolio(int from, int to) {
    if (from == to) return;
    if (from < 0 ||
        to < 0 ||
        from >= state.portfolioImages.length ||
        to >= state.portfolioImages.length) {
      return;
    }

    final items = [...state.portfolioImages];
    final item = items.removeAt(from);
    items.insert(to, item);
    state = state.copyWith(portfolioImages: items);
  }

  Future<bool> save() async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true);

    await Future<void>.delayed(const Duration(milliseconds: 600));

    final payload = state.toJson();
    developer.log(
      'Artist portfolio saved: $payload',
      name: 'ArtistPortfolioEdit',
    );

    ref.read(artistProfileProvider.notifier).updateName(state.nickname);

    state = state.copyWith(isSaving: false);
    return true;
  }
}

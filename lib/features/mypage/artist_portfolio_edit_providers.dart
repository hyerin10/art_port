import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/resource_ids.dart';
import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/mypage/data/mypage_write_providers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final artistPortfolioEditProvider =
    NotifierProvider.autoDispose<ArtistPortfolioEditNotifier, ArtistPortfolioEditState>(
  ArtistPortfolioEditNotifier.new,
);

class ArtistPortfolioEditNotifier extends AutoDisposeNotifier<ArtistPortfolioEditState> {
  List<String> _loadedPortfolioIds = const [];
  String? _twitterLinkId;
  String? _instagramLinkId;
  String? _websiteLinkId;

  @override
  ArtistPortfolioEditState build() {
    Future.microtask(_load);
    return const ArtistPortfolioEditState(
      nickname: '',
      oneLineIntro: '',
      portfolioImages: [],
      selectedStyles: {},
      selectedTools: {},
      detailedIntro: '',
      workNotice: '',
      twitterHandle: '',
      instagramHandle: '',
      websiteUrl: '',
    );
  }

  Future<void> _load() async {
    final profileId = ref.read(currentArtistProfileIdProvider);
    if (profileId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    try {
      final repo = ref.read(artistProfileRepositoryProvider);
      final (profile, portfolio, socialLinks) = await (
        repo.getById(profileId),
        repo.getPortfolioImages(profileId),
        repo.getSocialLinks(profileId),
      ).wait;

      _loadedPortfolioIds = [for (final image in portfolio) image.id];
      _twitterLinkId = _idForType(socialLinks, 'twitter');
      _instagramLinkId = _idForType(socialLinks, 'instagram');
      _websiteLinkId = _idForType(socialLinks, 'website');

      state = ArtistPortfolioEditState(
        backgroundNetworkUrl: profile.backgroundUrl,
        avatarNetworkUrl: profile.avatarUrl,
        nickname: profile.displayName,
        oneLineIntro: profile.oneLineIntro ?? '',
        portfolioImages: [
          for (final image in portfolio)
            PortfolioImageItem(id: image.id, networkUrl: image.imageUrl),
        ],
        selectedStyles: profile.specialties.toSet(),
        selectedTools: const {},
        detailedIntro: profile.detailedIntro ?? '',
        workNotice: _workNoticeFrom(profile),
        twitterHandle: _handleFrom(
          socialLinks,
          'twitter',
          stripAt: true,
        ),
        instagramHandle: _handleFrom(socialLinks, 'instagram'),
        websiteUrl: _urlFrom(socialLinks, 'website'),
        isLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoaded: true,
        saveError: '프로필을 불러오지 못했습니다.',
      );
    }
  }

  void updateNickname(String value) {
    state = state.copyWith(nickname: value, clearSaveError: true);
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

    final profileId = ref.read(currentArtistProfileIdProvider);
    final userId = ref.read(currentUserIdProvider);
    if (profileId == null || userId == null) {
      state = state.copyWith(saveError: '로그인이 필요합니다.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final repo = ref.read(artistProfileRepositoryProvider);
      final nickname = state.nickname.trim();
      final updated = await repo.update(
        profileId,
        displayName: nickname.isEmpty ? null : nickname,
        oneLineIntro: state.oneLineIntro.trim(),
        detailedIntro: state.detailedIntro.trim(),
        revisionPolicy: state.workNotice.trim(),
        specialties: state.selectedStyles.toList(),
        avatarUrl: ResourceIds.isRemoteUrl(state.avatarNetworkUrl)
            ? state.avatarNetworkUrl
            : null,
        backgroundUrl: ResourceIds.isRemoteUrl(state.backgroundNetworkUrl)
            ? state.backgroundNetworkUrl
            : null,
      );

      await _syncSocialLinks(profileId: profileId);
      await _syncPortfolioImages(profileId: profileId);

      ref.read(artistProfileProvider.notifier).updateName(updated.displayName);
      if (updated.avatarUrl != null && updated.avatarUrl!.isNotEmpty) {
        ref.read(artistProfileProvider.notifier).updateAvatar(updated.avatarUrl!);
      }
      invalidateArtistWorkspaceQueries(ref, artistProfileId: profileId);

      state = state.copyWith(isSaving: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSaving: false, saveError: e.displayMessage);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        saveError: '저장에 실패했습니다. 다시 시도해 주세요.',
      );
      return false;
    }
  }

  Future<void> _syncSocialLinks({required String profileId}) async {
    await _upsertSocialLink(
      profileId: profileId,
      type: 'twitter',
      currentId: _twitterLinkId,
      url: _twitterUrl(state.twitterHandle),
      label: state.twitterHandle.trim().isEmpty
          ? null
          : state.twitterHandle.trim(),
      onId: (id) => _twitterLinkId = id,
    );
    await _upsertSocialLink(
      profileId: profileId,
      type: 'instagram',
      currentId: _instagramLinkId,
      url: _instagramUrl(state.instagramHandle),
      label: state.instagramHandle.trim().isEmpty
          ? null
          : state.instagramHandle.trim(),
      onId: (id) => _instagramLinkId = id,
    );
    await _upsertSocialLink(
      profileId: profileId,
      type: 'website',
      currentId: _websiteLinkId,
      url: _websiteUrl(state.websiteUrl),
      label: '웹사이트',
      onId: (id) => _websiteLinkId = id,
    );
  }

  Future<void> _upsertSocialLink({
    required String profileId,
    required String type,
    required String? currentId,
    required String? url,
    required String? label,
    required void Function(String? id) onId,
  }) async {
    final repo = ref.read(artistProfileRepositoryProvider);
    if (url == null) {
      if (currentId != null) {
        await repo.deleteSocialLink(currentId);
        onId(null);
      }
      return;
    }

    if (currentId != null) {
      await repo.updateSocialLink(
        linkId: currentId,
        label: label,
        url: url,
      );
      return;
    }

    final created = await repo.createSocialLink(
      profileId: profileId,
      type: type,
      label: label,
      url: url,
    );
    onId(created.id);
  }

  Future<void> _syncPortfolioImages({required String profileId}) async {
    final repo = ref.read(artistProfileRepositoryProvider);
    final currentIds = [
      for (final item in state.portfolioImages)
        if (ResourceIds.isUuid(item.id)) item.id,
    ];
    for (final id in _loadedPortfolioIds) {
      if (!currentIds.contains(id)) {
        await repo.deletePortfolioImage(id);
      }
    }
    if (currentIds.length >= 2) {
      await repo.reorderPortfolioImages(
        profileId: profileId,
        orderedIds: currentIds,
      );
    }
    _loadedPortfolioIds = currentIds;
  }

  static String? _idForType(List<SocialLinkDto> links, String type) {
    for (final link in links) {
      if (link.type == type) return link.id;
    }
    return null;
  }

  static String _handleFrom(
    List<SocialLinkDto> links,
    String type, {
    bool stripAt = false,
  }) {
    for (final link in links) {
      if (link.type != type) continue;
      final label = link.label?.trim();
      if (label != null && label.isNotEmpty) {
        return stripAt ? label.replaceFirst('@', '') : label;
      }
      return _handleFromUrl(link.url, type);
    }
    return '';
  }

  static String _urlFrom(List<SocialLinkDto> links, String type) {
    for (final link in links) {
      if (link.type == type) return link.url;
    }
    return '';
  }

  static String _handleFromUrl(String url, String type) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final segments = uri.pathSegments.where((part) => part.isNotEmpty);
    if (segments.isEmpty) return url;
    final handle = segments.last;
    if (type == 'twitter') return handle.startsWith('@') ? handle : '@$handle';
    return handle;
  }

  static String _workNoticeFrom(ArtistProfileDto profile) {
    if (profile.revisionPolicy != null && profile.revisionPolicy!.trim().isNotEmpty) {
      return profile.revisionPolicy!;
    }
    final lines = <String>[
      if (profile.workingHours != null && profile.workingHours!.isNotEmpty)
        '• 작업 시간: ${profile.workingHours}',
      if (profile.averageDeliveryDays != null)
        '• 작업 기간: 일반적으로 ${profile.averageDeliveryDays}일 소요',
      if (profile.paymentTerms != null && profile.paymentTerms!.isNotEmpty)
        '• 결제: ${profile.paymentTerms}',
      if (profile.restrictedItems.isNotEmpty)
        '• 그리지 않는 것: ${profile.restrictedItems.join(', ')}',
    ];
    return lines.join('\n');
  }

  static String? _twitterUrl(String handle) {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) return null;
    if (ResourceIds.isRemoteUrl(trimmed)) return trimmed;
    final user = trimmed.replaceAll('@', '');
    return 'https://twitter.com/$user';
  }

  static String? _instagramUrl(String handle) {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) return null;
    if (ResourceIds.isRemoteUrl(trimmed)) return trimmed;
    final user = trimmed.replaceAll('@', '');
    return 'https://instagram.com/$user';
  }

  static String? _websiteUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (ResourceIds.isRemoteUrl(trimmed)) return trimmed;
    return 'https://$trimmed';
  }
}

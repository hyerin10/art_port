import 'package:art_port/features/artist_application/models/artist_application_data.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작가 활동 신청 폼 상태
class ArtistApplicationFormState {
  const ArtistApplicationFormState({
    this.currentStep = ArtistApplicationStep.basicInfo,
    this.data = const ArtistApplicationData(),
    this.hasDraft = false,
    this.lastSavedAt,
  });

  final ArtistApplicationStep currentStep;
  final ArtistApplicationData data;
  final bool hasDraft;
  final DateTime? lastSavedAt;

  bool get canGoNext => data.isStepValid(currentStep);

  bool get isFirstStep => currentStep == ArtistApplicationStep.basicInfo;

  bool get isLastStep => currentStep == ArtistApplicationStep.terms;

  ArtistApplicationFormState copyWith({
    ArtistApplicationStep? currentStep,
    ArtistApplicationData? data,
    bool? hasDraft,
    DateTime? lastSavedAt,
    bool clearLastSavedAt = false,
  }) {
    return ArtistApplicationFormState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      hasDraft: hasDraft ?? this.hasDraft,
      lastSavedAt:
          clearLastSavedAt ? null : (lastSavedAt ?? this.lastSavedAt),
    );
  }
}

final artistApplicationFormProvider =
    NotifierProvider<ArtistApplicationFormNotifier, ArtistApplicationFormState>(
  ArtistApplicationFormNotifier.new,
);

/// 임시저장 데이터 (로컬 영속화 확장용 — SharedPreferences 등 연동 가능)
final artistApplicationDraftProvider =
    NotifierProvider<ArtistApplicationDraftNotifier, ArtistApplicationData?>(
  ArtistApplicationDraftNotifier.new,
);

class ArtistApplicationDraftNotifier extends Notifier<ArtistApplicationData?> {
  @override
  ArtistApplicationData? build() => null;

  /// TODO: SharedPreferences 등 로컬 저장소에 직렬화하여 영속화
  void save(ArtistApplicationData data) {
    state = data;
  }

  void clear() {
    state = null;
  }
}

class ArtistApplicationFormNotifier
    extends Notifier<ArtistApplicationFormState> {
  @override
  ArtistApplicationFormState build() {
    final draft = ref.read(artistApplicationDraftProvider);
    if (draft != null) {
      return ArtistApplicationFormState(
        data: draft,
        hasDraft: true,
      );
    }
    return const ArtistApplicationFormState();
  }

  void loadDraftIfAvailable() {
    final draft = ref.read(artistApplicationDraftProvider);
    if (draft != null) {
      state = state.copyWith(data: draft, hasDraft: true);
    }
  }

  void setArtistName(String value) {
    state = state.copyWith(data: state.data.copyWith(artistName: value));
  }

  void setBankName(String? value) {
    state = state.copyWith(
      data: state.data.copyWith(
        bankName: value,
        clearBankName: value == null,
      ),
    );
  }

  void setAccountNumber(String value) {
    state = state.copyWith(data: state.data.copyWith(accountNumber: value));
  }

  void setAccountHolder(String value) {
    state = state.copyWith(data: state.data.copyWith(accountHolder: value));
  }

  void setPortfolioImages(List<String> paths) {
    state = state.copyWith(
      data: state.data.copyWith(portfolioImagePaths: paths),
    );
  }

  void addPortfolioImage(String path) {
    final current = List<String>.from(state.data.portfolioImagePaths);
    if (current.length >= 5) return;
    current.add(path);
    setPortfolioImages(current);
  }

  void removePortfolioImage(int index) {
    final current = List<String>.from(state.data.portfolioImagePaths);
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    setPortfolioImages(current);
  }

  void setVerificationFiles(List<String> paths) {
    state = state.copyWith(
      data: state.data.copyWith(verificationFilePaths: paths),
    );
  }

  void addVerificationFile(String path) {
    final current = List<String>.from(state.data.verificationFilePaths);
    current.add(path);
    setVerificationFiles(current);
  }

  void toggleStyleTag(String tag) {
    final tags = Set<String>.from(state.data.styleTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    state = state.copyWith(data: state.data.copyWith(styleTags: tags));
  }

  void updateCommissionType(int index, CommissionTypeEntry entry) {
    final types = List<CommissionTypeEntry>.from(state.data.commissionTypes);
    if (index < 0 || index >= types.length) return;
    types[index] = entry;
    state = state.copyWith(data: state.data.copyWith(commissionTypes: types));
  }

  void addCommissionType() {
    final types = List<CommissionTypeEntry>.from(state.data.commissionTypes);
    types.add(const CommissionTypeEntry());
    state = state.copyWith(data: state.data.copyWith(commissionTypes: types));
  }

  void removeCommissionType(int index) {
    final types = List<CommissionTypeEntry>.from(state.data.commissionTypes);
    if (types.length <= 1) return;
    types.removeAt(index);
    state = state.copyWith(data: state.data.copyWith(commissionTypes: types));
  }

  void setMaxWorkDays(int value) {
    state = state.copyWith(data: state.data.copyWith(maxWorkDays: value));
  }

  void setRoughRevisionCount(int value) {
    state = state.copyWith(
      data: state.data.copyWith(roughRevisionCount: value),
    );
  }

  void setFinalRevisionCount(int value) {
    state = state.copyWith(
      data: state.data.copyWith(finalRevisionCount: value),
    );
  }

  void setNonCommercial(bool value) {
    state = state.copyWith(data: state.data.copyWith(nonCommercial: value));
  }

  void setCommercialStreaming(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(commercialStreaming: value),
    );
  }

  void setCopyrightTransfer(bool value) {
    state = state.copyWith(
      data: state.data.copyWith(copyrightTransfer: value),
    );
  }

  void setTermsAgreed(bool value) {
    state = state.copyWith(data: state.data.copyWith(termsAgreed: value));
  }

  void goNext() {
    if (!state.canGoNext || state.isLastStep) return;
    final nextIndex = state.currentStep.index + 1;
    state = state.copyWith(
      currentStep: ArtistApplicationStep.values[nextIndex],
    );
  }

  void goPrevious() {
    if (state.isFirstStep) return;
    final prevIndex = state.currentStep.index - 1;
    state = state.copyWith(
      currentStep: ArtistApplicationStep.values[prevIndex],
    );
  }

  void goToStep(ArtistApplicationStep step) {
    state = state.copyWith(currentStep: step);
  }

  /// 임시저장 — draft provider에 현재 폼 데이터 저장
  void saveDraft() {
    ref.read(artistApplicationDraftProvider.notifier).save(state.data);
    state = state.copyWith(
      hasDraft: true,
      lastSavedAt: DateTime.now(),
    );
  }

  /// 최종 신청 제출
  bool submit() {
    if (!state.data.isStepValid(ArtistApplicationStep.terms)) {
      return false;
    }
    ref.read(artistApprovalStatusProvider.notifier).markPending();
    ref.read(artistApplicationDraftProvider.notifier).clear();
    reset();
    return true;
  }

  void reset() {
    state = const ArtistApplicationFormState();
  }
}

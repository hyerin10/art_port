import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_application/artist_application_providers.dart';
import 'package:art_port/features/artist_application/models/artist_application_data.dart';
import 'package:art_port/features/artist_application/widgets/artist_application_footer.dart';
import 'package:art_port/features/artist_application/widgets/artist_application_stepper.dart';
import 'package:art_port/features/artist_application/widgets/steps/basic_info_step.dart';
import 'package:art_port/features/artist_application/widgets/steps/commission_step.dart';
import 'package:art_port/features/artist_application/widgets/steps/portfolio_step.dart';
import 'package:art_port/features/artist_application/widgets/steps/terms_step.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistApplicationView extends ConsumerStatefulWidget {
  const ArtistApplicationView({super.key});

  @override
  ConsumerState<ArtistApplicationView> createState() =>
      _ArtistApplicationViewState();
}

class _ArtistApplicationViewState extends ConsumerState<ArtistApplicationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final draft = ref.read(artistApplicationDraftProvider);
      final notifier = ref.read(artistApplicationFormProvider.notifier);
      if (draft != null) {
        notifier.loadDraftIfAvailable();
      } else {
        notifier.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(artistApplicationFormProvider);
    final notifier = ref.read(artistApplicationFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _ApplicationHeader(
            onClose: () => _confirmClose(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: ArtistApplicationStepper(
              currentStep: formState.currentStep,
            ),
          ),
          const Divider(height: 24, color: AppColors.borderLight),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: _StepContent(step: formState.currentStep),
            ),
          ),
          ArtistApplicationFooter(
            showPrevious: !formState.isFirstStep,
            isNextEnabled: formState.canGoNext,
            isLastStep: formState.isLastStep,
            onPrevious: notifier.goPrevious,
            onNext: () => _handleNext(context, ref),
            onSaveDraft: () => _handleSaveDraft(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(BuildContext context, WidgetRef ref) async {
    final formState = ref.read(artistApplicationFormProvider);
    final notifier = ref.read(artistApplicationFormProvider.notifier);

    if (!formState.canGoNext) return;

    if (formState.isLastStep) {
      final success =
          await ref.read(artistApplicationFormProvider.notifier).submit();
      if (!context.mounted) return;
      if (success) {
        AppToast.show(
          ScaffoldMessenger.of(context),
          message: '작가 활동 신청이 완료되었습니다.',
          duration: const Duration(seconds: 3),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(artistApplicationFormProvider).submitError;
        AppToast.show(
          ScaffoldMessenger.of(context),
          message: error ?? '신청에 실패했습니다. 다시 시도해 주세요.',
        );
      }
      return;
    }

    notifier.goNext();
  }

  void _handleSaveDraft(BuildContext context, WidgetRef ref) {
    ref.read(artistApplicationFormProvider.notifier).saveDraft();
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '임시저장되었습니다.',
    );
  }

  Future<void> _confirmClose(BuildContext context, WidgetRef ref) async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('신청을 종료하시겠습니까?'),
        content: const Text(
          '입력 중인 내용은 임시저장하지 않으면 사라질 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('계속 작성'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    if (shouldClose == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _ApplicationHeader extends StatelessWidget {
  const _ApplicationHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: AppColors.textPrimary,
            ),
            const Expanded(
              child: Text(
                '작가 활동 신청',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.step});

  final ArtistApplicationStep step;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      ArtistApplicationStep.basicInfo => const BasicInfoStep(),
      ArtistApplicationStep.portfolio => const PortfolioStep(),
      ArtistApplicationStep.commission => const CommissionStep(),
      ArtistApplicationStep.terms => const TermsStep(),
    };
  }
}

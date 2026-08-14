import 'package:art_port/features/commission/commission_transaction_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 신청 제출 내역 (추후 주문 API 연동 시 교체)
final commissionApplySubmissionsProvider =
    NotifierProvider<CommissionApplySubmissionsNotifier, List<CommissionApplySubmission>>(
  CommissionApplySubmissionsNotifier.new,
);

class CommissionApplySubmissionsNotifier
    extends Notifier<List<CommissionApplySubmission>> {
  @override
  List<CommissionApplySubmission> build() => [];

  String submit(CommissionApplySubmission submission) {
    state = [...state, submission];

    final detail = ref
        .read(commissionCatalogProvider)
        .valueOrNull
        ?.detailFor(submission.commissionId);
    final artistAvatarUrl = detail?.artistAvatarUrl ??
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop';

    return ref.read(commissionTransactionRegistryProvider.notifier).registerFromSubmission(
          submission: submission,
          artistAvatarUrl: artistAvatarUrl,
          artistId: detail?.artistProfileId,
        );
  }
}

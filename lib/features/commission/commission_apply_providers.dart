import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 신청 제출 내역 (추후 API 연동 시 교체)
final commissionApplySubmissionsProvider =
    NotifierProvider<CommissionApplySubmissionsNotifier, List<CommissionApplySubmission>>(
  CommissionApplySubmissionsNotifier.new,
);

class CommissionApplySubmissionsNotifier
    extends Notifier<List<CommissionApplySubmission>> {
  @override
  List<CommissionApplySubmission> build() => [];

  void submit(CommissionApplySubmission submission) {
    state = [...state, submission];
  }
}

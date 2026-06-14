import 'package:art_port/features/mypage/models/withdrawal_data.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final withdrawalProvider =
    NotifierProvider.autoDispose<WithdrawalNotifier, WithdrawalState>(
  WithdrawalNotifier.new,
);

class WithdrawalNotifier extends AutoDisposeNotifier<WithdrawalState> {
  @override
  WithdrawalState build() {
    final earnings = ref.watch(artistEarningsProvider);
    return WithdrawalState(
      availableAmount: earnings.withdrawableAmount,
    );
  }

  void updateRequestedAmount(int amount) {
    final clamped = amount.clamp(0, state.availableAmount);
    state = state.copyWith(requestedAmount: clamped);
  }

  void fillFullAmount() {
    state = state.copyWith(requestedAmount: state.availableAmount);
  }

  Future<bool> submit() async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isSubmitting: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isSubmitting: false);
    return true;
  }
}

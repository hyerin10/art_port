import 'package:art_port/features/mypage/models/settlement_account_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settlementAccountProvider =
    NotifierProvider.autoDispose<SettlementAccountNotifier, SettlementAccountState>(
  SettlementAccountNotifier.new,
);

class SettlementAccountNotifier extends AutoDisposeNotifier<SettlementAccountState> {
  @override
  SettlementAccountState build() => const SettlementAccountState();

  void selectBank(String? bank) {
    state = state.copyWith(
      selectedBank: bank,
      isVerified: false,
    );
  }

  void updateAccountNumber(String value) {
    state = state.copyWith(
      accountNumber: value,
      isVerified: false,
    );
  }

  Future<bool> verifyAccount() async {
    if (!state.canVerify) return false;

    state = state.copyWith(isVerifying: true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isVerifying: false, isVerified: true);
    return true;
  }

  Future<bool> save() async {
    if (!state.canSave) return false;

    state = state.copyWith(isSaving: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isSaving: false);
    return true;
  }
}

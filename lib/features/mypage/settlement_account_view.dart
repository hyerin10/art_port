import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/settlement_account_actions.dart';
import 'package:art_port/features/mypage/settlement_account_providers.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/settlement_account_form.dart';
import 'package:art_port/features/mypage/widgets/settlement_account_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 정산 계좌 관리 메인 화면
class SettlementAccountView extends ConsumerStatefulWidget {
  const SettlementAccountView({super.key});

  @override
  ConsumerState<SettlementAccountView> createState() =>
      _SettlementAccountViewState();
}

class _SettlementAccountViewState extends ConsumerState<SettlementAccountView> {
  final _accountNumberController = TextEditingController();
  var _initialized = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  void _syncController(String accountNumber) {
    if (!_initialized) {
      _accountNumberController.text = accountNumber;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementAccountProvider);
    final notifier = ref.read(settlementAccountProvider.notifier);
    _syncController(state.accountNumber);

    return MyPageSubScreenScaffold(
      backgroundColor: AppColors.background,
      header: SettlementAccountHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SettlementAccountForm(
        state: state,
        accountNumberController: _accountNumberController,
        onBankSelected: notifier.selectBank,
        onAccountNumberChanged: notifier.updateAccountNumber,
        onVerifyAccount: () => SettlementAccountActions.verifyAccount(context, ref),
      ),
      footer: _SaveFooterButton(
        enabled: state.canSave,
        isSaving: state.isSaving,
        onPressed: () => SettlementAccountActions.save(context, ref),
      ),
    );
  }
}

class _SaveFooterButton extends StatelessWidget {
  const _SaveFooterButton({
    required this.enabled,
    required this.isSaving,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: enabled && !isSaving ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.chipBackground,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '저장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

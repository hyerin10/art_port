import 'package:art_port/features/mypage/settlement_account_screen.dart';
import 'package:art_port/features/mypage/withdrawal_actions.dart';
import 'package:art_port/features/mypage/withdrawal_providers.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_account_section.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_amount_section.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_available_profit_card.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_footer_button.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_header.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_notice_box.dart';
import 'package:art_port/features/mypage/widgets/withdrawal_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 출금 신청 메인 화면
class WithdrawalView extends ConsumerWidget {
  const WithdrawalView({super.key});

  static const _screenBackground = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(withdrawalProvider);
    final notifier = ref.read(withdrawalProvider.notifier);

    return MyPageSubScreenScaffold(
      backgroundColor: _screenBackground,
      header: WithdrawalHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WithdrawalAvailableProfitCard(amount: state.availableAmount),
            const SizedBox(height: 24),
            WithdrawalAmountSection(
              amount: state.requestedAmount,
              onAmountChanged: notifier.updateRequestedAmount,
              onFillFullAmount: notifier.fillFullAmount,
            ),
            const SizedBox(height: 24),
            WithdrawalAccountSection(
              bankName: state.bankName,
              maskedAccountNumber: state.maskedAccountNumber,
              accountHolder: state.accountHolder,
              onChangeAccount: () => SettlementAccountScreen.open(context),
            ),
            const SizedBox(height: 24),
            WithdrawalSummaryCard(
              requestedAmount: state.requestedAmount,
              feeAmount: state.feeAmount,
              finalDepositAmount: state.finalDepositAmount,
            ),
            const SizedBox(height: 20),
            const WithdrawalNoticeBox(),
          ],
        ),
      ),
      footer: WithdrawalFooterButton(
        enabled: state.canSubmit,
        isSubmitting: state.isSubmitting,
        onPressed: () => WithdrawalActions.submit(context, ref),
      ),
    );
  }
}

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/settlement_account_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 정산 계좌 관리 폼 본문
class SettlementAccountForm extends StatelessWidget {
  const SettlementAccountForm({
    super.key,
    required this.state,
    required this.accountNumberController,
    required this.onBankSelected,
    required this.onAccountNumberChanged,
    required this.onVerifyAccount,
  });

  final SettlementAccountState state;
  final TextEditingController accountNumberController;
  final ValueChanged<String> onBankSelected;
  final ValueChanged<String> onAccountNumberChanged;
  final VoidCallback onVerifyAccount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _InfoBanner(),
          const SizedBox(height: 24),
          _BankSelectorField(
            selectedBank: state.selectedBank,
            onBankSelected: onBankSelected,
          ),
          const SizedBox(height: 24),
          _AccountNumberField(
            controller: accountNumberController,
            canVerify: state.canVerify,
            isVerifying: state.isVerifying,
            isVerified: state.isVerified,
            onChanged: onAccountNumberChanged,
            onVerify: onVerifyAccount,
          ),
          const SizedBox(height: 24),
          _AccountHolderField(accountHolder: state.accountHolder),
          if (state.isVerified) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                SizedBox(width: 6),
                Text(
                  '계좌 인증이 완료되었습니다.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
          const _NoticeSection(),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '안전한 정산을 위해 본인 명의의 계좌 정보를 입력해 주세요.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankSelectorField extends StatelessWidget {
  const _BankSelectorField({
    required this.selectedBank,
    required this.onBankSelected,
  });

  final String? selectedBank;
  final ValueChanged<String> onBankSelected;

  Future<void> _openBankPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  '은행 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: SettlementAccountState.bankOptions.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: AppColors.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final bank = SettlementAccountState.bankOptions[index];
                    final isSelected = bank == selectedBank;
                    return ListTile(
                      title: Text(
                        bank,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(bank),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      onBankSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('은행 선택'),
        const SizedBox(height: 10),
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _openBankPicker(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedBank ?? '은행을 선택해 주세요',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: selectedBank == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountNumberField extends StatelessWidget {
  const _AccountNumberField({
    required this.controller,
    required this.canVerify,
    required this.isVerifying,
    required this.isVerified,
    required this.onChanged,
    required this.onVerify,
  });

  final TextEditingController controller;
  final bool canVerify;
  final bool isVerifying;
  final bool isVerified;
  final ValueChanged<String> onChanged;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('계좌번호'),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isVerified,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '하이픈(-) 없이 입력',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _VerifyAccountButton(
              enabled: canVerify,
              isVerifying: isVerifying,
              isVerified: isVerified,
              onPressed: onVerify,
            ),
          ],
        ),
      ],
    );
  }
}

class _VerifyAccountButton extends StatelessWidget {
  const _VerifyAccountButton({
    required this.enabled,
    required this.isVerifying,
    required this.isVerified,
    required this.onPressed,
  });

  final bool enabled;
  final bool isVerifying;
  final bool isVerified;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isActive = enabled || isVerified;

    return Material(
      color: isVerified
          ? AppColors.primaryLight
          : isActive
              ? AppColors.primary
              : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled && !isVerifying ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: isVerifying
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isActive ? Colors.white : AppColors.textMuted,
                  ),
                )
              : Text(
                  isVerified ? '인증 완료' : '계좌 인증',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isVerified
                        ? AppColors.primary
                        : isActive
                            ? Colors.white
                            : AppColors.textMuted,
                  ),
                ),
        ),
      ),
    );
  }
}

class _AccountHolderField extends StatelessWidget {
  const _AccountHolderField({required this.accountHolder});

  final String accountHolder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('예금주'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            accountHolder,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '계좌의 예금주와 일치해야 합니다.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _NoticeSection extends StatelessWidget {
  const _NoticeSection();

  static const _notices = [
    '반드시 본인 명의의 계좌를 입력해주세요.',
    '정산 진행 중에는 계좌 정보를 변경할 수 없습니다.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                '유의사항',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final notice in _notices) ...[
            _NoticeBullet(text: notice),
            if (notice != _notices.last) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _NoticeBullet extends StatelessWidget {
  const _NoticeBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.45,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

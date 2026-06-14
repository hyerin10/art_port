import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 출금 신청 금액 입력 섹션
class WithdrawalAmountSection extends StatefulWidget {
  const WithdrawalAmountSection({
    super.key,
    required this.amount,
    required this.onAmountChanged,
    required this.onFillFullAmount,
  });

  final int amount;
  final ValueChanged<int> onAmountChanged;
  final VoidCallback onFillFullAmount;

  @override
  State<WithdrawalAmountSection> createState() => _WithdrawalAmountSectionState();
}

class _WithdrawalAmountSectionState extends State<WithdrawalAmountSection> {
  late final TextEditingController _controller;
  var _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatAmount(widget.amount));
  }

  @override
  void didUpdateWidget(WithdrawalAmountSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _syncController(widget.amount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatAmount(int amount) {
    if (amount <= 0) return '';
    return CurrencyFormatter.formatComma(amount);
  }

  void _syncController(int amount) {
    final formatted = _formatAmount(amount);
    if (_controller.text == formatted) return;

    _isInternalUpdate = true;
    _controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isInternalUpdate = false;
  }

  void _handleChanged(String value) {
    if (_isInternalUpdate) return;

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = int.tryParse(digits) ?? 0;
    widget.onAmountChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '출금 신청 금액',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                    suffixText: ' 원',
                    suffixStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  onChanged: _handleChanged,
                ),
              ),
              const SizedBox(width: 8),
              _FullAmountButton(
                onPressed: widget.onFillFullAmount,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '• 최소 출금 금액은 10,000원부터 가능합니다.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FullAmountButton extends StatelessWidget {
  const _FullAmountButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            '전액 입력',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

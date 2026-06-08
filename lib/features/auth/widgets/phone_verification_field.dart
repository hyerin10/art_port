import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/widgets/auth_field_error.dart';
import 'package:art_port/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class PhoneVerificationField extends StatelessWidget {
  const PhoneVerificationField({
    super.key,
    required this.phoneController,
    required this.verificationCodeController,
    required this.isVerified,
    required this.isVerifying,
    required this.verificationCodeSent,
    required this.canRequestVerification,
    required this.canConfirmVerification,
    required this.phoneError,
    required this.verificationError,
    required this.showSuccess,
    required this.onPhoneChanged,
    required this.onVerificationCodeChanged,
    required this.onRequestVerification,
    required this.onConfirmVerification,
  });

  final TextEditingController phoneController;
  final TextEditingController verificationCodeController;
  final bool isVerified;
  final bool isVerifying;
  final bool verificationCodeSent;
  final bool canRequestVerification;
  final bool canConfirmVerification;
  final String? phoneError;
  final String? verificationError;
  final bool showSuccess;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onVerificationCodeChanged;
  final VoidCallback onRequestVerification;
  final VoidCallback onConfirmVerification;

  AuthFieldStatus get _phoneStatus {
    if (phoneError != null || verificationError != null) {
      return AuthFieldStatus.error;
    }
    if (showSuccess) return AuthFieldStatus.success;
    return AuthFieldStatus.neutral;
  }

  AuthFieldStatus get _verificationCodeStatus {
    if (verificationError != null) return AuthFieldStatus.error;
    return AuthFieldStatus.neutral;
  }

  String? get _displayError => verificationError ?? phoneError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '전화번호',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AuthTextField(
                controller: phoneController,
                hintText: '01012345678',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !isVerified,
                onChanged: onPhoneChanged,
                status: _phoneStatus,
              ),
            ),
            const SizedBox(width: 10),
            _VerificationActionButton(
              isVerified: isVerified,
              isVerifying: isVerifying,
              verificationCodeSent: verificationCodeSent,
              canRequestVerification: canRequestVerification,
              canConfirmVerification: canConfirmVerification,
              onRequestVerification: onRequestVerification,
              onConfirmVerification: onConfirmVerification,
            ),
          ],
        ),
        if (verificationCodeSent && !isVerified) ...[
          const SizedBox(height: 12),
          AuthTextField(
            controller: verificationCodeController,
            hintText: '인증번호 6자리',
            prefixIcon: Icons.sms_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onChanged: onVerificationCodeChanged,
            status: _verificationCodeStatus,
          ),
        ],
        if (_displayError != null) AuthFieldError(message: _displayError!),
      ],
    );
  }
}

class _VerificationActionButton extends StatelessWidget {
  const _VerificationActionButton({
    required this.isVerified,
    required this.isVerifying,
    required this.verificationCodeSent,
    required this.canRequestVerification,
    required this.canConfirmVerification,
    required this.onRequestVerification,
    required this.onConfirmVerification,
  });

  final bool isVerified;
  final bool isVerifying;
  final bool verificationCodeSent;
  final bool canRequestVerification;
  final bool canConfirmVerification;
  final VoidCallback onRequestVerification;
  final VoidCallback onConfirmVerification;

  @override
  Widget build(BuildContext context) {
    final buttonLabel = isVerified
        ? '인증 완료'
        : verificationCodeSent
            ? '확인'
            : '인증하기';

    final buttonColor = isVerified
        ? AppColors.success
        : verificationCodeSent
            ? (canConfirmVerification ? AppColors.info : AppColors.textMuted)
            : canRequestVerification
                ? AppColors.info
                : AppColors.textMuted;

    final canPressButton = isVerified
        ? false
        : isVerifying
            ? false
            : verificationCodeSent
                ? canConfirmVerification
                : canRequestVerification;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: canPressButton
            ? () {
                if (verificationCodeSent) {
                  onConfirmVerification();
                } else {
                  onRequestVerification();
                }
              }
            : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          disabledForegroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: isVerifying
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: buttonColor,
                ),
              )
            : Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

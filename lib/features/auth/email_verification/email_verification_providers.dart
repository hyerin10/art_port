import 'package:art_port/features/auth/auth_messages.dart';
import 'package:art_port/features/auth/auth_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationFlowState {
  const EmailVerificationFlowState({
    this.verificationCode = '',
    this.codeSent = false,
    this.isSending = false,
    this.isVerifying = false,
    this.verificationCodeTouched = false,
    this.validationError,
    this.errorMessage,
  });

  final String verificationCode;
  final bool codeSent;
  final bool isSending;
  final bool isVerifying;
  final bool verificationCodeTouched;
  final String? validationError;
  final String? errorMessage;

  bool get isCodeComplete => verificationCode.length == 6;

  bool get canConfirm =>
      codeSent &&
      isCodeComplete &&
      validationError == null &&
      !isVerifying &&
      !isSending;

  bool get canResend => codeSent && !isSending && !isVerifying;

  String? get displayError => validationError ?? errorMessage;

  EmailVerificationFlowState copyWith({
    String? verificationCode,
    bool? codeSent,
    bool? isSending,
    bool? isVerifying,
    bool? verificationCodeTouched,
    String? validationError,
    String? errorMessage,
    bool clearValidationError = false,
    bool clearError = false,
  }) {
    return EmailVerificationFlowState(
      verificationCode: verificationCode ?? this.verificationCode,
      codeSent: codeSent ?? this.codeSent,
      isSending: isSending ?? this.isSending,
      isVerifying: isVerifying ?? this.isVerifying,
      verificationCodeTouched:
          verificationCodeTouched ?? this.verificationCodeTouched,
      validationError: clearValidationError
          ? null
          : (validationError ?? this.validationError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final emailVerificationFlowProvider =
    NotifierProvider<EmailVerificationFlowNotifier, EmailVerificationFlowState>(
  EmailVerificationFlowNotifier.new,
);

class EmailVerificationFlowNotifier extends Notifier<EmailVerificationFlowState> {
  static const _mockVerificationCode = '000000';

  @override
  EmailVerificationFlowState build() => const EmailVerificationFlowState();

  void reset() {
    state = const EmailVerificationFlowState();
  }

  void updateVerificationCode(String value) {
    final hasInvalidCharacters =
        AuthValidators.hasInvalidVerificationCodeCharacters(value);
    final normalized = AuthValidators.normalizeVerificationCode(value);

    state = state.copyWith(
      verificationCode: normalized,
      verificationCodeTouched: true,
      validationError: hasInvalidCharacters
          ? AuthMessages.emailVerificationCodeDigitsOnly
          : null,
      clearValidationError: !hasInvalidCharacters,
      clearError: true,
    );
  }

  Future<void> sendCode() async {
    if (state.isSending) return;

    state = state.copyWith(
      isSending: true,
      clearValidationError: true,
      clearError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isSending: false,
      codeSent: true,
    );
  }

  Future<bool> confirmCode() async {
    state = state.copyWith(verificationCodeTouched: true);

    if (AuthValidators.hasInvalidVerificationCodeCharacters(
      state.verificationCode,
    )) {
      state = state.copyWith(
        validationError: AuthMessages.emailVerificationCodeDigitsOnly,
      );
      return false;
    }

    if (!AuthValidators.isValidVerificationCode(state.verificationCode)) {
      state = state.copyWith(
        validationError: AuthMessages.emailVerificationCodeLength,
      );
      return false;
    }

    if (!state.canConfirm) return false;

    state = state.copyWith(
      isVerifying: true,
      clearValidationError: true,
      clearError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (state.verificationCode != _mockVerificationCode) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: AuthMessages.signUpVerificationFailed,
      );
      return false;
    }

    state = state.copyWith(isVerifying: false);
    return true;
  }

  Future<void> resendCode() async {
    if (!state.canResend) return;

    state = state.copyWith(
      isSending: true,
      verificationCode: '',
      verificationCodeTouched: false,
      clearValidationError: true,
      clearError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isSending: false,
      codeSent: true,
    );
  }
}

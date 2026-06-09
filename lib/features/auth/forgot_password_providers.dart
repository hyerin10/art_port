import 'package:art_port/features/auth/auth_messages.dart';
import 'package:art_port/features/auth/auth_validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ForgotPasswordStatus { initial, loading, success, failure }

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);

class ForgotPasswordState {
  const ForgotPasswordState({
    this.email = '',
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
    this.emailTouched = false,
    this.emailBlurred = false,
    this.submitAttempted = false,
  });

  final String email;
  final ForgotPasswordStatus status;
  final String? errorMessage;
  final bool emailTouched;
  final bool emailBlurred;
  final bool submitAttempted;

  bool get isLoading => status == ForgotPasswordStatus.loading;

  bool get canSubmit =>
      !isLoading && AuthValidators.isValidEmail(email);

  String? get emailError {
    if (!emailTouched && !emailBlurred && !submitAttempted) return null;
    if (email.isEmpty || !AuthValidators.isValidEmail(email)) {
      return AuthMessages.forgotPasswordEmailInvalid;
    }
    return null;
  }

  ForgotPasswordState copyWith({
    String? email,
    ForgotPasswordStatus? status,
    String? errorMessage,
    bool? emailTouched,
    bool? emailBlurred,
    bool? submitAttempted,
    bool clearErrorMessage = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      emailTouched: emailTouched ?? this.emailTouched,
      emailBlurred: emailBlurred ?? this.emailBlurred,
      submitAttempted: submitAttempted ?? this.submitAttempted,
    );
  }
}

class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  static const _mockFailureEmail = 'unknown@example.com';

  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void updateEmail(String value) {
    state = state.copyWith(
      email: value.trim(),
      emailTouched: true,
      status: ForgotPasswordStatus.initial,
      clearErrorMessage: true,
    );
  }

  void markEmailBlurred() {
    state = state.copyWith(emailBlurred: true);
  }

  void clearFailure() {
    if (state.status == ForgotPasswordStatus.failure) {
      state = state.copyWith(
        status: ForgotPasswordStatus.initial,
        clearErrorMessage: true,
      );
    }
  }

  Future<void> sendTemporaryPassword(String email) async {
    state = state.copyWith(
      email: email.trim(),
      emailTouched: true,
      emailBlurred: true,
      submitAttempted: true,
      status: ForgotPasswordStatus.initial,
      clearErrorMessage: true,
    );

    if (!AuthValidators.isValidEmail(state.email)) return;

    state = state.copyWith(status: ForgotPasswordStatus.loading);
    await Future<void>.delayed(const Duration(seconds: 2));

    if (state.email == _mockFailureEmail) {
      state = state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: AuthMessages.forgotPasswordEmailNotFound,
      );
      return;
    }

    state = state.copyWith(status: ForgotPasswordStatus.success);
  }
}

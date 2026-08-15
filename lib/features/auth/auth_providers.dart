import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/auth_messages.dart';
import 'package:art_port/features/auth/auth_validators.dart';
import 'package:art_port/features/auth/data/dto/user_dto.dart';
import 'package:art_port/features/auth/presentation/auth_session_effects.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signInFormProvider =
    NotifierProvider.autoDispose<SignInFormNotifier, SignInFormState>(
  SignInFormNotifier.new,
);

class SignInFormState {
  const SignInFormState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.emailTouched = false,
    this.emailBlurred = false,
    this.submitAttempted = false,
    this.submitError,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final bool isSubmitting;
  final bool emailTouched;
  final bool emailBlurred;
  final bool submitAttempted;
  final String? submitError;

  bool get canSubmit =>
      !isSubmitting &&
      AuthValidators.isValidEmail(email) &&
      password.isNotEmpty;

  String? get emailError {
    if (!emailTouched && !emailBlurred) return null;
    if (email.isEmpty) return null;
    if (!AuthValidators.isValidEmail(email)) {
      return AuthMessages.signInEmailInvalid;
    }
    return null;
  }

  String? get passwordError {
    if (!submitAttempted) return null;
    if (password.isEmpty) return AuthMessages.signInPasswordEmpty;
    return null;
  }

  SignInFormState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? isSubmitting,
    bool? emailTouched,
    bool? emailBlurred,
    bool? submitAttempted,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return SignInFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailTouched: emailTouched ?? this.emailTouched,
      emailBlurred: emailBlurred ?? this.emailBlurred,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
    );
  }
}

class SignInFormNotifier extends AutoDisposeNotifier<SignInFormState> {
  @override
  SignInFormState build() => const SignInFormState();

  void updateEmail(String value) {
    state = state.copyWith(
      email: value.trim(),
      emailTouched: true,
    );
  }

  void markEmailBlurred() {
    state = state.copyWith(emailBlurred: true);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> submit() async {
    state = state.copyWith(
      emailTouched: true,
      emailBlurred: true,
      submitAttempted: true,
      clearSubmitError: true,
    );
    if (!state.canSubmit) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      final session = await ref.read(userRepositoryProvider).login(
            state.email,
            state.password,
          );
      await ref.read(authProvider.notifier).applySession(session);
      syncSessionSideEffectsFromRef(ref, session.user);
      await refreshArtistApprovalStatus(ref.read);
      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: e.displayMessage,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: AuthMessages.signInNetworkError,
      );
      return false;
    }
  }
}

final signUpFormProvider =
    NotifierProvider.autoDispose<SignUpFormNotifier, SignUpFormState>(
  SignUpFormNotifier.new,
);

class SignUpFormState {
  const SignUpFormState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.verificationCode = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.isPhoneVerified = false,
    this.isVerifyingPhone = false,
    this.verificationCodeSent = false,
    this.isSubmitting = false,
    this.nameTouched = false,
    this.emailTouched = false,
    this.phoneTouched = false,
    this.verificationCodeTouched = false,
    this.passwordTouched = false,
    this.confirmPasswordTouched = false,
    this.phoneVerificationError,
    this.submitError,
  });

  final String name;
  final String email;
  final String phone;
  final String verificationCode;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isPhoneVerified;
  final bool isVerifyingPhone;
  final bool verificationCodeSent;
  final bool isSubmitting;
  final bool nameTouched;
  final bool emailTouched;
  final bool phoneTouched;
  final bool verificationCodeTouched;
  final bool passwordTouched;
  final bool confirmPasswordTouched;
  final String? phoneVerificationError;
  final String? submitError;

  bool get isNameValid => name.trim().isNotEmpty;

  bool get isEmailValid => AuthValidators.isValidEmail(email);

  bool get isPhoneValid => AuthValidators.isValidPhone(phone);

  bool get isPasswordValid => AuthValidators.isValidPassword(password);

  bool get isConfirmPasswordValid =>
      confirmPassword.isNotEmpty && password == confirmPassword;

  bool get canRequestVerification =>
      isPhoneValid && !isPhoneVerified && !isVerifyingPhone && !verificationCodeSent;

  bool get canConfirmVerification =>
      verificationCodeSent &&
      !isPhoneVerified &&
      !isVerifyingPhone &&
      verificationCode.isNotEmpty;

  bool get canSubmit =>
      !isSubmitting &&
      isNameValid &&
      isEmailValid &&
      isPhoneValid &&
      isPhoneVerified &&
      isPasswordValid &&
      isConfirmPasswordValid;

  String? get nameError {
    if (!nameTouched) return null;
    if (!isNameValid) return AuthMessages.signUpNameEmpty;
    return null;
  }

  String? get emailError {
    if (!emailTouched) return null;
    if (email.isEmpty) return null;
    if (!isEmailValid) return AuthMessages.signUpEmailInvalid;
    return null;
  }

  bool get showEmailSuccess => emailTouched && email.isNotEmpty && isEmailValid;

  String? get phoneError {
    if (phoneVerificationError != null) return null;
    if (!phoneTouched) return null;
    if (phone.isEmpty) return null;
    if (!isPhoneValid) return AuthMessages.signUpPhoneInvalid;
    return null;
  }

  String? get phoneVerificationErrorMessage => phoneVerificationError;

  bool get showPhoneSuccess => isPhoneVerified;

  String? get passwordError {
    if (!passwordTouched) return null;
    if (password.isEmpty || !isPasswordValid) {
      return AuthMessages.signUpPasswordInvalid;
    }
    return null;
  }

  String? get confirmPasswordError {
    if (!confirmPasswordTouched) return null;
    if (confirmPassword.isEmpty) return null;
    if (!isConfirmPasswordValid) return AuthMessages.signUpPasswordMismatch;
    return null;
  }

  SignUpFormState copyWith({
    String? name,
    String? email,
    String? phone,
    String? verificationCode,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? isPhoneVerified,
    bool? isVerifyingPhone,
    bool? verificationCodeSent,
    bool? isSubmitting,
    bool? nameTouched,
    bool? emailTouched,
    bool? phoneTouched,
    bool? verificationCodeTouched,
    bool? passwordTouched,
    bool? confirmPasswordTouched,
    String? phoneVerificationError,
    String? submitError,
    bool clearPhoneVerificationError = false,
    bool clearSubmitError = false,
  }) {
    return SignUpFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      verificationCode: verificationCode ?? this.verificationCode,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isVerifyingPhone: isVerifyingPhone ?? this.isVerifyingPhone,
      verificationCodeSent: verificationCodeSent ?? this.verificationCodeSent,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      nameTouched: nameTouched ?? this.nameTouched,
      emailTouched: emailTouched ?? this.emailTouched,
      phoneTouched: phoneTouched ?? this.phoneTouched,
      verificationCodeTouched:
          verificationCodeTouched ?? this.verificationCodeTouched,
      passwordTouched: passwordTouched ?? this.passwordTouched,
      confirmPasswordTouched:
          confirmPasswordTouched ?? this.confirmPasswordTouched,
      phoneVerificationError: clearPhoneVerificationError
          ? null
          : phoneVerificationError ?? this.phoneVerificationError,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
    );
  }
}

class SignUpFormNotifier extends AutoDisposeNotifier<SignUpFormState> {
  static const _mockVerificationCode = '000000';

  @override
  SignUpFormState build() => const SignUpFormState();

  void updateName(String value) {
    state = state.copyWith(name: value, nameTouched: true);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value.trim(), emailTouched: true);
  }

  void updatePhone(String value) {
    final formatted = AuthValidators.hasInvalidPhoneCharacters(value)
        ? value
        : AuthValidators.formatPhone(value);

    state = state.copyWith(
      phone: formatted,
      phoneTouched: true,
      isPhoneVerified: false,
      verificationCodeSent: false,
      verificationCode: '',
      clearPhoneVerificationError: true,
    );
  }

  void updateVerificationCode(String value) {
    state = state.copyWith(
      verificationCode: value.replaceAll(RegExp(r'\D'), ''),
      verificationCodeTouched: true,
      clearPhoneVerificationError: true,
    );
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, passwordTouched: true);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordTouched: true,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
      obscureConfirmPassword: !state.obscureConfirmPassword,
    );
  }

  Future<void> requestVerificationCode() async {
    if (!state.canRequestVerification) return;

    state = state.copyWith(
      isVerifyingPhone: true,
      clearPhoneVerificationError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isVerifyingPhone: false,
      verificationCodeSent: true,
    );
  }

  Future<void> confirmVerificationCode() async {
    if (!state.canConfirmVerification) return;

    state = state.copyWith(
      isVerifyingPhone: true,
      verificationCodeTouched: true,
      clearPhoneVerificationError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (state.verificationCode != _mockVerificationCode) {
      state = state.copyWith(
        isVerifyingPhone: false,
        phoneVerificationError: AuthMessages.signUpVerificationFailed,
      );
      return;
    }

    state = state.copyWith(
      isVerifyingPhone: false,
      isPhoneVerified: true,
      clearPhoneVerificationError: true,
    );
  }

  Future<bool> submit() async {
    state = state.copyWith(
      nameTouched: true,
      emailTouched: true,
      phoneTouched: true,
      passwordTouched: true,
      confirmPasswordTouched: true,
      clearSubmitError: true,
    );
    if (!state.canSubmit) return false;

    state = state.copyWith(isSubmitting: true);
    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.createUser(
        CreateUserRequest(
          email: state.email,
          password: state.password,
          name: state.name.trim(),
          phone: state.phone,
        ),
      );

      final session = await repository.login(state.email, state.password);
      await ref.read(authProvider.notifier).applySession(session);
      syncSessionSideEffectsFromRef(ref, session.user);
      await refreshArtistApprovalStatus(ref.read);

      if (!session.user.isEmailVerified) {
        try {
          await repository.sendVerificationEmail(state.email);
        } catch (_) {
          // 인증 메일 발송 실패해도 가입·로그인은 유지합니다.
        }
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: e.displayMessage,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: AuthMessages.signUpNetworkError,
      );
      return false;
    }
  }
}

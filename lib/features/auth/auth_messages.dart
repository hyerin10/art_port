abstract final class AuthMessages {
  // 로그인
  static const signInEmailInvalid = '올바른 이메일 형식을 입력해주세요.';
  static const signInPasswordEmpty = '비밀번호를 입력해주세요.';
  static const signInNetworkError = '서버에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';

  // 회원가입
  static const signUpNameEmpty = '이름을 입력해주세요.';
  static const signUpEmailInvalid = '올바른 이메일 주소 형식이 아닙니다.';
  static const signUpPhoneInvalid =
      '하이픈(-) 없이 숫자만 입력해주세요.';
  static const signUpVerificationFailed =
      '인증번호가 일치하지 않습니다. 다시 시도해주세요.';
  static const emailVerificationCodeDigitsOnly = '숫자만 입력해주세요.';
  static const emailVerificationCodeLength = '인증번호 6자리를 입력해주세요.';
  static const emailVerificationEmailMissing = '이메일 정보를 확인할 수 없습니다. 다시 로그인해 주세요.';
  static const emailVerificationSendFailed = '인증 메일 발송에 실패했습니다. 잠시 후 다시 시도해 주세요.';
  static const signUpPasswordInvalid =
      '영문, 숫자, 특수문자를 포함하여 8자 이상 입력해주세요.';
  static const signUpPasswordMismatch = '비밀번호가 일치하지 않습니다.';
  static const signUpNetworkError = '회원가입에 실패했습니다. 네트워크 상태를 확인해주세요.';

  // 비밀번호 찾기
  static const forgotPasswordEmailInvalid = '올바른 이메일 형식을 입력해 주세요.';
  static const forgotPasswordEmailNotFound = '존재하지 않는 이메일 주소입니다.';
  static const forgotPasswordSuccessMessage =
      '임시 비밀번호가 이메일로 발송되었습니다. 로그인 후 비밀번호를 반드시 변경해 주세요.';
}

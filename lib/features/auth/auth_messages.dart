abstract final class AuthMessages {
  // 로그인
  static const signInEmailInvalid = '올바른 이메일 형식을 입력해주세요.';
  static const signInPasswordEmpty = '비밀번호를 입력해주세요.';

  // 회원가입
  static const signUpNameEmpty = '이름을 입력해주세요.';
  static const signUpEmailInvalid = '올바른 이메일 주소 형식이 아닙니다.';
  static const signUpPhoneInvalid =
      '하이픈(-) 없이 숫자만 입력해주세요.';
  static const signUpVerificationFailed =
      '인증번호가 일치하지 않습니다. 다시 시도해주세요.';
  static const signUpPasswordInvalid =
      '영문, 숫자, 특수문자를 포함하여 8자 이상 입력해주세요.';
  static const signUpPasswordMismatch = '비밀번호가 일치하지 않습니다.';
}

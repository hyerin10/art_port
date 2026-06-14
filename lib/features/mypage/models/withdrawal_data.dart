/// 출금 신청 화면 상태
class WithdrawalState {
  const WithdrawalState({
    this.availableAmount = 120_000,
    this.requestedAmount = 0,
    this.feeAmount = 0,
    this.bankName = '신한은행',
    this.maskedAccountNumber = '110-***-***1...',
    this.accountHolder = '홍길동',
    this.isSubmitting = false,
  });

  static const int minWithdrawalAmount = 10_000;

  final int availableAmount;
  final int requestedAmount;
  final int feeAmount;
  final String bankName;
  final String maskedAccountNumber;
  final String accountHolder;
  final bool isSubmitting;

  int get finalDepositAmount =>
      (requestedAmount - feeAmount).clamp(0, requestedAmount);

  bool get canSubmit =>
      !isSubmitting &&
      requestedAmount >= minWithdrawalAmount &&
      requestedAmount <= availableAmount;

  WithdrawalState copyWith({
    int? availableAmount,
    int? requestedAmount,
    int? feeAmount,
    String? bankName,
    String? maskedAccountNumber,
    String? accountHolder,
    bool? isSubmitting,
  }) {
    return WithdrawalState(
      availableAmount: availableAmount ?? this.availableAmount,
      requestedAmount: requestedAmount ?? this.requestedAmount,
      feeAmount: feeAmount ?? this.feeAmount,
      bankName: bankName ?? this.bankName,
      maskedAccountNumber:
          maskedAccountNumber ?? this.maskedAccountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

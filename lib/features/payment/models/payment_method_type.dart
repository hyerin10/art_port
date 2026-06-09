/// 결제 수단
enum PaymentMethodType {
  creditCard('신용 / 체크카드', 'Credit / Debit Card'),
  easyPay('간편결제', 'Easy Pay'),
  bankTransfer('계좌이체', 'Account Transfer');

  const PaymentMethodType(this.labelKo, this.labelEn);

  final String labelKo;
  final String labelEn;
}

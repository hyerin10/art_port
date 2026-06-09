/// 커미션 거래 진행 상태
enum CommissionStatus {
  submitted,
  accepted,
  paymentRequested,
  paid;

  String get statusBarLabel => switch (this) {
        CommissionStatus.submitted =>
          'Status: Form Submitted / 신청서 제출됨',
        CommissionStatus.accepted => 'Status: Accepted / 작가 수락됨',
        CommissionStatus.paymentRequested =>
          'Status: Payment Requested / 결제 요청됨',
        CommissionStatus.paid => 'Status: Payment Completed / 결제 완료',
      };

  bool get showsPaymentCard =>
      this == CommissionStatus.paymentRequested || this == CommissionStatus.paid;

  /// 주문 현황 탭 뱃지 라벨
  String get orderLabel => switch (this) {
        CommissionStatus.submitted => '신청서 제출됨',
        CommissionStatus.accepted => '작가 수락됨',
        CommissionStatus.paymentRequested => '결제 대기 중',
        CommissionStatus.paid => '거래 완료',
      };
}

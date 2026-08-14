/// 커미션 거래 진행 상태
enum CommissionStatus {
  submitted,
  accepted,
  paymentRequested,
  paid,
  working,
  completed,
  rejected,
  cancelled,
  refunded;

  String get statusBarLabel => switch (this) {
        CommissionStatus.submitted =>
          'Status: Form Submitted / 신청서 제출됨',
        CommissionStatus.accepted => 'Status: Accepted / 작가 수락됨',
        CommissionStatus.paymentRequested =>
          'Status: Payment Requested / 결제 요청됨',
        CommissionStatus.paid => 'Status: Payment Completed / 결제 완료',
        CommissionStatus.working => 'Status: In Progress / 작업 진행 중',
        CommissionStatus.completed => 'Status: Completed / 작업 완료',
        CommissionStatus.rejected => 'Status: Declined / 거절됨',
        CommissionStatus.cancelled => 'Status: Cancelled / 취소됨',
        CommissionStatus.refunded => 'Status: Refunded / 환불됨',
      };

  bool get showsPaymentCard =>
      this == CommissionStatus.paymentRequested || this == CommissionStatus.paid;

  bool get isDeclined =>
      this == CommissionStatus.rejected ||
      this == CommissionStatus.cancelled ||
      this == CommissionStatus.refunded;

  bool get hasBeenAccepted => switch (this) {
        CommissionStatus.submitted ||
        CommissionStatus.rejected ||
        CommissionStatus.cancelled ||
        CommissionStatus.refunded =>
          false,
        _ => true,
      };

  /// 주문 현황 탭 뱃지 라벨
  String get orderLabel => switch (this) {
        CommissionStatus.submitted => '신청서 제출됨',
        CommissionStatus.accepted => '작가 수락됨',
        CommissionStatus.paymentRequested => '결제 대기 중',
        CommissionStatus.paid => '결제 완료',
        CommissionStatus.working => '작업 중',
        CommissionStatus.completed => '작업 완료',
        CommissionStatus.rejected => '거절됨',
        CommissionStatus.cancelled => '취소됨',
        CommissionStatus.refunded => '환불됨',
      };
}

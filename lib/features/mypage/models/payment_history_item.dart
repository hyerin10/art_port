/// 결제 내역 상태
enum PaymentStatus {
  completed,
  processing,
  canceled,
}

/// 결제 수단
enum PaymentMethod {
  creditCard,
  bankTransfer,
}

extension PaymentStatusLabel on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.completed => '결제 완료',
        PaymentStatus.processing => '처리 중',
        PaymentStatus.canceled => '결제 취소',
      };
}

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.creditCard => '신용카드',
        PaymentMethod.bankTransfer => '계좌이체',
      };
}

/// 결제 및 영수증 목록·상세용 데이터 모델
class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.orderId,
    required this.imageUrl,
    required this.title,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.paidAt,
    required this.paymentMethod,
    required this.totalAmount,
    required this.subtotalAmount,
    required this.vatAmount,
    required this.status,
  });

  final String id;
  final String orderId;
  final String imageUrl;
  final String title;
  final String artistName;
  final String artistAvatarUrl;
  final DateTime paidAt;
  final PaymentMethod paymentMethod;
  final int totalAmount;
  final int subtotalAmount;
  final int vatAmount;
  final PaymentStatus status;

  String get paidAtLabel {
    final y = paidAt.year;
    final m = paidAt.month.toString().padLeft(2, '0');
    final d = paidAt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  String get totalAmountLabel => _formatWon(totalAmount);

  String get subtotalAmountLabel => _formatWon(subtotalAmount);

  String get vatAmountLabel => _formatWon(vatAmount);

  static String _formatWon(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer('₩');
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

/// 결제 내역 더미 데이터
abstract final class PaymentHistoryDummyData {
  static final List<PaymentHistoryItem> items = [
    PaymentHistoryItem(
      id: 'pay-001',
      orderId: 'ORD-2026-001234',
      imageUrl:
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=200&h=200&fit=crop',
      title: '캐릭터 일러스트',
      artistName: 'ChocoArt',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop',
      paidAt: DateTime(2026, 6, 5),
      paymentMethod: PaymentMethod.creditCard,
      totalAmount: 150000,
      subtotalAmount: 136364,
      vatAmount: 13636,
      status: PaymentStatus.completed,
    ),
    PaymentHistoryItem(
      id: 'pay-002',
      orderId: 'ORD-2026-001189',
      imageUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&h=200&fit=crop',
      title: '배경 일러스트',
      artistName: 'SkyPainter',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop',
      paidAt: DateTime(2026, 6, 3),
      paymentMethod: PaymentMethod.bankTransfer,
      totalAmount: 220000,
      subtotalAmount: 200000,
      vatAmount: 20000,
      status: PaymentStatus.processing,
    ),
    PaymentHistoryItem(
      id: 'pay-003',
      orderId: 'ORD-2026-000987',
      imageUrl:
          'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=200&h=200&fit=crop',
      title: '캐릭터 디자인',
      artistName: 'PixelMuse',
      artistAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
      paidAt: DateTime(2026, 5, 28),
      paymentMethod: PaymentMethod.creditCard,
      totalAmount: 95000,
      subtotalAmount: 86364,
      vatAmount: 8636,
      status: PaymentStatus.canceled,
    ),
  ];
}

import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:art_port/features/commission/models/commission_status.dart';
import 'package:art_port/features/commission/models/commission_transaction.dart';

/// 작업실 주문 현황 탭용 뷰 모델 — [CommissionTransaction]에서 파생
class WorkroomCommissionOrder {
  const WorkroomCommissionOrder({
    required this.roomId,
    required this.title,
    required this.counterpartName,
    required this.avatarUrl,
    required this.status,
    required this.updatedAt,
    required this.priceWon,
    this.isDeclined = false,
    this.deadlineLabel,
  });

  final String roomId;
  final String title;
  final String counterpartName;
  final String avatarUrl;
  final CommissionStatus status;
  final DateTime updatedAt;
  final int priceWon;
  final bool isDeclined;
  final String? deadlineLabel;

  String get priceLabel => CurrencyFormatter.formatWon(priceWon);

  String get counterpartLabel => 'with $counterpartName';

  factory WorkroomCommissionOrder.fromTransaction(
    CommissionTransaction transaction, {
    required bool isArtistMode,
  }) {
    final deadline = transaction.application.desiredDeadline;
    final deadlineLabel = deadline != null
        ? '마감일: ${deadline.year}.${deadline.month.toString().padLeft(2, '0')}.${deadline.day.toString().padLeft(2, '0')}'
        : null;

    return WorkroomCommissionOrder(
      roomId: transaction.roomId,
      title: transaction.commissionTitle,
      counterpartName:
          isArtistMode ? transaction.clientName : transaction.artistName,
      avatarUrl:
          isArtistMode ? transaction.clientAvatarUrl : transaction.artistAvatarUrl,
      status: transaction.status,
      updatedAt: transaction.updatedAt,
      priceWon: transaction.totalAmountWon,
      isDeclined: transaction.isDeclined,
      deadlineLabel: deadlineLabel,
    );
  }
}

/// 상대 시간 라벨 (예: 방금, 5분 전)
String formatWorkroomRelativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);

  if (diff.inSeconds < 60) return '방금';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';

  final month = timestamp.month.toString().padLeft(2, '0');
  final day = timestamp.day.toString().padLeft(2, '0');
  return '${timestamp.year}.$month.$day';
}

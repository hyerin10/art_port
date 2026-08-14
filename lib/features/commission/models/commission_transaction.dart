import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/commission/models/commission_status.dart';

/// 채팅방 단위 커미션 거래 상태
class CommissionTransaction {
  const CommissionTransaction({
    required this.orderId,
    required this.roomId,
    required this.status,
    required this.application,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.clientName,
    required this.clientAvatarUrl,
    required this.commissionTitle,
    required this.updatedAt,
    required this.baseAmountWon,
    required this.serviceFeeWon,
    required this.totalAmountWon,
    this.additionalAmountWon = 0,
    this.artistId,
    this.isDeclined = false,
  });

  final String orderId;
  final String roomId;
  final CommissionStatus status;
  final CommissionApplySubmission application;
  final String artistName;
  final String artistAvatarUrl;
  final String clientName;
  final String clientAvatarUrl;
  final String commissionTitle;
  final DateTime updatedAt;
  final String? artistId;
  final bool isDeclined;
  final int baseAmountWon;
  final int additionalAmountWon;
  final int serviceFeeWon;
  final int totalAmountWon;

  CommissionTransaction copyWith({
    CommissionStatus? status,
    bool? isDeclined,
    DateTime? updatedAt,
  }) {
    return CommissionTransaction(
      orderId: orderId,
      roomId: roomId,
      status: status ?? this.status,
      application: application,
      artistName: artistName,
      artistAvatarUrl: artistAvatarUrl,
      clientName: clientName,
      clientAvatarUrl: clientAvatarUrl,
      commissionTitle: commissionTitle,
      updatedAt: updatedAt ?? this.updatedAt,
      artistId: artistId,
      isDeclined: isDeclined ?? this.isDeclined,
      baseAmountWon: baseAmountWon,
      additionalAmountWon: additionalAmountWon,
      serviceFeeWon: serviceFeeWon,
      totalAmountWon: totalAmountWon,
    );
  }
}

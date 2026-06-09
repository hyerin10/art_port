import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/commission/models/commission_status.dart';

/// 채팅방 단위 커미션 거래 상태
class CommissionTransaction {
  const CommissionTransaction({
    required this.roomId,
    required this.status,
    required this.application,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.clientName,
    required this.clientAvatarUrl,
    required this.commissionTitle,
    required this.updatedAt,
    this.artistId,
    this.isDeclined = false,
  });

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

  int get baseAmountWon => application.selectedOption.priceWon;

  int get serviceFeeWon => (baseAmountWon * 0.05).round();

  int get totalAmountWon => baseAmountWon + serviceFeeWon;

  CommissionTransaction copyWith({
    CommissionStatus? status,
    bool? isDeclined,
    DateTime? updatedAt,
  }) {
    return CommissionTransaction(
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
    );
  }
}

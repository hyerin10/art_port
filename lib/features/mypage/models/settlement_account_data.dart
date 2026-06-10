import 'package:art_port/features/artist_application/models/artist_application_data.dart';

/// 정산 계좌 관리 폼 상태
class SettlementAccountState {
  const SettlementAccountState({
    this.selectedBank,
    this.accountNumber = '',
    this.accountHolder = '김하늘',
    this.isVerified = false,
    this.isVerifying = false,
    this.isSaving = false,
  });

  final String? selectedBank;
  final String accountNumber;
  final String accountHolder;
  final bool isVerified;
  final bool isVerifying;
  final bool isSaving;

  static const bankOptions = ArtistApplicationData.bankOptions;

  bool get hasValidAccountNumber =>
      accountNumber.length >= 10 && RegExp(r'^\d+$').hasMatch(accountNumber);

  bool get canVerify =>
      !isVerified &&
      !isVerifying &&
      selectedBank != null &&
      selectedBank!.isNotEmpty &&
      hasValidAccountNumber;

  bool get canSave => isVerified && !isSaving;

  SettlementAccountState copyWith({
    String? selectedBank,
    bool clearSelectedBank = false,
    String? accountNumber,
    String? accountHolder,
    bool? isVerified,
    bool? isVerifying,
    bool? isSaving,
  }) {
    return SettlementAccountState(
      selectedBank: clearSelectedBank ? null : (selectedBank ?? this.selectedBank),
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolder: accountHolder ?? this.accountHolder,
      isVerified: isVerified ?? this.isVerified,
      isVerifying: isVerifying ?? this.isVerifying,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

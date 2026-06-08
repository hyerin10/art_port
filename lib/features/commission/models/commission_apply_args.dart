import 'package:art_port/features/commission/models/commission_detail.dart';

/// 커미션 상세 → 신청 페이지로 전달하는 인자
class CommissionApplyArgs {
  const CommissionApplyArgs({
    required this.commissionId,
    required this.commissionTitle,
    required this.artistName,
    required this.selectedOption,
  });

  final String commissionId;
  final String commissionTitle;
  final String artistName;
  final CommissionPriceOption selectedOption;
}

/// 사용 용도 선택지
enum CommissionUsagePurpose {
  personal('개인 소장', 'Personal'),
  commercial('상업적 이용', 'Commercial'),
  broadcasting('방송 사용', 'Broadcasting');

  const CommissionUsagePurpose(this.labelKo, this.labelEn);

  final String labelKo;
  final String labelEn;

  String get displayLabel => '$labelKo ($labelEn)';
}

/// 커미션 신청서 제출 데이터
class CommissionApplySubmission {
  const CommissionApplySubmission({
    required this.commissionId,
    required this.commissionTitle,
    required this.artistName,
    required this.selectedOption,
    required this.requestContent,
    required this.referenceImagePaths,
    required this.usagePurpose,
    this.desiredDeadline,
    required this.submittedAt,
  });

  final String commissionId;
  final String commissionTitle;
  final String artistName;
  final CommissionPriceOption selectedOption;
  final String requestContent;
  final List<String> referenceImagePaths;
  final CommissionUsagePurpose usagePurpose;
  final DateTime? desiredDeadline;
  final DateTime submittedAt;
}

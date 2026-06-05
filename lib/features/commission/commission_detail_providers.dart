import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commissionDetailProvider =
    Provider.family<CommissionDetail?, String>((ref, commissionId) {
  return CommissionDetailData.forId(commissionId);
});


import 'package:art_port/features/commission/data/commission_detail_dummy_data.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commissionDetailProvider =
    Provider.family<CommissionDetail?, String>((ref, commissionId) {
  return CommissionDetailDummyData.forId(commissionId);
});


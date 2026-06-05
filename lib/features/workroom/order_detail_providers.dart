import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workroomOrderDetailProvider =
    Provider.family<WorkroomOrderDetail?, String>((ref, orderId) {
  return WorkroomOrderDetailData.forOrderId(orderId);
});

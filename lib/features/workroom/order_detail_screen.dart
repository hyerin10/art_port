import 'package:art_port/features/workroom/order_detail_view.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return OrderDetailView(orderId: orderId);
  }
}

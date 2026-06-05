import 'package:art_port/features/commission/commission_detail_view.dart';
import 'package:flutter/material.dart';

class CommissionDetailScreen extends StatelessWidget {
  const CommissionDetailScreen({super.key, required this.commissionId});

  final String commissionId;

  static void open(BuildContext context, {required String commissionId}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommissionDetailScreen(commissionId: commissionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommissionDetailView(commissionId: commissionId);
  }
}

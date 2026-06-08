import 'package:art_port/features/commission/commission_apply_view.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:flutter/material.dart';

class CommissionApplyScreen extends StatelessWidget {
  const CommissionApplyScreen({super.key, required this.args});

  final CommissionApplyArgs args;

  static void open(BuildContext context, {required CommissionApplyArgs args}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommissionApplyScreen(args: args),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommissionApplyView(args: args);
  }
}

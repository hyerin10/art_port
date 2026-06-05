import 'package:art_port/features/mypage/commission_type_form_view.dart';
import 'package:flutter/material.dart';

class CommissionTypeFormScreen extends StatelessWidget {
  const CommissionTypeFormScreen({
    super.key,
    this.editingTypeId,
  });

  /// null이면 새 타입 추가, 값이 있으면 수정 모드
  final String? editingTypeId;

  static Future<bool?> openAdd(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const CommissionTypeFormScreen(),
      ),
    );
  }

  static Future<bool?> openEdit(BuildContext context, String typeId) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CommissionTypeFormScreen(editingTypeId: typeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommissionTypeFormView(editingTypeId: editingTypeId);
  }
}

import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:flutter/material.dart';

/// 커미션 타입 폼 텍스트 컨트롤러 묶음
class CommissionTypeFormControllers {
  final name = TextEditingController();
  final price = TextEditingController();
  final workPeriod = TextEditingController();
  final totalSlots = TextEditingController();
  final description = TextEditingController();

  var _initialized = false;

  void syncFrom(CommissionTypeFormState form) {
    if (_initialized) return;

    name.text = form.name;
    price.text = form.startingPrice;
    workPeriod.text = form.workPeriod;
    totalSlots.text = form.totalSlots;
    description.text = form.description;
    _initialized = true;
  }

  void dispose() {
    name.dispose();
    price.dispose();
    workPeriod.dispose();
    totalSlots.dispose();
    description.dispose();
  }
}

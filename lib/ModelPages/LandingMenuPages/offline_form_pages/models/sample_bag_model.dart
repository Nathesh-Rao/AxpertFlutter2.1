import 'package:flutter/material.dart';

class SampleBagModel {
  final int sno;

  final TextEditingController brokenCtrl = TextEditingController();
  final TextEditingController neckChipCtrl = TextEditingController();
  final TextEditingController extraDirtyCtrl = TextEditingController();
  final TextEditingController shortCtrl = TextEditingController();
  final TextEditingController otherBrandCtrl = TextEditingController();
  final TextEditingController otherKfCtrl = TextEditingController();
  final TextEditingController tornBagsCtrl = TextEditingController();
  final TextEditingController mafDateCtrl = TextEditingController();
  final TextEditingController mafYearCtrl = TextEditingController();

  SampleBagModel({required this.sno});
}

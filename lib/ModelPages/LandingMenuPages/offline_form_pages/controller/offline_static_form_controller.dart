import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfflineStaticFormController extends GetxController {
  // ================= BASIC INFO =================

  final ubGeNoCtrl = TextEditingController();
  final vehicleNoCtrl = TextEditingController();
  final receiptDateCtrl = TextEditingController();

  final unit = ''.obs;

  // ================= SUPPLIER =================

  final s1Name = ''.obs;
  final s1DcCtrl = TextEditingController();
  final s2District = ''.obs;
  final s2NameCtrl = TextEditingController();

  // ================= BOTTLE =================

  final bottleType = ''.obs;
  final bottleCapacity = ''.obs;
  final bottlePerCrate = ''.obs;
  final manufacturingDateCtrl = TextEditingController();

  // ================= WEIGHT =================

  final loadedWeightCtrl = TextEditingController();
  final emptyWeightCtrl = TextEditingController();
  final netWeightCtrl = TextEditingController();

  // ================= QUANTITY =================

  final receivedBagsCtrl = TextEditingController();
  final bagsToSampleCtrl = TextEditingController();

  // ================= ERRORS =================

  final errors = <String, String>{}.obs;

  // ================= VALIDATION =================

  bool validate() {
    errors.clear();

    void req(String key, String val, String label) {
      if (val.trim().isEmpty) {
        errors[key] = '$label is required';
      }
    }

    req('ubGeNo', ubGeNoCtrl.text, 'UB G.E No');
    req('unit', unit.value, 'Unit');
    req('receiptDate', receiptDateCtrl.text, 'Receipt Date');
    req('vehicleNo', vehicleNoCtrl.text, 'Vehicle No');

    req('s1Name', s1Name.value, 'S1 Name');
    req('s1Dc', s1DcCtrl.text, 'S1 DC');

    req('bottleType', bottleType.value, 'Bottle Type');
    req('bottleCapacity', bottleCapacity.value, 'Bottle Capacity');
    req('bottlePerCrate', bottlePerCrate.value, 'Bottle Per Bag / Crate');

    req('loadedWeight', loadedWeightCtrl.text, 'Loaded Weight');
    req('emptyWeight', emptyWeightCtrl.text, 'Empty Weight');
    req('netWeight', netWeightCtrl.text, 'Net Weight');

    req('receivedBags', receivedBagsCtrl.text, 'Received Bags');
    req('bagsToSample', bagsToSampleCtrl.text, 'Bags To Sample');

    return errors.isEmpty;
  }

  // ================= COLLECT DATA =================

  Map<String, dynamic> collectData() {
    return {
      "ub_ge_no": ubGeNoCtrl.text,
      "unit": unit.value,
      "receipt_date": receiptDateCtrl.text,
      "vehicle_no": vehicleNoCtrl.text,

      "s1_name": s1Name.value,
      "s1_dc": s1DcCtrl.text,
      "s2_district": s2District.value,
      "s2_name": s2NameCtrl.text,

      "bottle_type": bottleType.value,
      "bottle_capacity": bottleCapacity.value,
      "bottle_per_crate": bottlePerCrate.value,
      "manufacturing_date": manufacturingDateCtrl.text,

      "loaded_weight": loadedWeightCtrl.text,
      "empty_weight": emptyWeightCtrl.text,
      "net_weight": netWeightCtrl.text,

      "received_bags": receivedBagsCtrl.text,
      "bags_to_sample": bagsToSampleCtrl.text,
    };
  }

  // ================= RESET =================

  void resetForm() {
    ubGeNoCtrl.clear();
    vehicleNoCtrl.clear();
    receiptDateCtrl.clear();

    unit.value = '';

    s1Name.value = '';
    s1DcCtrl.clear();
    s2District.value = '';
    s2NameCtrl.clear();

    bottleType.value = '';
    bottleCapacity.value = '';
    bottlePerCrate.value = '';
    manufacturingDateCtrl.clear();

    loadedWeightCtrl.clear();
    emptyWeightCtrl.clear();
    netWeightCtrl.clear();

    receivedBagsCtrl.clear();
    bagsToSampleCtrl.clear();

    errors.clear();
  }

  @override
  void onClose() {
    ubGeNoCtrl.dispose();
    vehicleNoCtrl.dispose();
    receiptDateCtrl.dispose();
    s1DcCtrl.dispose();
    s2NameCtrl.dispose();
    manufacturingDateCtrl.dispose();
    loadedWeightCtrl.dispose();
    emptyWeightCtrl.dispose();
    netWeightCtrl.dispose();
    receivedBagsCtrl.dispose();
    bagsToSampleCtrl.dispose();
    super.onClose();
  }
}

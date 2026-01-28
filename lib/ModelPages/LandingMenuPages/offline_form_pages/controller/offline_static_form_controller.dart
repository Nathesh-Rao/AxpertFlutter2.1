import 'dart:async';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/db/offline_db_module.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/sample_bag_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineStaticFormController extends GetxController {
  final showMiniFab = false.obs;
  final RxList<SampleBagModel> sampleBags = <SampleBagModel>[].obs;
  Timer? _bagsToSampleDebounce;
  var currentCardIndex = 0.obs;
  var isAtTop = true.obs;
  final pendingCount = 0.obs;
  @override
  void onInit() {
    resetForm();

    receivedBagsCtrl.addListener(_onReceivedChanged);
    bagsToSampleCtrl.addListener(_recheckMiniFab);
    refreshPendingCount();
    super.onInit();
  }

  Future<void> refreshPendingCount() async {
    try {
      int count = await OfflineDbModule.getPendingCount();
      pendingCount.value = count;
    } catch (e) {
      print("Error fetching pending count: $e");
    }
  }

  void _onReceivedChanged() {
    final received = int.tryParse(receivedBagsCtrl.text.trim()) ?? 0;

    if (received < 20) {
      bagsToSampleCtrl.text = '';
      sampleBags.clear();
      _recheckMiniFab();
      return;
    }

    int sample = (received * 5) ~/ 100;
    if (sample < 1) sample = 1;

    bagsToSampleCtrl.text = sample.toString();

    _generateSampleCards(sample);

    _recheckMiniFab();
  }

  void onBagsToSampleChanged(String value) {
    _bagsToSampleDebounce?.cancel();

    _bagsToSampleDebounce = Timer(const Duration(seconds: 1), () {
      final int count = int.tryParse(value) ?? 0;

      if (count >= 1) {
        _generateSampleCards(count);
        showMiniFab.value = true;
        openSampleDetailsDialog();
      } else {
        showMiniFab.value = false;
        clearSampleCards();
      }
    });
  }

  void clearSampleCards() {
    for (final bag in sampleBags) {
      bag.brokenCtrl.dispose();
      bag.neckChipCtrl.dispose();
      bag.extraDirtyCtrl.dispose();
      bag.shortCtrl.dispose();
      bag.otherBrandCtrl.dispose();
      bag.otherKfCtrl.dispose();
      bag.tornBagsCtrl.dispose();
      bag.mafDateCtrl.dispose();
      bag.mafYearCtrl.dispose();
    }
    sampleBags.clear();
  }

  void _generateSampleCards(int count) {
    sampleBags.clear();

    for (int i = 0; i < count; i++) {
      sampleBags.add(SampleBagModel(sno: i + 1));
    }
  }

  void _recheckMiniFab() {
    final received = int.tryParse(receivedBagsCtrl.text.trim()) ?? 0;
    final sample = int.tryParse(bagsToSampleCtrl.text.trim()) ?? 0;

    if (received >= 1 && sample >= 1) {
      showMiniFab.value = true;
    } else {
      showMiniFab.value = false;
    }
  }

  void openSampleDetailsDialog() {
    currentCardIndex.value = 0;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          height: Get.height * 0.85,
          width: Get.width,
          child: Column(
            children: [
              // ---------- HEADER ----------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Chip(
                        backgroundColor: Colors.white,
                        label: Obx(() => Text(
                              "Item ${currentCardIndex.value + 1} of ${sampleBags.length}",
                              style:
                                  GoogleFonts.poppins(color: MyColors.baseBlue),
                            ))),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Chip(
                          backgroundColor: Colors.white,
                          label: Text(
                            "Close",
                            style: GoogleFonts.poppins(color: MyColors.baseRed),
                          )),
                    ),
                  ],
                ),
              ),
              // // ---------- PAGE VIEW ----------
              Expanded(
                child: PageView.builder(
                  onPageChanged: (i) {
                    currentCardIndex.value = i;
                  },
                  itemCount: sampleBags.length,
                  itemBuilder: (context, index) {
                    final bag = sampleBags[index];
                    return _buildSampleFormPage(bag);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleFormPage(SampleBagModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ---------- HEADER ----------
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "ID: ${model.sno}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.swipe, size: 18, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 10),
            _compactField("Broken", model.brokenCtrl),
            _compactField("Neck Chip", model.neckChipCtrl),
            _compactField("Extra Dirty", model.extraDirtyCtrl),
            _compactField("Short", model.shortCtrl),
            _compactField("Other Brand", model.otherBrandCtrl),
            _compactField("Other KF", model.otherKfCtrl),
            _compactField("Torn Bags", model.tornBagsCtrl),
            _compactField("Maf Date", model.mafDateCtrl),
            _compactField("Maf Year", model.mafYearCtrl),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _compactField(String label, TextEditingController controller) {
    final Color accent =
        const Color(0xFF2563EB); // you can vary per card if needed

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---------- COLORED LABEL STRIP ----------
          Container(
            width: 110,
            height: double.infinity,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
              border: Border(
                right: BorderSide(
                  color: accent.withOpacity(0.25),
                ),
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),

          // ---------- INPUT ----------
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "-",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              // onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

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
  final loadedWeightCtrl = TextEditingController();
  final emptyWeightCtrl = TextEditingController();
  final netWeightCtrl = TextEditingController();
  final receivedBagsCtrl = TextEditingController();
  final bagsToSampleCtrl = TextEditingController();

  final errors = <String, String>{}.obs;

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

    showMiniFab.value = false;
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
    _bagsToSampleDebounce?.cancel();

    super.onClose();
  }
}

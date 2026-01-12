import 'dart:async';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/inward_entry_consolidated_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:axpertflutter/Constants/MyColors.dart';

import 'inward_entry_schema.dart';

class InwardEntryDynamicController extends GetxController {
  // ================== SCHEMA ==================
  final Map<String, dynamic> schema = InwardEntrySchema.schema;

  // ================== FIELD CONTROLLERS ==================
  final Map<String, TextEditingController> textCtrls = {};
  final Map<String, RxString> dropdownCtrls = {};
  final ScrollController scrollCtrl = ScrollController();
  final PageController pageController = PageController();
  Map<String, dynamic> mainFormJson = {};
  List<Map<String, dynamic>> sampleGridJson = [];
  Map<String, dynamic> sampleSummaryJson = {};
  RxMap<String, List<String>> imageAttachmentJson =
      <String, List<String>>{}.obs;

  TextEditingController getTextCtrl(String name) => textCtrls[name]!;
  RxString getDropdownCtrl(String name) => dropdownCtrls[name]!;

  // ================== UI STATE ==================
  final showMiniFab = false.obs;
  var isAtTop = true.obs;
  var currentCardIndex = 0.obs;

  // ================== SAMPLE GRID ==================
  final RxList<Map<String, TextEditingController>> sampleGridRows =
      <Map<String, TextEditingController>>[].obs;

  Timer? _bagsToSampleDebounce;

  // ================== ERRORS (for later UI) ==================
  final errors = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    scrollCtrl.addListener(() {
      if (!scrollCtrl.hasClients) return;

      final max = scrollCtrl.position.maxScrollExtent;
      final offset = scrollCtrl.offset;

      if (offset > max - 80) {
        isAtTop.value = false;
      } else if (offset < 80) {
        isAtTop.value = true;
      }
    });
    _buildControllersFromSchema();
    _attachBusinessListeners();
    resetForm();
  }

  prepareForm() {
    resetForm();
    scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // ================== BUILD CONTROLLERS FROM JSON ==================

  void _buildControllersFromSchema() {
    final List fields = schema["fields"];

    for (final f in fields) {
      final String name = f["fld_name"];
      final String type = f["fld_type"];

      if (type == "dd") {
        dropdownCtrls[name] = "".obs;
      } else {
        textCtrls[name] = TextEditingController();
      }
    }
  }

  void _attachBusinessListeners() {
    // receivedBags logic
    getTextCtrl("receivedBags").addListener(_onReceivedChanged);
    // bagsToSample logic
    getTextCtrl("bagsToSample").addListener(_recheckMiniFab);
    getTextCtrl("loadedWeight").addListener(_calculateNetWeight);
    getTextCtrl("loadedWeight").addListener(_calculateNetWeight);
    getTextCtrl("emptyWeight").addListener(_calculateNetWeight);
    // getTextCtrl("netWeight").addListener(_calculateNetWeight);
  }

  _calculateNetWeight() {
    final loadedWeight =
        int.tryParse(getTextCtrl("loadedWeight").text.trim()) ?? 0;
    final emptyWeight =
        int.tryParse(getTextCtrl("emptyWeight").text.trim()) ?? 0;
    //  final netWeight = int.tryParse(getTextCtrl("netWeight").text.trim()) ?? 0;

    var netweight = loadedWeight - emptyWeight;

    getTextCtrl("netWeight").text = netweight.toString();
  }

  void _onReceivedChanged() {
    final received = int.tryParse(getTextCtrl("receivedBags").text.trim()) ?? 0;

    if (received < 20) {
      getTextCtrl("bagsToSample").text = '';
      clearSampleGrid();
      _recheckMiniFab();
      return;
    }

    int sample = (received * 5) ~/ 100;
    if (sample < 1) sample = 1;

    getTextCtrl("bagsToSample").text = sample.toString();

    _generateSampleGrid(sample);
    _recheckMiniFab();
  }

  void onBagsToSampleChanged(String value) {
    _bagsToSampleDebounce?.cancel();

    _bagsToSampleDebounce = Timer(const Duration(seconds: 1), () {
      final int count = int.tryParse(value) ?? 0;

      if (count >= 1) {
        _generateSampleGrid(count);
        showMiniFab.value = true;
        openSampleDetailsDialog();
      } else {
        showMiniFab.value = false;
        clearSampleGrid();
      }
    });
  }

  void _recheckMiniFab() {
    final received = int.tryParse(getTextCtrl("receivedBags").text.trim()) ?? 0;
    final sample = int.tryParse(getTextCtrl("bagsToSample").text.trim()) ?? 0;

    if (received >= 1 && sample >= 1) {
      showMiniFab.value = true;
    } else {
      showMiniFab.value = false;
    }
  }

  void clearSampleGrid() {
    for (final row in sampleGridRows) {
      for (final c in row.values) {
        c.dispose();
      }
    }
    sampleGridRows.clear();
  }

  void _generateSampleGrid(int count) {
    clearSampleGrid();

    final List gridFields = schema["fillgrids"]["fields"];

    for (int i = 0; i < count; i++) {
      final Map<String, TextEditingController> row = {};

      for (final f in gridFields) {
        final String name = f["fld_name"];
        row[name] = TextEditingController(text: f["def_value"] ?? "");
      }

      sampleGridRows.add(row);
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Chip(
                      backgroundColor: Colors.white,
                      label: Obx(() => Text(
                            "Item ${currentCardIndex.value + 1} of ${sampleGridRows.length}",
                            style:
                                GoogleFonts.poppins(color: MyColors.baseBlue),
                          )),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Chip(
                        backgroundColor: Colors.white,
                        label: Text(
                          "Close",
                          style: GoogleFonts.poppins(color: MyColors.baseRed),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- PAGE VIEW ----------
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (i) {
                    currentCardIndex.value = i;
                  },
                  itemCount: sampleGridRows.length,
                  itemBuilder: (context, index) {
                    final row = sampleGridRows[index];
                    return _buildSampleFormPage(row, index + 1);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Row(
                    children: [
                      currentCardIndex.value != 0
                          ? InkWell(
                              onTap: () {
                                pageController.previousPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.decelerate);
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.arrow_back),
                              ),
                            )
                          : SizedBox(),
                      Spacer(),
                      currentCardIndex.value != sampleGridRows.length - 1
                          ? InkWell(
                              onTap: () {
                                pageController.nextPage(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.decelerate);
                              },
                              child: CircleAvatar(
                                child: Icon(Icons.arrow_forward),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleFormPage(
      Map<String, TextEditingController> model, int sno) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
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
                    "ID: $sno",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.swipe, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            ...model.entries.map((e) {
              return _compactField(e.key, e.value, model);
            }).toList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _compactField(
    String label,
    TextEditingController controller,
    Map<String, TextEditingController> model,
  ) {
    final Color accent = const Color(0xFF2563EB);

    final bool isMafDate = label == "maf_date";
    final bool isMafYear = label == "maf_year";

    final bool isNumeric = !isMafDate && !isMafYear;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: double.infinity,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(10)),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label.replaceAll("_", " ").toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType:
                  isNumeric ? TextInputType.number : TextInputType.text,
              readOnly: isMafDate || isMafYear,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "-",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onTap: () async {
                if (isNumeric) {
                  if (controller.text == "0") {
                    controller.text = "";
                  }
                }

                if (isMafDate) {
                  final d = await showDatePicker(
                    context: Get.context!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (d != null) {
                    controller.text =
                        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

                    // ✅ AUTO-FILL YEAR
                    final row = model; // <-- current row map
                    if (row.containsKey("maf_year")) {
                      row["maf_year"]!.text = d.year.toString();
                    }
                  }
                } else if (isMafYear) {
                  final now = DateTime.now();
                  final y = await showDatePicker(
                    context: Get.context!,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime(now.year),
                    initialDatePickerMode: DatePickerMode.year,
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                  );
                  if (y != null) {
                    controller.text = y.year.toString();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void resetForm() {
    for (final c in textCtrls.values) {
      c.clear();
    }
    for (final d in dropdownCtrls.values) {
      d.value = "";
    }
    clearSampleGrid();
    showMiniFab.value = false;
    errors.clear();
  }

  bool validateForm() {
    errors.clear();

    final List fields = schema["fields"];

    for (final f in fields) {
      final String name = f["fld_name"];
      final String label = f["fld_caption"];
      final String allowEmpty = f["allowempty"] ?? "T";
      final String type = f["fld_type"];

      if (allowEmpty == "F") {
        String value = "";

        if (type == "dd") {
          value = dropdownCtrls[name]?.value ?? "";
        } else {
          value = textCtrls[name]?.text.trim() ?? "";
        }

        if (value.isEmpty) {
          errors[name] = "$label is required";
        }
      }
    }

    return errors.isEmpty;
  }

  void submit() {
    final ok = validateForm();

    if (!ok) {
      Get.snackbar(
        "Validation Error",
        "Please fix the highlighted fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    mainFormJson = buildMainFormJson();
    sampleGridJson = buildSampleGridJson();
    sampleSummaryJson = buildSampleSummaryJson();

    debugPrint("====== MAIN FORM JSON ======");
    debugPrint(mainFormJson.toString());

    debugPrint("====== SAMPLE GRID JSON ======");
    debugPrint(sampleGridJson.toString());

    debugPrint("====== SAMPLE SUMMARY JSON ======");
    debugPrint(sampleSummaryJson.toString());

    resetImageAttachments();

    Get.to(() => const InwardEntryConsolidatedPage());
  }

  Map<String, dynamic> buildMainFormJson() {
    final Map<String, dynamic> result = {};
    final List fields = schema["fields"];

    for (final f in fields) {
      final String name = f["fld_name"];
      final String type = f["fld_type"];

      // final String key = _toSnakeCase(name);
      final String key = name;

      dynamic value;

      if (type == "dd") {
        value = dropdownCtrls[name]?.value ?? "";
      } else {
        value = textCtrls[name]?.text.trim() ?? "";
      }

      result[key] = value;
    }

    return result;
  }

  List<Map<String, dynamic>> buildSampleGridJson() {
    final List<Map<String, dynamic>> rows = [];
    final List gridFields = schema["fillgrids"]["fields"];

    for (final row in sampleGridRows) {
      final Map<String, dynamic> obj = {};

      for (final f in gridFields) {
        final String name = f["fld_name"];
        final String key = name; // already snake_case in schema

        final ctrl = row[name];
        obj[key] = ctrl?.text.trim() ?? "";
      }

      rows.add(obj);
    }

    return rows;
  }

  Map<String, dynamic> buildSampleSummaryJson() {
    final Map<String, int> summary = {};
    final List gridFields = schema["fillgrids"]["fields"];

    // init all numeric fields to 0
    for (final f in gridFields) {
      if (f["data_type"] == "n") {
        final String name = f["fld_name"];
        summary[name] = 0;
      }
    }

    // sum them
    for (final row in sampleGridRows) {
      for (final f in gridFields) {
        if (f["data_type"] == "n") {
          final String name = f["fld_name"];
          final String v = row[name]?.text.trim() ?? "0";
          final int n = int.tryParse(v) ?? 0;

          summary[name] = (summary[name] ?? 0) + n;
        }
      }
    }

    return summary;
  }

////////////////////////////////////////////////////////////////////////
  void resetImageAttachments() {
    imageAttachmentJson.clear();

    for (final entry in sampleSummaryJson.entries) {
      final String key = entry.key;
      final int val = entry.value;

      if (val > 0 && key != "maf_date" && key != "maf_year") {
        imageAttachmentJson[key] = [];
      }
    }
  }

////////////////////////////////////////////////////////////////////////
  @override
  void onClose() {
    for (final c in textCtrls.values) {
      c.dispose();
    }
    _bagsToSampleDebounce?.cancel();
    super.onClose();
  }
}

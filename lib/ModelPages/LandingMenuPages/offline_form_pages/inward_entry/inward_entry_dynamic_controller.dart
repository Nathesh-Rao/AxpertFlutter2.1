import 'dart:async';
import 'dart:developer';
import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/db/offline_db_module.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/inward_entry_consolidated_page.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:axpertflutter/Constants/MyColors.dart';

class InwardEntryDynamicController extends GetxController {
  // ================== SCHEMA ==================
  Map<String, dynamic> schema = {};

  // ================== FIELD CONTROLLERS ==================
  final Map<String, TextEditingController> textCtrls = {};
  final Map<String, RxString> dropdownCtrls = {};
  final ScrollController scrollCtrl = ScrollController();
  final PageController pageController = PageController();
  Map<String, dynamic> mainFormJson = {};
  Map<String, dynamic> dc1SubmitFormJson = {};

  // List<Map<String, dynamic>> sampleGridJson = [];
  Map<String, dynamic> sampleSummaryJson = {};
  RxMap<String, List<String>> imageAttachmentJson =
      <String, List<String>>{}.obs;
  var filteredSummary = <String, dynamic>{}.obs;

  var imageErrors = <String, bool>{}.obs;
  TextEditingController getTextCtrl(String name) => textCtrls[name]!;
  RxString getDropdownCtrl(String name) => dropdownCtrls[name]!;

  // ================== UI STATE ==================
  final showMiniFab = false.obs;
  var isAtTop = true.obs;
  var currentCardIndex = 0.obs;
  final Map<String, List<Map<String, dynamic>>> datasourceMap = {};
  var samplePercentageDivValue = 5;
  // ================== SAMPLE GRID ==================
  final RxList<Map<String, TextEditingController>> sampleGridRows =
      <Map<String, TextEditingController>>[].obs;

  Timer? _bagsToSampleDebounce;

  // ================== ERRORS (for later UI) ==================
  final errors = <String, String>{}.obs;
  var isLoading = false.obs;
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
    // _buildControllersFromSchema();
    // _attachBusinessListeners();
    resetForm();
  }

  var isFormPreparing = false.obs;
  Future<void> prepareForm(Map<String, dynamic> newSchema) async {
    isFormPreparing.value = true;
    schema = newSchema;
    // 1. clear old stuff
    resetForm();
    // scrollCtrl.animateTo(
    //   0,
    //   duration: const Duration(milliseconds: 500),
    //   curve: Curves.easeInOut,
    // );
    // 2. destroy old controllers
    for (final c in textCtrls.values) {
      c.dispose();
    }
    textCtrls.clear();
    dropdownCtrls.clear();

    // 3. rebuild from schema
    _buildControllersFromSchema();

    // 4. load datasources
    await loadDatasources();

    // 5. attach business rules
    _attachBusinessListeners();

    // 6. scroll to top
    if (scrollCtrl.hasClients) {
      scrollCtrl.jumpTo(0);
    }

    isFormPreparing.value = false;
  }

  Future<void> loadDatasources() async {
    datasourceMap.clear();

    final List fields = schema["fields"];
    final Set<String> needed = {};

    for (final f in fields) {
      if (f["datasource"] != null && f["datasource"].toString().isNotEmpty) {
        needed.add(f["datasource"]);
      }
    }

    for (final ds in needed) {
      final list = await OfflineDbModule.getDatasourceOptions(
          transId: schema["transid"], datasource: ds);
      datasourceMap[ds] = List<Map<String, dynamic>>.from(list);
    }

    update();
  }

  // ================== BUILD CONTROLLERS FROM JSON ==================

  void _buildControllersFromSchema() {
    final List fields = schema["fields"];

    for (final f in fields) {
      final String name = f["fld_name"];
      final String rawType = f["fld_type"];
      final String defValue = f["def_value"]?.toString() ?? "";
      final bool isUpper = rawType.endsWith("_upper");
      final String type = isUpper ? rawType.replaceAll("_upper", "") : rawType;
      if (type == "dd") {
        dropdownCtrls[name] = "".obs;

        if (defValue.isNotEmpty) {
          List<String> validOptions = getDropdownOptions(name);

          if (validOptions.contains(defValue)) {
            dropdownCtrls[name]!.value = defValue;
          }
        }
      } else {
        final ctrl = TextEditingController(text: defValue);
        textCtrls[name] = ctrl;
        if (isUpper) {
          ctrl.addListener(() {
            final String text = ctrl.text;
            final String formatted = text.toUpperCase();

            if (text != formatted) {
              int cursorPosition = ctrl.selection.baseOffset;

              ctrl.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: cursorPosition),
              );
            }
          });
        }
      }
    }
  }

  void _attachBusinessListeners() {
    getTextCtrl("received_bags_crates").addListener(_onReceivedChanged);
    // ever(getTextCtrl("eceived_bags_crates"), (_){
    //   _onReceivedChanged();
    // });
    getTextCtrl("bags_sample").addListener(_recheckMiniFab);
    getTextCtrl("loaded_truck").addListener(_calculateNetWeight);
    getTextCtrl("empty_truck").addListener(_calculateNetWeight);
    // getDropdownCtrl("packing").listen((_) {
    //   _onReceivedChanged();
    // });

    ever(getDropdownCtrl("packing"), (_) {
      _onReceivedChanged();
    });
  }

  _calculateNetWeight() {
    final loadedWeight =
        int.tryParse(getTextCtrl("loaded_truck").text.trim()) ?? 0;
    final emptyWeight =
        int.tryParse(getTextCtrl("empty_truck").text.trim()) ?? 0;
    //  final netWeight = int.tryParse(getTextCtrl("netWeight").text.trim()) ?? 0;

    var netweight = loadedWeight - emptyWeight;

    getTextCtrl("netweight").text = netweight.toString();
  }

  // void _onReceivedChanged() {
  //   final received =
  //       int.tryParse(getTextCtrl("received_bags_crates").text.trim()) ?? 0;

  //   final String packingType = getDropdownCtrl("packing").value.toLowerCase();

  //   int percentage = 5;
  //   if (packingType.contains("crate")) {
  //     percentage = 2;
  //   }

  //   if (received < 20) {
  //     getTextCtrl("bags_sample").text = '';
  //     clearSampleGrid();
  //     _recheckMiniFab();
  //     return;
  //   }

  //   int sample = ((received * percentage) / 100).round();

  //   if (sample < 1) sample = 1;

  //   getTextCtrl("bags_sample").text = sample.toString();

  //   _generateSampleGrid(sample);
  //   _recheckMiniFab();
  // }

  void _onReceivedChanged() {
    final received =
        int.tryParse(getTextCtrl("received_bags_crates").text.trim()) ?? 0;

    final String packingType =
        getDropdownCtrl("packing").value.trim().toLowerCase();

    int percentage = 0;

    if (packingType.isNotEmpty) {
      if (packingType.contains("crate")) {
        percentage = 2;
      } else {
        percentage = 5;
      }
    }

    if (percentage == 0 || received < 20) {
      getTextCtrl("bags_sample").text = '';
      clearSampleGrid();
      _recheckMiniFab();
      return;
    }

    int sample = ((received * percentage) / 100).round();

    if (sample < 1) sample = 1;

    getTextCtrl("bags_sample").text = sample.toString();

    _generateSampleGrid(sample);
    _recheckMiniFab();
    onBagsToSampleChanged(sample.toString());

    debugPrint("_onReceivedChanged updated with value => $sample");
  }

  void onBagsToSampleChanged(String value) {
    _bagsToSampleDebounce?.cancel();

    _bagsToSampleDebounce = Timer(const Duration(milliseconds: 300), () {
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
    final received =
        int.tryParse(getTextCtrl("received_bags_crates").text.trim()) ?? 0;
    final sample = int.tryParse(getTextCtrl("bags_sample").text.trim()) ?? 0;

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

    final RxBool isGridView = (Get.width > 600).obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          height: Get.height * 0.9,
          width: Get.width > 1000 ? 1000 : Get.width,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Chip(
                      backgroundColor: const Color(0xFFEFF6FF),
                      label: Obx(() => Text(
                            isGridView.value
                                ? "Total Samples: ${sampleGridRows.length}"
                                : "Sample ${currentCardIndex.value + 1} of ${sampleGridRows.length}",
                            style: GoogleFonts.poppins(
                              color: MyColors.baseBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                    const Spacer(),
                    Obx(() => IconButton(
                          onPressed: () => isGridView.toggle(),
                          tooltip: isGridView.value
                              ? "Switch to Single View"
                              : "Switch to Grid View",
                          icon: Icon(
                            isGridView.value
                                ? Icons.view_carousel_rounded // Icon for Pager
                                : Icons.grid_view_rounded, // Icon for Grid
                            color: MyColors.baseBlue,
                          ),
                        )),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Chip(
                        backgroundColor: const Color(0xFFFEF2F2),
                        label: Text(
                          "Close",
                          style: GoogleFonts.poppins(
                            color: MyColors.baseRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (isGridView.value) {
                    return _buildTabletGridView();
                  } else {
                    return _buildMobilePagerView();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletGridView() {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      // gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(

      //   maxCrossAxisExtent: 400,
      //   mainAxisExtent: 500,
      //   crossAxisSpacing: 12,
      //   mainAxisSpacing: 12,
      // ),
      //
      // gridampleGridRows.length,
      itemCount: sampleGridRows.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.45,
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        final row = sampleGridRows[index];
        return _buildSampleFormPage(row, index + 1);
      },
    );
  }

  Widget _buildMobilePagerView() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (i) => currentCardIndex.value = i,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                Opacity(
                  opacity: currentCardIndex.value > 0 ? 1 : 0,
                  child: FloatingActionButton.small(
                    heroTag: "btn_prev",
                    backgroundColor: Colors.white,
                    onPressed: currentCardIndex.value > 0
                        ? () {
                            pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        : null,
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),

                // Next Button
                Opacity(
                  opacity: currentCardIndex.value < sampleGridRows.length - 1
                      ? 1
                      : 0,
                  child: FloatingActionButton.small(
                    heroTag: "btn_next",
                    backgroundColor: MyColors.baseBlue,
                    onPressed:
                        currentCardIndex.value < sampleGridRows.length - 1
                            ? () {
                                pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut);
                              }
                            : null,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSampleFormPage(
      Map<String, TextEditingController> model, int sno) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
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
                  const Icon(Icons.edit_note, size: 18, color: Colors.grey),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                primary: false,
                children: [
                  ...model.entries.map((e) {
                    return _compactField(e.key, e.value, model);
                  }).toList(),
                ],
              ),
            ),
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

  void next() {
    final ok = validateForm();

    if (!ok) {
      Get.snackbar(
        "Validation Error",
        "Please fix the highlighted fields",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    dc1SubmitFormJson = buildDc1SubmitFormJson();
    // mainFormJson = buildMainFormJson();
    // sampleGridJson = buildSampleGridJson();
    sampleSummaryJson = buildSampleSummaryJson();

    debugPrint("====== MAIN FORM JSON ======");
    debugPrint(mainFormJson.toString());

    // debugPrint("====== SAMPLE GRID JSON ======");
    // debugPrint(sampleGridJson.toString());

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
        final String ds = f["datasource"];
        // 1. Get the list safely
        var dsList = datasourceMap[ds] ?? [];

        // 2. Get the ID we are looking for
        final selectedId = dropdownCtrls[name]?.value ?? "";

        // 3. Find the item safely (handle Type mismatch and Missing item)
        final selectedItem = dsList.firstWhere(
          (item) => item["id"].toString() == selectedId.toString(),
          orElse: () => {}, // Prevents crash if not found
        );

        // 4. Extract just the text value (or fallback to empty)
        value = selectedItem[
            "value"]; // <--- Make sure you extract the specific key!
      } else {
        value = textCtrls[name]?.text.trim() ?? "";
      }

      result[key] = value;
    }

    return result;
  }

  Map<String, dynamic> buildDc1SubmitFormJson() {
    final Map<String, dynamic> result = {};
    final List fields = schema["fields"];

    for (final f in fields) {
      final String name = f["fld_name"];
      final String type = f["fld_type"];

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

  // List<Map<String, dynamic>> buildSampleGridJson() {
  //   final List<Map<String, dynamic>> rows = [];
  //   final List gridFields = schema["fillgrids"]["fields"];

  //   for (final row in sampleGridRows) {
  //     final Map<String, dynamic> obj = {};

  //     for (final f in gridFields) {
  //       final String name = f["fld_name"];
  //       final String key = name;
  //       final ctrl = row[name];
  //       obj[key] = ctrl?.text.trim() ?? "";
  //     }

  //     rows.add(obj);
  //   }

  //   return rows;
  // }

  List<Map<String, dynamic>> getOptionsForField(String fieldName) {
    final List fields = schema["fields"];

    final field = fields.firstWhere((e) => e["fld_name"] == fieldName);

    final String? ds = field["datasource"];

    if (ds == null) return [];

    return datasourceMap[ds] ?? [];
  }

  List<String> getDropdownOptions(String fieldName) {
    if (!isFieldEnabled(fieldName)) return [];

    final fieldDef = (schema['fields'] as List).firstWhere(
      (e) => e['fld_name'] == fieldName,
      orElse: () => null,
    );
    if (fieldDef == null) return [];

    final String? dsName = fieldDef['datasource'];
    if (dsName == null || !datasourceMap.containsKey(dsName)) return [];

    List<Map<String, dynamic>> filteredList = datasourceMap[dsName]!;

    final List deps = fieldDef['dep_field'] ?? [];
    if (deps.isNotEmpty) {
      filteredList = filteredList.where((row) {
        for (final parentKey in deps) {
          final parentSelected = dropdownCtrls[parentKey]?.value ?? "";

          // Data Match Logic
          String rowVal = row[parentKey]?.toString() ?? "";
          if (rowVal.endsWith(".0")) rowVal = rowVal.replaceAll(".0", "");

          String parentVal = parentSelected;
          if (parentVal.endsWith(".0"))
            parentVal = parentVal.replaceAll(".0", "");

          if (rowVal.toLowerCase() != parentVal.toLowerCase()) return false;
        }
        return true;
      }).toList();
    }

    final Set<String> uniqueValues = {};
    for (final row in filteredList) {
      final val = row[fieldName]?.toString();
      if (val != null && val.isNotEmpty) uniqueValues.add(val);
    }

    return uniqueValues.toList()..sort();
  }

  bool isFieldEnabled(String fieldName) {
    final fieldDef = (schema['fields'] as List).firstWhere(
      (e) => e['fld_name'] == fieldName,
      orElse: () => null,
    );

    if (fieldDef == null) return true;

    final List deps = fieldDef['dep_field'] ?? [];

    if (deps.isEmpty) return true;

    for (final parentKey in deps) {
      final parentValue = dropdownCtrls[parentKey]?.value ?? "";
      if (parentValue.isEmpty) {
        return false;
      }
    }

    return true;
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

  submit() {
    if (validateImages()) {
      submitPage();
    } else {
      Get.snackbar("Missing Images",
          "Please add at least one image for the highlighted items.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16));
    }
  }

  void calculateFilteredSummary() {
    filteredSummary.clear();
    imageErrors.clear();

    var result = Map<String, dynamic>.fromEntries(
      sampleSummaryJson.entries.where((e) {
        if (e.key == "maf_date" || e.key == "maf_year" || e.key == "short") {
          return false;
        }
        final num v = num.tryParse(e.value.toString()) ?? 0;
        return v > 0;
      }),
    );

    filteredSummary.value = result;

    for (var key in result.keys) {
      if (!imageAttachmentJson.containsKey(key)) {
        imageAttachmentJson[key] = [];
      }
    }

    update(["sample_list"]);
  }

  bool validateImages({bool isPartial = false}) {
    if (isPartial) {
      bool hasActiveErrors = imageErrors.containsValue(true);

      if (!hasActiveErrors) return true;
    }

    bool isValid = true;
    imageErrors.clear();

    filteredSummary.forEach((key, value) {
      List? images = imageAttachmentJson[key];

      if (images == null || images.isEmpty) {
        imageErrors[key] = true;
        isValid = false;
      } else {
        imageErrors[key] = false;
      }
    });

    imageErrors.refresh();
    return isValid;
  }

  Map<String, dynamic> generateSubmitPayload() {
    // ----------------- 1. DC1 (Header Data) -----------------
    final Map<String, dynamic> dc1Data = {};
    final List fields = schema["fields"];

    for (final f in fields) {
      final String name = f["fld_name"];
      final String type = f["fld_type"];

      dynamic value;

      if (type == "dd") {
        value = dropdownCtrls[name]?.value ?? "";
      } else {
        value = textCtrls[name]?.text.trim() ?? "";
      }

      dc1Data[name] = value;
    }

    // ----------------- 2. DC2 (Grid Data) -----------------
    final Map<String, dynamic> dc2Data = {};
    final List gridFields = schema["fillgrids"]["fields"];

    int rowIndex = 1;
    for (final row in sampleGridRows) {
      final Map<String, dynamic> rowData = {};

      for (final f in gridFields) {
        final String name = f["fld_name"];
        final ctrl = row[name];
        rowData[name] = ctrl?.text.trim() ?? "";
      }

      rowData["fillrows"] = rowIndex.toString();

      dc2Data["row$rowIndex"] = rowData;
      rowIndex++;
    }

    final Map<String, int> summary = {};

    // Init summary keys
    for (final f in gridFields) {
      if (f["data_type"] == "n") {
        summary[f["fld_name"]] = 0;
      }
    }

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

    final Map<String, dynamic> dc3Data = {
      "row1": {
        "tot_broken": summary["broken"]?.toString() ?? "0",
        "tot_neckchip": summary["neck_chip"]?.toString() ?? "0",
        "tot_extradirty": summary["extra_dirty"]?.toString() ?? "0",
        "tot_short": summary["short"]?.toString() ?? "0",
        "tot_otherbrand": summary["other_brand"]?.toString() ?? "0",
        "tot_otherkf": summary["other_kf"]?.toString() ?? "0",
        "tot_tornbags": summary["torn_bags"]?.toString() ?? "0",
      }
    };

    String sessionId = AppStorage().retrieveValue(AppStorage.SESSIONID) ?? "";
    final String username = AppStorage().retrieveValue(AppStorage.USER_NAME);
    var project = globalVariableController.PROJECT_NAME.value;
    return {
      "ARMSessionId": sessionId,
      "publickey": "InwardEntry",
      "project": project,
      "submitdata": {
        "username": username,
        "trace": "false",
        "keyfield": "",
        "dataarray": {
          "data": {
            "mode": "new",
            "keyvalue": "",
            "recordid": "0",
            "dc1": {"row1": dc1Data},
            "dc2": dc2Data,
            "dc3": dc3Data
          }
        }
      }
    };
  }

  // Future<void> submitPage() async {
  //   if (!validateForm()) {
  //     Get.snackbar("Required", "Please fill mandatory fields");
  //     return;
  //   }

  //   try {
  //     isLoading.value = true;

  //     final isOnline = await Get.find<InternetConnectivity>().check();
  //     final Map<String, dynamic> mainBody = generateSubmitPayload();

  //     final SubmitStatus status = await OfflineDbModule.submitFormSmart(
  //       submitBody: mainBody,
  //       isInternetAvailable: isOnline,
  //     );

  //     switch (status) {
  //       case SubmitStatus.success:
  //         resetForm();
  //         Get.back();

  //         Get.snackbar(
  //           "Success",
  //           "Form submitted successfully!",
  //           backgroundColor: Colors.green,
  //           colorText: Colors.white,
  //           duration: const Duration(seconds: 3),
  //         );
  //         break;

  //       case SubmitStatus.savedOffline:
  //         resetForm();
  //         Get.back();

  //         Get.snackbar(
  //           "Saved Offline",
  //           "No Internet. Form saved to pending queue.",
  //           backgroundColor: Colors.blueAccent,
  //           colorText: Colors.white,
  //           duration: const Duration(seconds: 3),
  //         );
  //         break;

  //       case SubmitStatus.apiFailure:
  //         // SHOW THE ERROR! Do not close the form.
  //         // Let user correct data or try again.
  //         Get.snackbar(
  //           "Submission Failed",
  //           "Server rejected the request. Please check your data.",
  //           backgroundColor: Colors.redAccent,
  //           colorText: Colors.white,
  //           duration: const Duration(seconds: 4),
  //         );
  //         break;
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Unexpected error: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> submitPage() async {
  //   if (!validateForm()) {
  //     Get.snackbar("Required", "Please fill mandatory fields");
  //     return;
  //   }

  //   try {
  //     isLoading.value = true;
  //     final isOnline = await Get.find<InternetConnectivity>().check();

  //     final Map<String, dynamic> mainBody = generateSubmitPayload();

  //     final SubmitStatus mainStatus = await OfflineDbModule.submitFormSmart(
  //       submitBody: mainBody,
  //       isInternetAvailable: isOnline,
  //     );

  //     if (mainStatus == SubmitStatus.apiFailure) {
  //       Get.snackbar(
  //         "Submission Failed",
  //         "Server rejected the main form. Please check your data.",
  //         backgroundColor: Colors.redAccent,
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 4),
  //       );
  //       return;
  //     }

  //     // ignore: unused_local_variable
  //     int imagesUploaded = 0;
  //     // ignore: unused_local_variable
  //     int imagesQueued = 0;
  //     int imagesFailed = 0;

  //     final List<Map<String, dynamic>> attachmentPayloads =
  //         generateAttachmentPayloads();

  //     if (attachmentPayloads.isNotEmpty) {
  //       for (final attachBody in attachmentPayloads) {
  //         final SubmitStatus imgStatus = await OfflineDbModule.submitFormSmart(
  //           submitBody: attachBody,
  //           isInternetAvailable: isOnline,
  //         );

  //         if (imgStatus == SubmitStatus.success)
  //           imagesUploaded++;
  //         else if (imgStatus == SubmitStatus.savedOffline)
  //           imagesQueued++;
  //         else
  //           imagesFailed++;
  //       }
  //     }

  //     resetForm();
  //     prepareForm(schema);
  //     Get.back();
  //     isLoading.value = false;

  //     if (mainStatus == SubmitStatus.savedOffline) {
  //       Get.snackbar(
  //         "Saved Offline",
  //         "No Internet. Main form + ${attachmentPayloads.length} attachments saved to queue.",
  //         backgroundColor: Colors.blueAccent,
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 4),
  //       );
  //     } else if (imagesFailed == 0) {
  //       Get.snackbar(
  //         "Success",
  //         "Form and all attachments submitted successfully!",
  //         backgroundColor: Colors.green,
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 3),
  //       );
  //     } else {
  //       Get.snackbar(
  //         "Partial Success",
  //         "Main form submitted, but $imagesFailed images failed to upload.",
  //         backgroundColor: Colors.orangeAccent,
  //         colorText: Colors.black,
  //         duration: const Duration(seconds: 5),
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error", "Unexpected error: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Add this variable to your controller
  var submitStatus = "".obs;
  Future<void> submitPage() async {
    if (!validateForm()) {
      Get.snackbar("Required", "Please fill mandatory fields");
      return;
    }

    try {
      isLoading.value = true;
      submitStatus.value = "Checking internet connection...";

      final isOnline = await Get.find<InternetConnectivity>().check();
      var forceOffline = schema["force_offline"];
      submitStatus.value = "Generating form data...";
      final Map<String, dynamic> mainBody = generateSubmitPayload();
      log(mainBody.toString(), name: "MAIN_BODY");
      submitStatus.value = "Submitting Master Form...";

      final SubmitStatus mainStatus = await OfflineDbModule.submitFormSmart(
        submitBody: mainBody,
        isInternetAvailable: isOnline,
        forceOffline: forceOffline,
      );

      if (mainStatus == SubmitStatus.apiFailure) {
        isLoading.value = false;
        submitStatus.value = "";
        Get.snackbar(
          "Submission Failed",
          "Server rejected the main form. Please check your data.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      submitStatus.value = "Preparing images for upload...";

      final List<Map<String, dynamic>> attachmentPayloads =
          generateAttachmentPayloads();

      int imagesUploaded = 0;
      int imagesQueued = 0;
      int imagesFailed = 0;
      int totalImages = attachmentPayloads.length;

      if (totalImages > 0) {
        for (int i = 0; i < totalImages; i++) {
          submitStatus.value = "Uploading image ${i + 1} of $totalImages...";

          final attachBody = attachmentPayloads[i];

          final SubmitStatus imgStatus = await OfflineDbModule.submitFormSmart(
            submitBody: attachBody,
            isInternetAvailable: isOnline,
            forceOffline: forceOffline,
          );

          if (imgStatus == SubmitStatus.success)
            imagesUploaded++;
          else if (imgStatus == SubmitStatus.savedOffline)
            imagesQueued++;
          else
            imagesFailed++;
        }
      }

      submitStatus.value = "Finalizing...";
      await Future.delayed(Duration(milliseconds: 500));
// todo Form widget
      resetForm();
      isLoading.value = false;
      prepareForm(schema);
      submitStatus.value = "";
      Get.back();

      if (mainStatus == SubmitStatus.savedOffline) {
        Get.snackbar(
          "Saved Offline",
          "No Internet. Main form + $totalImages attachments saved to queue.",
          backgroundColor: Colors.blueAccent,
          colorText: Colors.white,
        );
      } else if (imagesFailed == 0) {
        Get.snackbar(
          "Success",
          "Form and all attachments submitted successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Partial Success",
          "Main form submitted, but $imagesFailed images failed.",
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      isLoading.value = false;
      submitStatus.value = "";
      print("SUBMIT ERROR: $e");
      Get.snackbar("Error", "Unexpected error: $e");
    }
  }

  List<Map<String, dynamic>> generateAttachmentPayloads() {
    final List<Map<String, dynamic>> payloads = [];

    final String refNo = textCtrls["ub_ge_no"]?.text.trim() ?? "UNKNOWN_REF";
    final String sessionId = AppStorage().retrieveValue(AppStorage.SESSIONID);
    final String username = AppStorage().retrieveValue(AppStorage.USER_NAME);
    imageAttachmentJson.forEach((categoryKey, base64List) {
      if (base64List.isEmpty) return;

      final Map<String, dynamic> fileMap = {};
      for (int i = 0; i < base64List.length; i++) {
        fileMap["file${i + 1}"] = {
          "filename": "${refNo}_${categoryKey}_${i + 1}.jpg",
          "fileasbase64": base64List[i]
        };
      }
      var project = globalVariableController.PROJECT_NAME.value;
      final Map<String, dynamic> payload = {
        "ARMSessionId": sessionId,
        "publickey": "InwardAttach",
        "project": project,
        "submitdata": {
          "username": username,
          "trace": "false",
          "keyfield": "",
          "dataarray": {
            "data": {
              "mode": "new",
              "keyvalue": "",
              "recordid": "0",
              "dc1": {
                "row1": {
                  "ub_gen_no": refNo,
                  "category": categoryKey,
                  "axpfile_file": fileMap,
                  "axpfilepath_file": ""
                }
              }
            }
          }
        }
      };

      payloads.add(payload);
    });

    return payloads;
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

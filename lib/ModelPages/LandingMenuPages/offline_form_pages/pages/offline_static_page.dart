import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_static_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineStaticFormPageV2Compact
    extends GetView<OfflineStaticFormController> {
  const OfflineStaticFormPageV2Compact({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollCtrl = ScrollController();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetForm();
      _scrollCtrl.addListener(() {
        if (!_scrollCtrl.hasClients) return;

        final max = _scrollCtrl.position.maxScrollExtent;
        final offset = _scrollCtrl.offset;

        // consider near bottom if within 80px
        if (offset > max - 80) {
          controller.isAtTop.value = false;
        } else if (offset < 80) {
          controller.isAtTop.value = true;
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: const Color(0xFFF5F7FB),
        title: Text(
          'Inward Entry',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                controller.resetForm();
              },
              icon: Icon(
                Icons.history,
                color: MyColors.baseYellow,
              ))
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: "Basic Info",
            children: [
              _text("UB G.E No", controller.ubGeNoCtrl, "ubGeNo",
                  mandatory: true),
              _dropdown("Unit", controller.unit, "unit", mandatory: true),
              _date(context, "Receipt Date", controller.receiptDateCtrl,
                  "receiptDate",
                  mandatory: true),
              _text("Vehicle No", controller.vehicleNoCtrl, "vehicleNo",
                  mandatory: true),
            ],
          ),
          _Section(
            title: "Supplier",
            children: [
              _dropdown("S1 Name", controller.s1Name, "s1Name",
                  mandatory: true),
              _text("S1 DC", controller.s1DcCtrl, "s1Dc", mandatory: true),
              _dropdown("S2 District", controller.s2District, "s2District"),
              _text("S2 Name", controller.s2NameCtrl, "s2Name"),
            ],
          ),
          _Section(
            title: "Bottle Details",
            children: [
              _dropdown("Bottle Type", controller.bottleType, "bottleType",
                  mandatory: true),
              _dropdown("Bottle Capacity", controller.bottleCapacity,
                  "bottleCapacity",
                  mandatory: true),
              _dropdown("Bottle Per Bag / Crate", controller.bottlePerCrate,
                  "bottlePerCrate",
                  mandatory: true),
              _date(context, "Manufacturing Date of Bottle",
                  controller.manufacturingDateCtrl, "manufacturingDate"),
            ],
          ),
          _Section(
            title: "Weight",
            children: [
              _number("Loaded Truck Weight", controller.loadedWeightCtrl,
                  "loadedWeight",
                  mandatory: true),
              _number("Empty Truck Weight", controller.emptyWeightCtrl,
                  "emptyWeight",
                  mandatory: true),
              _number("Net Weight", controller.netWeightCtrl, "netWeight",
                  mandatory: true),
            ],
          ),
          _Section(
            title: "Quantity",
            children: [
              _number("Received Bags / Crates", controller.receivedBagsCtrl,
                  "receivedBags",
                  mandatory: true),
              _number(
                  "Bags To Sample", controller.bagsToSampleCtrl, "bagsToSample",
                  mandatory: true),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
      // floatingActionButton: Obx(() {
      //   if (!controller.showMiniFab.value) return const SizedBox.shrink();

      //   return FloatingActionButton(
      //     backgroundColor: MyColors.blue10,
      //     onPressed: () {
      //       // you decide what this does
      //       // Get.dialog(const SampleDetailsDialog());
      //       controller.openSampleDetailsDialog();
      //     },
      //     child: const Icon(Icons.table_rows_outlined),
      //   );
      // }),

      floatingActionButton: Row(
        children: [
          SizedBox(
            width: 40,
          ),

          Obx(() {
            return FloatingActionButton(
              heroTag: "scrollFab",
              backgroundColor: Colors.white,
              // elevation: 3,
              onPressed: () {
                if (!_scrollCtrl.hasClients) return;

                if (controller.isAtTop.value) {
                  _scrollCtrl.animateTo(
                    _scrollCtrl.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  _scrollCtrl.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Icon(
                controller.isAtTop.value
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_up,
                color: MyColors.baseBlue,
              ),
            );
          }),
          Spacer(),
          // ---------- RIGHT SAMPLE FAB ----------
          Obx(() {
            if (!controller.showMiniFab.value) return const SizedBox.shrink();

            return FloatingActionButton(
              heroTag: "sampleFab",
              backgroundColor: MyColors.blue10,
              onPressed: () {
                controller.openSampleDetailsDialog();
              },
              child: const Icon(Icons.table_rows_outlined),
            );
          }),
        ],
      ),

      // floatingActionButton: Stack(
      //   children: [
      //     // ---------- LEFT SCROLL TOGGLE FAB ----------
      //     Positioned(
      //       left: 26,
      //       bottom: 16,
      //       child: Obx(() {
      //         return FloatingActionButton(
      //           heroTag: "scrollFab",
      //           backgroundColor: Colors.white,
      //           // elevation: 3,
      //           onPressed: () {
      //             if (!_scrollCtrl.hasClients) return;

      //             if (controller.isAtTop.value) {
      //               _scrollCtrl.animateTo(
      //                 _scrollCtrl.position.maxScrollExtent,
      //                 duration: const Duration(milliseconds: 500),
      //                 curve: Curves.easeInOut,
      //               );
      //             } else {
      //               _scrollCtrl.animateTo(
      //                 0,
      //                 duration: const Duration(milliseconds: 500),
      //                 curve: Curves.easeInOut,
      //               );
      //             }
      //           },
      //           child: Icon(
      //             controller.isAtTop.value
      //                 ? Icons.keyboard_arrow_down
      //                 : Icons.keyboard_arrow_up,
      //             color: MyColors.baseBlue,
      //           ),
      //         );
      //       }),
      //     ),

      //     // ---------- RIGHT SAMPLE FAB ----------
      //     Positioned(
      //       right: 16,
      //       bottom: 16,
      //       child: Obx(() {
      //         if (!controller.showMiniFab.value) return const SizedBox.shrink();

      //         return FloatingActionButton(
      //           heroTag: "sampleFab",
      //           backgroundColor: MyColors.blue10,
      //           onPressed: () {
      //             controller.openSampleDetailsDialog();
      //           },
      //           child: const Icon(Icons.table_rows_outlined),
      //         );
      //       }),
      //     ),
      //   ],
      // ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              controller.validate();
            },
            child: const Text("Submit"),
          ),
        ),
      ),
    );
  }

  // ================= FIELD TYPES =================

  Widget _text(String label, TextEditingController ctrl, String key,
      {bool mandatory = false}) {
    return _RowWithField(
      label: label,
      mandatory: mandatory,
      errorKey: key,
      child: Obx(() {
        final hasError = controller.errors.containsKey(key);
        return TextFormField(
          controller: ctrl,
          decoration: _inputDecoration(label, hasError),
        );
      }),
    );
  }

  Widget _number(String label, TextEditingController ctrl, String key,
      {bool mandatory = false}) {
    return _RowWithField(
      label: label,
      mandatory: mandatory,
      errorKey: key,
      child: Obx(() {
        final hasError = controller.errors.containsKey(key);
        return TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(label, hasError),
          onChanged: (v) {
            if (key == "bagsToSample") {
              controller.onBagsToSampleChanged(v);
            }
          },
        );
      }),
    );
  }

  Widget _dropdown(String label, RxString value, String key,
      {bool mandatory = false}) {
    return _RowWithField(
      label: label,
      mandatory: mandatory,
      errorKey: key,
      trailing: const Icon(Icons.expand_more, size: 18, color: Colors.grey),
      child: Obx(() {
        final hasError = controller.errors.containsKey(key);
        return DropdownButtonFormField<String>(
          initialValue: value.value.isEmpty ? null : value.value,
          items: const [
            DropdownMenuItem(value: "1", child: Text("Option 1")),
            DropdownMenuItem(value: "2", child: Text("Option 2")),
          ],
          onChanged: (v) => value.value = v ?? '',
          decoration: _inputDecoration(label, hasError),
        );
      }),
    );
  }

  Widget _date(BuildContext context, String label, TextEditingController ctrl,
      String key,
      {bool mandatory = false}) {
    return _RowWithField(
      label: label,
      mandatory: mandatory,
      errorKey: key,
      trailing: const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
      child: Obx(() {
        final hasError = controller.errors.containsKey(key);
        return TextFormField(
          controller: ctrl,
          readOnly: true,
          decoration: _inputDecoration(label, hasError),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (d != null) {
              ctrl.text =
                  "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
            }
          },
        );
      }),
    );
  }

  static InputDecoration _inputDecoration(String label, bool hasError) {
    return InputDecoration(
      hintText: "Enter $label",
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey.shade500,
      ),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.transparent,
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.transparent,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFF2563EB),
          width: 1.2,
        ),
      ),
    );
  }
}

// ================= ROW WITH FIELD =================

class _RowWithField extends GetView<OfflineStaticFormController> {
  final String label;
  final bool mandatory;
  final Widget child;
  final Widget? trailing;
  final String errorKey;

  const _RowWithField({
    required this.label,
    required this.child,
    required this.errorKey,
    this.mandatory = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEF1F6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (mandatory)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
          Obx(() {
            final err = controller.errors[errorKey];
            if (err == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                err,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.red,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
// ================= SECTION =================

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

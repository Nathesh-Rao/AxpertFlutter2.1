import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/inward_entry_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'inward_entry_dynamic_controller.dart';
import 'inward_entry_schema.dart';

class InwardEntryDynamicPageV1 extends GetView<InwardEntryDynamicController> {
  const InwardEntryDynamicPageV1({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    final Map<String, dynamic> schema = InwardEntrySchema.schema;
    final List fields = List.from(schema["fields"]);

    // sort by order
    fields.sort((a, b) => int.parse(a["order"].toString())
        .compareTo(int.parse(b["order"].toString())));

    // group by section
    final Map<String, List<Map<String, dynamic>>> sections = {};
    for (final f in fields) {
      final String section = f["fld_category"] ?? "General";
      sections.putIfAbsent(section, () => []);
      sections[section]!.add(Map<String, dynamic>.from(f));
    }

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
            onPressed: () => controller.resetForm(),
            icon: Icon(Icons.history, color: MyColors.baseYellow),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        controller: controller.scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          ...sections.entries.map((entry) {
            final sectionTitle = entry.key;
            final sectionFields = entry.value;

            return _Section(
              title: sectionTitle,
              children: sectionFields.map((f) {
                return _buildFieldFromSchema(context, f);
              }).toList(),
            );
          }).toList(),
          const SizedBox(height: 50),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

        return Row(
          children: [
            keyboardOpen ? Spacer() : const SizedBox(width: 40),
            Obx(() {
              return FloatingActionButton(
                heroTag: "scrollFab",
                backgroundColor: Colors.white,
                onPressed: () {
                  if (!controller.scrollCtrl.hasClients) return;

                  if (controller.isAtTop.value) {
                    controller.scrollCtrl.animateTo(
                      controller.scrollCtrl.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    controller.scrollCtrl.animateTo(
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
            !keyboardOpen ? Spacer() : const SizedBox(width: 40),
            Obx(() {
              if (!controller.showMiniFab.value) return const SizedBox.shrink();
              return FloatingActionButton(
                heroTag: "sampleFab",
                backgroundColor: MyColors.blue10,
                onPressed: () => controller.openSampleDetailsDialog(),
                child: const Icon(Icons.table_rows_outlined),
              );
            }),
          ],
        );
      }),
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
              controller.submit();
            },
            child: const Text("Next"),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldFromSchema(BuildContext context, Map<String, dynamic> f) {
    final String type = f["fld_type"];
    final String name = f["fld_name"];
    final String label = f["fld_caption"];
    final bool mandatory = (f["allowempty"] == "F");

    switch (type) {
      case "c":
        return _text(
          label,
          controller.getTextCtrl(name),
          name,
          mandatory: mandatory,
        );
      case "n":
        return _number(
          label,
          controller.getTextCtrl(name),
          name,
          mandatory: mandatory,
        );
      case "dd":
        final String dsKey = f["datasource"];
        return _dropdown(
          label,
          controller.getDropdownCtrl(name),
          name,
          dsKey,
          mandatory: mandatory,
        );

      case "date":
        return _date(
          context,
          label,
          controller.getTextCtrl(name),
          name,
          mandatory: mandatory,
        );
      case "year":
        return _yearPicker(
          context,
          label,
          controller.getTextCtrl(name),
          name,
          mandatory: mandatory,
        );
      default:
        return const SizedBox.shrink();
    }
  }

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

  Widget _dropdown(
    String label,
    RxString value,
    String key,
    String datasourceKey, {
    bool mandatory = false,
  }) {
    return _RowWithField(
      label: label,
      mandatory: mandatory,
      errorKey: key,
      trailing: const Icon(Icons.expand_more, size: 18, color: Colors.grey),
      child: Obx(() {
        final hasError = controller.errors.containsKey(key);

        final List<String> options =
            InwardEntryDatasource.options[datasourceKey] ?? [];

        return DropdownButtonFormField<String>(
          initialValue: value.value.isEmpty ? null : value.value,
          items: options
              .map(
                (opt) => DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt),
                ),
              )
              .toList(),
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

  Widget _yearPicker(BuildContext context, String label,
      TextEditingController ctrl, String key,
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
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(now.year + 1),
              initialDate: now,
              initialDatePickerMode: DatePickerMode.year,
            );
            if (d != null) {
              ctrl.text = d.year.toString();
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

class _RowWithField extends GetView<InwardEntryDynamicController> {
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

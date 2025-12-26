import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_field_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/offline_attachment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class OfflineFormController extends GetxController {
  late OfflineFormPageModel page;

  final Map<String, OfflineFormFieldModel> fieldMap = {};

  var isLoading = false.obs;

  RxList<OfflineFormPageModel> allPages = <OfflineFormPageModel>[].obs;
  RxList<OfflineAttachmentModel> attachments = <OfflineAttachmentModel>[].obs;

  final ImagePicker _imagePicker = ImagePicker();

  // ---------------- LOAD ALL PAGES ----------------

  void getAllPages() {
    allPages.value = OfflineFormPageModel.tempdata
        .map((e) => OfflineFormPageModel.fromJson(e))
        .where((p) => p.visible)
        .toList();
  }

  // ---------------- LOAD PAGE ----------------

  void loadPage(OfflineFormPageModel pageModel) {
    page = pageModel;
    fieldMap.clear();
    attachments.clear();

    final sortedFields = [...page.fields]
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final field in sortedFields) {
      field.value = field.defValue;
      field.errorText = null;
      fieldMap[field.fldName] = field;
    }

    Get.toNamed(Routes.OfflineFormPage);
  }

  void updateFieldValue(OfflineFormFieldModel field, dynamic newValue) {
    switch (field.fldType) {
      case 'cb':
        field.value =
            (newValue == true || newValue.toString().toLowerCase() == 'true')
                .toString();
        break;

      case 'cl':
        if (newValue is List<String>) {
          field.value = newValue.join(',');
        }
        break;

      case 'rb':
      case 'rl':
      case 'dd':
      case 'c':
      case 'n':
      case 'm':
      case 'd':
        field.value = newValue.toString();
        break;
      case 'image':
        field.value = newValue.toString();
        break;

      default:
        field.value = newValue.toString();
        break;
    }

    field.errorText = null;
    fieldMap[field.fldName] = field;
    update([field.fldName]);
  }

  bool validateForm() {
    bool isFormValid = true;

    for (final field in fieldMap.values) {
      final value = field.value.trim();
      bool isValid = true;

      /// allowempty = T means NOT mandatory
      if (field.allowEmpty) {
        field.errorText = null;
        continue;
      }

      switch (field.fldType) {
        case 'cb':
          isValid = value.toLowerCase() == 'true';
          break;

        case 'cl':
          isValid =
              value.split(',').where((e) => e.trim().isNotEmpty).isNotEmpty;
          break;

        default:
          isValid = value.isNotEmpty;
          break;
      }

      if (!isValid) {
        isFormValid = false;
        field.errorText = '${field.fldCaption} is required';
      } else {
        field.errorText = null;
      }

      fieldMap[field.fldName] = field;
      update([field.fldName]);
    }

    return isFormValid;
  }

  void resetForm() {
    for (final field in fieldMap.values) {
      field.value = field.defValue;
      field.errorText = null;
      fieldMap[field.fldName] = field;
      update([field.fldName]);
    }
  }

  // ---------------- COLLECT DATA ----------------

  Map<String, dynamic> collectFormData() {
    final Map<String, dynamic> data = {};

    for (final field in fieldMap.values) {
      data[field.fldName] = field.value;
    }

    return data;
  }

  // ---------------- HELPERS ----------------

  OfflineFormFieldModel? getField(String fldName) {
    return fieldMap[fldName];
  }

  String getFieldValue(String fldName) {
    return fieldMap[fldName]?.value ?? '';
  }

  bool isFieldFilled(String fldName) {
    final v = fieldMap[fldName]?.value.trim() ?? '';
    return v.isNotEmpty;
  }

  Future<void> pickImage({
    required OfflineFormFieldModel field,
    required ImageSource source,
  }) async {
    if (field.readOnly) return;

    final XFile? file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (file == null) {
      _showImageNotSelectedMsg();
      return;
    }

    final bytes = await File(file.path).readAsBytes();
    final base64 = base64Encode(bytes);

    updateFieldValue(field, base64);
  }

  void removeImage(OfflineFormFieldModel field) {
    if (field.readOnly) return;
    updateFieldValue(field, '');
  }

  void _showImageNotSelectedMsg() {
    Get.snackbar(
      'Image not selected',
      'Please select an image to continue',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) {
      Get.snackbar(
        'No file selected',
        'Please select a file to attach',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    for (final f in result.files) {
      if (f.path == null) continue;

      attachments.add(
        OfflineAttachmentModel(
          name: f.name,
          path: f.path!,
          extension: f.extension ?? '',
        ),
      );
    }
  }

  void removeAttachment(OfflineAttachmentModel file) {
    attachments.remove(file);
  }

  IconData getAttachmentIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'mp4':
      case 'mov':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color getAttachmentColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Colors.redAccent;

      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blueAccent;

      case 'doc':
      case 'docx':
        return Colors.indigo;

      case 'xls':
      case 'xlsx':
        return Colors.green;

      case 'mp4':
      case 'mov':
        return Colors.deepPurple;

      default:
        return Colors.grey;
    }
  }

  String getAttachmentTypeSummary() {
    if (attachments.isEmpty) return '';

    int images = 0;
    int docs = 0;
    int videos = 0;
    int others = 0;

    for (final file in attachments) {
      final ext = file.extension.toLowerCase();

      if (['jpg', 'jpeg', 'png'].contains(ext)) {
        images++;
      } else if (['doc', 'docx', 'pdf', 'xls', 'xlsx'].contains(ext)) {
        docs++;
      } else if (['mp4', 'mov'].contains(ext)) {
        videos++;
      } else {
        others++;
      }
    }

    final List<String> parts = [];

    if (images > 0) parts.add('$images image${images > 1 ? 's' : ''}');
    if (docs > 0) parts.add('$docs doc${docs > 1 ? 's' : ''}');
    if (videos > 0) parts.add('$videos video${videos > 1 ? 's' : ''}');
    if (others > 0) parts.add('$others file${others > 1 ? 's' : ''}');

    return parts.join(', ');
  }
}

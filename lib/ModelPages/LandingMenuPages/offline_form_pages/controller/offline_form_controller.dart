import 'dart:convert';
import 'dart:io';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/db/offline_db_constants.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/db/offline_db_module.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
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

  ///////////////////////////////////////
  // ================= OFFLINE DASHBOARD STATE =================
  @override
  void onInit() {
    super.onInit();
    loadOfflineDashboard(); // 👈 THIS WAS MISSING
  }

  Map<String, dynamic>? offlineUser;
  var offlineFormsCount = 0.obs;
  int pendingCount = 0;

  bool isDashboardBusy = false;

  ///////////////////////////////////////

  // ---------------- LOAD ALL PAGES ----------------

  Future<void> getAllPages() async {
    const String tag = "[OFFLINE_PAGES_LOAD_001]";
    try {
      isLoading.value = true;

      final rawPages = await OfflineDbModule.getOfflinePages();

      if (rawPages.isEmpty) {
        LogService.writeLog(
          message: "$tag[INFO] No offline pages in DB",
        );
        allPages.clear();
        return;
      }

      final pages = rawPages
          .map((e) => OfflineFormPageModel.fromJson(e))
          .where((p) => p.visible)
          .toList();

      allPages.value = pages;

      LogService.writeLog(
        message: "$tag[SUCCESS] Loaded ${pages.length} pages from DB",
      );
    } catch (e, st) {
      LogService.writeLog(
        message: "$tag[FAILED] Failed to load offline pages => $e",
      );
      LogService.writeLog(
        message: "$tag[STACK] $st",
      );
    } finally {
      isLoading.value = false;
    }
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

  Future<void> loadOfflineDashboard() async {
    const String tag = "[OFFLINE_DASHBOARD_001]";

    try {
      LogService.writeLog(message: "$tag[START] Loading offline dashboard");

      offlineUser = await OfflineDbModule.getLastUser();
      offlineFormsCount.value = await OfflineDbModule.getOfflinePagesCount();
      pendingCount = await OfflineDbModule.getPendingCount();

      update();

      LogService.writeLog(message: "$tag[SUCCESS] Dashboard loaded");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
    }
  }

  Future<bool> guardOnlineOrShowDialog() async {
    final connectivity = Get.find<InternetConnectivity>();

    if (connectivity.isConnected.value) return true;

    await Get.dialog(
      AlertDialog(
        title: const Text("No Internet"),
        content: const Text("This action requires internet connection."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    return false;
  }

  Future<void> confirmAndRun({
    required String title,
    required String message,
    required Future<void> Function() action,
  }) async {
    if (isDashboardBusy) return;

    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    isDashboardBusy = true;
    update();

    try {
      await action();
      await loadOfflineDashboard();
    } finally {
      isDashboardBusy = false;
      update();
    }
  }
  // ================= DASHBOARD ACTIONS =================

  void goToOfflineForms() {
    Get.toNamed(Routes.OfflineListingPage);
  }

// ---------- SYNC ----------

  Future<void> refetchAll() async {
    if (!await guardOnlineOrShowDialog()) return;

    await confirmAndRun(
      title: "Refetch Everything",
      message: "This will re-download all forms and datasources. Continue?",
      action: () async {
        await OfflineDbModule.syncAllData(isInternetAvailable: true);
      },
    );
  }

  Future<void> refetchForms() async {
    if (!await guardOnlineOrShowDialog()) return;

    await confirmAndRun(
      title: "Refetch Forms",
      message: "This will re-download all forms. Continue?",
      action: () async {
        await OfflineDbModule.refetchOnlyForms();
      },
    );
  }

  Future<void> refetchDatasources() async {
    if (!await guardOnlineOrShowDialog()) return;

    await confirmAndRun(
      title: "Refetch Datasources",
      message: "This will re-download all datasources. Continue?",
      action: () async {
        await OfflineDbModule.refetchOnlyDatasources();
      },
    );
  }

// ---------- CLEAR ----------

  Future<void> clearAllCache() async {
    await confirmAndRun(
      title: "Clear All Cache",
      message: "This will delete all offline data except user. Continue?",
      action: () async {
        await OfflineDbModule.clearOfflineCache();
      },
    );
  }

  Future<void> clearForms() async {
    await confirmAndRun(
      title: "Clear Forms",
      message: "This will delete all offline forms. Continue?",
      action: () async {
        await OfflineDbModule.deleteTable(
          OfflineDBConstants.TABLE_OFFLINE_PAGES,
        );
      },
    );
  }

  Future<void> clearDatasources() async {
    await confirmAndRun(
      title: "Clear Datasources",
      message: "This will delete all cached datasources. Continue?",
      action: () async {
        await OfflineDbModule.deleteTable(
          OfflineDBConstants.TABLE_DATASOURCE_DATA,
        );
      },
    );
  }

  Future<void> clearPending() async {
    await confirmAndRun(
      title: "Clear Pending Uploads",
      message: "This will delete all pending uploads. Continue?",
      action: () async {
        await OfflineDbModule.clearPendingRequests();
      },
    );
  }

  Future<void> actionSyncAll() async {
    const tag = "[OFFLINE_ACTION_SYNCALL_001]";
    LogService.writeLog(message: "$tag[START]");

    if (!_isInternetAvailable()) {
      _showNeedInternetDialog();
      return;
    }

    final ok = await _confirm(
      title: "Sync All Data",
      message:
          "This will upload pending data and refetch all offline data. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      // TODO: push pending queue
      // await OfflineDbModule.pushPending();

      // Refetch everything
      await OfflineDbModule.fetchAndStoreOfflinePages();
      await OfflineDbModule.fetchAndStoreAllDatasources();

      await getAllPages();
      await loadOfflineDashboard();

      Get.snackbar("Success", "Offline data synced successfully");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to sync offline data");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> actionRefetchForms() async {
    const tag = "[OFFLINE_ACTION_REFETCH_FORMS_001]";

    if (!_isInternetAvailable()) {
      _showNeedInternetDialog();
      return;
    }

    final ok = await _confirm(
      title: "Refetch Forms",
      message: "This will replace all offline forms. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      await OfflineDbModule.fetchAndStoreOfflinePages();
      await getAllPages();
      await loadOfflineDashboard();

      Get.snackbar("Success", "Forms refreshed");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to refetch forms");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> actionRefetchDatasources() async {
    const tag = "[OFFLINE_ACTION_REFETCH_DS_001]";

    if (!_isInternetAvailable()) {
      _showNeedInternetDialog();
      return;
    }

    final ok = await _confirm(
      title: "Refetch Datasources",
      message: "This will replace all cached datasources. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      await OfflineDbModule.fetchAndStoreAllDatasources();

      Get.snackbar("Success", "Datasources refreshed");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to refetch datasources");
    } finally {
      isLoading.value = false;
    }
  }

  void actionShowPending() {}
  Future<void> actionClearForms() async {
    const tag = "[OFFLINE_ACTION_CLEAR_FORMS_001]";

    final ok = await _confirm(
      title: "Clear Forms",
      message: "This will delete all offline forms. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      await OfflineDbModule.clearOfflinePages();
      await getAllPages();
      await loadOfflineDashboard();

      Get.snackbar("Done", "Offline forms cleared");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to clear forms");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> actionClearDatasources() async {
    const tag = "[OFFLINE_ACTION_CLEAR_DS_001]";

    final ok = await _confirm(
      title: "Clear Datasources",
      message: "This will delete all cached datasources. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      await OfflineDbModule.clearDatasources();

      Get.snackbar("Done", "Datasources cleared");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to clear datasources");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> actionClearPending() async {
    const tag = "[OFFLINE_ACTION_CLEAR_PENDING_001]";

    final ok = await _confirm(
      title: "Clear Pending Queue",
      message: "This will delete all pending submissions. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      await OfflineDbModule.clearPendingQueue();

      Get.snackbar("Done", "Pending queue cleared");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to clear pending queue");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> actionClearAll() async {
    const tag = "[OFFLINE_ACTION_CLEAR_ALL_001]";

    final ok = await _confirm(
      title: "Clear ALL Offline Data",
      message: "This will delete ALL offline data except user. Continue?",
      okText: "Yes, Delete",
    );
    if (!ok) return;

    try {
      isLoading.value = true;

      await OfflineDbModule.clearAllExceptUser();
      await getAllPages();
      await loadOfflineDashboard();

      Get.snackbar("Done", "All offline data cleared");
      LogService.writeLog(message: "$tag[SUCCESS]");
    } catch (e, st) {
      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");
      Get.snackbar("Error", "Failed to clear all data");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    String okText = "Yes",
    String cancelText = "Cancel",
  }) async {
    bool result = false;

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              result = false;
              Get.back();
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              result = true;
              Get.back();
            },
            child: Text(okText),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result;
  }

  bool _isInternetAvailable() {
    try {
      final conn = Get.find<InternetConnectivity>();
      return conn.isConnected.value;
    } catch (_) {
      return false;
    }
  }

  void _showNeedInternetDialog() {
    Get.defaultDialog(
      title: "No Internet",
      middleText: "This action requires an internet connection.",
      textConfirm: "OK",
      onConfirm: Get.back,
    );
  }
}

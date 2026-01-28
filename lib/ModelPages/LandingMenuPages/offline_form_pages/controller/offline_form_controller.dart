import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/controller/webview_controller.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class OfflineFormController extends GetxController {
  late OfflineFormPageModel page;

  final Map<String, OfflineFormFieldModel> fieldMap = {};
  List<Map<String, dynamic>> allRawPages = [];
  var isLoading = false.obs;

  RxList<OfflineFormPageModel> allPages = <OfflineFormPageModel>[].obs;

  RxList<OfflineAttachmentModel> attachments = <OfflineAttachmentModel>[].obs;

  final ImagePicker _imagePicker = ImagePicker();

  ///////////////////////////////////////
  // ================= OFFLINE DASHBOARD STATE =================

  var isConnected = false.obs;
  @override
  void onInit() {
    super.onInit();
    refreshPendingCount();
    listenInternetState();
    // loadOfflineDashboard(); // 👈 THIS WAS MISSING
  }

  Future<void> refreshPendingCount() async {
    try {
      int count = await OfflineDbModule.getPendingCount();
      pendingCount.value = count;
    } catch (e) {
      print("Error fetching pending count: $e");
    }
  }

  void listenInternetState() async {
    final InternetConnectivity net = Get.find<InternetConnectivity>();

    isConnected.value = await net.check();

    ever<bool>(net.isConnected, (connected) {
      isConnected.value = connected;
    });
  }

  Map<String, dynamic>? offlineUser;
  var offlineFormsCount = 0.obs;
  var pendingCount = 0.obs;

  bool isDashboardBusy = false;

  ///////////////////////////////////////

  // ---------------- LOAD ALL PAGES ----------------

  Future<void> getAllPages() async {
    const String tag = "[OFFLINE_PAGES_LOAD_001]";
    try {
      isLoading.value = true;

      final rawPages = allRawPages = await OfflineDbModule.getOfflinePages();

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

  // Future<void> loadPage(OfflineFormPageModel pageModel) async {
  //   page = pageModel;
  //   fieldMap.clear();
  //   attachments.clear();

  //   final sortedFields = [...page.fields]
  //     ..sort((a, b) => a.order.compareTo(b.order));

  //   for (final field in sortedFields) {
  //     field.value = field.defValue;
  //     field.errorText = null;
  //     fieldMap[field.fldName] = field;
  //   }

  //   await OfflineDbModule.fetchAndStoreAllDatasources(
  //           transId: pageModel.transId)
  //       .then((_) async {
  //     await OfflineDbModule.mapDatasourceOptionsIntoPages(
  //       pages: [pageModel],
  //     );
  //     update();
  //   });

  //   Get.toNamed(Routes.OfflineFormPage);
  // }

  Future<void> loadPage(OfflineFormPageModel pageModel) async {
    // await OfflineDbModule.fetchAndStoreAllDatasources(transId: page.transId);
    var tempPage =
        await OfflineDbModule.mapDatasourceOptionsIntoPages(pages: [pageModel]);
    page = tempPage.first;
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

  // void updateFieldValue(OfflineFormFieldModel field, dynamic newValue) {
  //   switch (field.fldType) {
  //     case 'cb':
  //       field.value =
  //           (newValue == true || newValue.toString().toLowerCase() == 'true')
  //               .toString();
  //       break;

  //     case 'cl':
  //       if (newValue is List<String>) {
  //         field.value = newValue.join(',');
  //       }
  //       break;

  //     case 'rb':
  //     case 'rl':
  //     case 'dd':
  //     case 'c':
  //     case 'n':
  //     case 'm':
  //     case 'd':
  //       field.value = newValue.toString();
  //       break;
  //     case 'image':
  //       field.value = newValue.toString();
  //       break;

  //     default:
  //       field.value = newValue.toString();
  //       break;
  //   }

  //   field.errorText = null;
  //   fieldMap[field.fldName] = field;
  //   update([field.fldName]);
  // }
  void updateFieldValue(OfflineFormFieldModel field, dynamic newValue) {
    final bool isDs = field.datasource != null && field.datasource!.isNotEmpty;

    switch (field.fldType) {
      case 'cb':
        field.value =
            (newValue == true || newValue.toString().toLowerCase() == 'true')
                .toString();
        break;

      case 'cl':
        if (isDs) {
          // datasource checklist → store list of IDs
          if (newValue is List) {
            field.value = newValue;
          }
        } else {
          // normal checklist → old behavior
          if (newValue is List<String>) {
            field.value = newValue.join(',');
          }
        }
        break;

      case 'rb':
      case 'rl':
      case 'dd':
        if (isDs) {
          field.value = newValue;
        } else {
          field.value = newValue.toString();
        }
        break;

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
        field.value = newValue;
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

  // Future<void> loadOfflineDashboard() async {
  //   const String tag = "[OFFLINE_DASHBOARD_001]";

  //   try {
  //     LogService.writeLog(message: "$tag[START] Loading offline dashboard");

  //     offlineUser = await OfflineDbModule.getLastUser();
  //     offlineFormsCount.value = await OfflineDbModule.getOfflinePagesCount();
  //     pendingCount = await OfflineDbModule.getPendingCount();

  //     update();

  //     LogService.writeLog(message: "$tag[SUCCESS] Dashboard loaded");
  //   } catch (e, st) {
  //     LogService.writeLog(message: "$tag[FAILED] $e");
  //     LogService.writeLog(message: "$tag[STACK] $st");
  //   }
  // }

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
      // await loadOfflineDashboard();
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
        // await OfflineDbModule.refetchOnlyForms();
      },
    );
  }

  Future<void> refetchDatasources() async {
    if (!await guardOnlineOrShowDialog()) return;

    await confirmAndRun(
      title: "Refetch Datasources",
      message: "This will re-download all datasources. Continue?",
      action: () async {
        // await OfflineDbModule.refetchOnlyDatasources();
      },
    );
  }

// ---------- CLEAR ----------

  Future<void> clearAllCache() async {
    await confirmAndRun(
      title: "Clear All Cache",
      message: "This will delete all offline data except user. Continue?",
      action: () async {
        // await OfflineDbModule.clearOfflineCache();
      },
    );
  }

  Future<void> clearForms() async {
    await confirmAndRun(
      title: "Clear Forms",
      message: "This will delete all offline forms. Continue?",
      action: () async {
        // await OfflineDbModule.deleteTable(
        //   OfflineDBConstants.TABLE_OFFLINE_PAGES,
        // );
      },
    );
  }

  Future<void> clearDatasources() async {
    await confirmAndRun(
      title: "Clear Datasources",
      message: "This will delete all cached datasources. Continue?",
      action: () async {
        // await OfflineDbModule.deleteTable(
        //   OfflineDBConstants.TABLE_DATASOURCE_DATA,
        // );
      },
    );
  }

  Future<void> clearPending() async {
    await confirmAndRun(
      title: "Clear Pending Uploads",
      message: "This will delete all pending uploads. Continue?",
      action: () async {
        // await OfflineDbModule.clearPendingRequests();
        refreshPendingCount();
      },
    );
  }

  // Future<void> actionSyncAll() async {
  //   const tag = "[OFFLINE_ACTION_SYNCALL_001]";
  //   LogService.writeLog(message: "$tag[START]");

  //   if (!await _isInternetAvailable()) {
  //     _showNeedInternetDialog();
  //     return;
  //   }

  //   final ok = await _confirm(
  //     title: "Sync All Data",
  //     message:
  //         "This will upload pending data and refetch all offline data. Continue?",
  //   );
  //   if (!ok) return;

  //   try {
  //     isLoading.value = true;

  //     // TODO: push pending queue
  //     // await OfflineDbModule.pushPending();

  //     // Refetch everything
  //     await OfflineDbModule.fetchAndStoreOfflinePages();
  //     // await OfflineDbModule.fetchAndStoreAllDatasources();

  //     await getAllPages();
  //     // await loadOfflineDashboard();

  //     Get.snackbar("Success", "Offline data synced successfully");
  //     LogService.writeLog(message: "$tag[SUCCESS]");
  //   } catch (e, st) {
  //     LogService.writeLog(message: "$tag[FAILED] $e");
  //     LogService.writeLog(message: "$tag[STACK] $st");
  //     Get.snackbar("Error", "Failed to sync offline data");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> actionRefetchForms() async {
    const tag = "[OFFLINE_ACTION_REFETCH_FORMS_001]";

    if (!await _isInternetAvailable()) {
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
      // await loadOfflineDashboard();

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

  // Future<void> actionRefetchDatasources() async {
  //   const tag = "[OFFLINE_ACTION_REFETCH_DS_001]";

  //   if (!await _isInternetAvailable()) {
  //     _showNeedInternetDialog();
  //     return;
  //   }

  //   final ok = await _confirm(
  //     title: "Refetch Datasources",
  //     message: "This will replace all cached datasources. Continue?",
  //   );
  //   if (!ok) return;

  //   try {
  //     isLoading.value = true;

  //     // await OfflineDbModule.fetchAndStoreAllDatasources();

  //     Get.snackbar("Success", "Datasources refreshed");
  //     LogService.writeLog(message: "$tag[SUCCESS]");
  //   } catch (e, st) {
  //     LogService.writeLog(message: "$tag[FAILED] $e");
  //     LogService.writeLog(message: "$tag[STACK] $st");
  //     Get.snackbar("Error", "Failed to refetch datasources");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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
      // await loadOfflineDashboard();

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
      // await loadOfflineDashboard();

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

  // Future<bool> _confirm({
  //   required String title,
  //   required String message,
  //   String okText = "Yes",
  //   String cancelText = "Cancel",
  // }) async {
  //   bool result = false;

  //   await Get.dialog(
  //     AlertDialog(
  //       title: Text(title),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             result = false;
  //             Get.back();
  //           },
  //           child: Text(cancelText),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             result = true;
  //             Get.back();
  //           },
  //           child: Text(okText),
  //         ),
  //       ],
  //     ),
  //     barrierDismissible: false,
  //   );

  //   return result;
  // }

  Future<bool> _confirm({
    required String title,
    required String message,
    String okText = "Yes",
    String cancelText = "Cancel",
    IconData icon = Icons.help_outline_rounded,
    Color confirmColor = const Color(0xFF2563EB),
  }) async {
    bool result = false;

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Icon Circle ---
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: confirmColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: confirmColor),
              ),
              const SizedBox(height: 20),

              // --- Title ---
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // --- Message ---
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // --- Buttons ---
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        result = false;
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Confirm Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        result = true;
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        okText,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    return result;
  }

  Future<bool> _isInternetAvailable() async {
    try {
      final conn = Get.find<InternetConnectivity>();
      return await conn.check();
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

  // ... inside OfflineFormController class ...

  // =================================================
  // ACTION: PUSH PENDING UPLOADS
  // =================================================
  // Future<void> actionPushPending() async {
  //   const tag = "[OFFLINE_ACTION_PUSH_PENDING]";

  //   if (!await _isInternetAvailable()) {
  //     _showNeedInternetDialog();
  //     return;
  //   }

  //   final ok = await _confirm(
  //     title: "Upload Pending Data",
  //     message: "This will attempt to upload all queued submissions. Continue?",
  //     okText: "Upload",
  //   );
  //   if (!ok) return;

  //   try {
  //     isLoading.value = true;
  //     Get.snackbar("Syncing", "Uploading pending records...",
  //         showProgressIndicator: true);

  //     final resultMsg =
  //         await OfflineDbModule.processPendingQueue(isInternetAvailable: true);

  //     Get.back();
  //     Get.snackbar("Sync Complete", resultMsg,
  //         duration: const Duration(seconds: 4));
  //     LogService.writeLog(message: "$tag[DONE] $resultMsg");
  //   } catch (e, st) {
  //     LogService.writeLog(message: "$tag[FAILED] $e");
  //     Get.snackbar("Error", "Failed during upload process");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> actionPushPending() async {
    const tag = "[OFFLINE_ACTION_PUSH_PENDING]";

    // 1. Check Internet
    if (!await _isInternetAvailable()) {
      _showNeedInternetDialog();
      return;
    }

    // 2. Beautiful Confirmation
    final ok = await _confirm(
      title: "Upload Pending Data",
      message:
          "This will upload all locally saved records to the server.\n\nAre you sure you want to continue?",
      okText: "Upload Now",
      icon: Icons.cloud_upload_rounded,
      confirmColor: const Color(0xFF2563EB), // Blue
    );
    if (!ok) return;

    try {
      // 3. Show Progress
      _showSyncProgressDialog(); // Reuse the dialog from previous step
      syncStatusText.value = "Uploading queued submissions...";

      // Artificial delay for UX (optional)
      await Future.delayed(const Duration(milliseconds: 800));

      // 4. Execute Logic
      final resultMsg =
          await OfflineDbModule.processPendingQueue(isInternetAvailable: true);

      Get.back(); // Close Progress Dialog

      // 5. Show Result
      _showSimpleSuccessDialog(title: "Upload Complete", message: resultMsg);
      refreshPendingCount();
      LogService.writeLog(message: "$tag[DONE] $resultMsg");
    } catch (e, st) {
      Get.back(); // Ensure dialog closes
      LogService.writeLog(message: "$tag[FAILED] $e");
      refreshPendingCount();
      Get.snackbar(
        "Upload Error",
        "Failed to process queue. Check logs.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSimpleSuccessDialog(
      {required String title, required String message}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF22C55E),
                size: 56,
              ),
              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Result Details (e.g., "Processed 3 success, 0 failed")
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4), // Light Green bg
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      // Monospaced looks technical/cool for stats
                      fontSize: 13,
                      color: const Color(0xFF15803D),
                      fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Done",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  // Future<void> actionSyncAll() async {
  //   const tag = "[OFFLINE_ACTION_SYNC_ALL]";

  //   if (!await _isInternetAvailable()) {
  //     _showNeedInternetDialog();
  //     return;
  //   }

  //   final ok = await _confirm(
  //     title: "Full Sync",
  //     message:
  //         "This will:\n1. Upload pending data\n2. Download latest Forms\n3. Download latest Datasources\n\nThis may take a moment. Continue?",
  //     okText: "Start Sync",
  //   );
  //   if (!ok) return;

  //   try {
  //     isLoading.value = true;

  //     // STEP 1: Push Pending
  //     Get.snackbar("Step 1/3", "Uploading pending data...",
  //         showProgressIndicator: true);
  //     final pushResult =
  //         await OfflineDbModule.processPendingQueue(isInternetAvailable: true);
  //     LogService.writeLog(message: "$tag[STEP_1] $pushResult");

  //     // STEP 2: Refetch Forms
  //     Get.snackbar("Step 2/3", "Downloading latest forms...",
  //         showProgressIndicator: true);
  //     final pages = await OfflineDbModule.fetchAndStoreOfflinePages();
  //     await getAllPages(); // Refresh controller list
  //     LogService.writeLog(
  //         message: "$tag[STEP_2] Fetched ${pages.length} forms");

  //     // STEP 3: Refetch Datasources
  //     Get.snackbar("Step 3/3", "Downloading datasources...",
  //         showProgressIndicator: true);
  //     await OfflineDbModule.refreshAllDatasourcesFromDownloadedPages();
  //     LogService.writeLog(message: "$tag[STEP_3] Datasources updated");

  //     // DONE
  //     // await loadOfflineDashboard();
  //     Get.back(); // close progress snackbar

  //     Get.dialog(
  //       AlertDialog(
  //         title: const Text("Sync Complete"),
  //         content: Text(
  //             "Uploads: $pushResult\nForms Updated: ${pages.length}\nDatasources: Updated"),
  //         actions: [
  //           TextButton(onPressed: () => Get.back(), child: const Text("OK"))
  //         ],
  //       ),
  //     );
  //   } catch (e, st) {
  //     LogService.writeLog(message: "$tag[FAILED] $e");
  //     LogService.writeLog(message: "$tag[STACK] $st");
  //     Get.snackbar("Error", "Sync failed. Check logs.");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  var syncStatusText = "Initializing...".obs;

  Future<void> actionSyncAll() async {
    const tag = "[OFFLINE_ACTION_SYNC_ALL]";

    // 1. Internet Check
    if (!await _isInternetAvailable()) {
      _showNeedInternetDialog();
      return;
    }

    // 2. Confirmation
    final ok = await _confirm(
      title: "Full Sync",
      message:
          "This will sync pending uploads, forms, and datasources.\n\nContinue?",
      okText: "Start Sync",
    );
    if (!ok) return;

    try {
      // --- START SYNC UI ---
      // Open a non-dismissible progress dialog
      _showSyncProgressDialog();

      // STEP 1: UPLOAD
      syncStatusText.value = "Step 1/3: Uploading pending data...";
      // Artificial delay only if you want users to read the text (optional, e.g. 500ms)
      await Future.delayed(const Duration(milliseconds: 500));

      final pushResult =
          await OfflineDbModule.processPendingQueue(isInternetAvailable: true);
      LogService.writeLog(message: "$tag[STEP_1] $pushResult");

      // STEP 2: FORMS
      syncStatusText.value = "Step 2/3: Checking for new forms...";
      final pages = await OfflineDbModule.fetchAndStoreOfflinePages();
      await getAllPages(); // Refresh the list in memory
      LogService.writeLog(
          message: "$tag[STEP_2] Fetched ${pages.length} forms");

      // STEP 3: DATASOURCES
      syncStatusText.value = "Step 3/3: Updating datasources...";
      await OfflineDbModule.refreshAllDatasourcesFromDownloadedPages();
      LogService.writeLog(message: "$tag[STEP_3] Datasources updated");

      // --- FINISH ---
      Get.back(); // Close Progress Dialog

      // Show Beautiful Success Dialog
      _showSyncSuccessDialog(
        uploads: pushResult,
        formsCount: pages.length,
      );
    } catch (e, st) {
      Get.back(); // Close Progress Dialog on error

      LogService.writeLog(message: "$tag[FAILED] $e");
      LogService.writeLog(message: "$tag[STACK] $st");

      Get.snackbar(
        "Sync Failed",
        "Something went wrong. Please check logs.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSyncProgressDialog() {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button
        child: Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF2563EB)),
                const SizedBox(height: 24),

                // Reactive Text
                Obx(() => Text(
                      syncStatusText.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    )),

                const SizedBox(height: 8),
                Text(
                  "Please wait, do not close the app.",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showSyncSuccessDialog(
      {required String uploads, required int formsCount}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header (Green Success Background) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E), // Success Green
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 60,
                ),
              ),

              // --- Body Content ---
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "Sync Complete!",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Rows
                    _buildSyncStatRow(
                        Icons.cloud_upload, "Upload Status", uploads),
                    const Divider(height: 20),
                    _buildSyncStatRow(Icons.description, "Forms Updated",
                        "$formsCount forms"),
                    const Divider(height: 20),
                    _buildSyncStatRow(
                        Icons.storage, "Datasources", "Refreshed"),

                    const SizedBox(height: 24),

                    // --- OK Button ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Awesome!",
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        // Icon Box
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),

        // Text Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                maxLines: 2, // Allow wrapping if message is long
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> actionRefetchDatasources() async {
    if (!await _isInternetAvailable()) {
      _showNeedInternetDialog();
      return;
    }

    final ok = await _confirm(
      title: "Refetch Datasources",
      message:
          "This will re-download lookup data for all downloaded forms. Continue?",
    );
    if (!ok) return;

    try {
      isLoading.value = true;
      Get.snackbar("Downloading", "Fetching datasources...",
          showProgressIndicator: true);

      await OfflineDbModule.refreshAllDatasourcesFromDownloadedPages();

      Get.back();
      Get.snackbar("Success", "Datasources updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update datasources");
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> onReportCardClick(String transId) async {
    WebViewController webViewController = Get.find();
    var urlNew = "aspx/AxMain.aspx?authKey=AXPERT-" +
        AppStorage().retrieveValue(AppStorage.SESSIONID) +
        "&pname=" +
        transId;
    webViewController.openWebView(url: Const.getFullWebUrl(urlNew));
  }
}

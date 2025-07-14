import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Controller/ProjectListingController.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Model/ProjectModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:scan/scan.dart';

import '../../../Utils/LogServices/LogService.dart';
import 'package:image/image.dart' as img;

class Old_AddConnectionController extends GetxController {
  ProjectListingController projectListingController = Get.find();
  TextEditingController connectionCodeController = TextEditingController();
  TextEditingController webUrlController = TextEditingController();
  TextEditingController armUrlController = TextEditingController();
  TextEditingController conNameController = TextEditingController();
  TextEditingController conCaptionController = TextEditingController();

  var tempProjectName = "";
  var tempProjectCaption = "";
  var tempProjectId = '';

  var selectedRadioValue = "QR".obs;
  var index = 0.obs;
  var deleted = false.obs;
  var updateProjectDetails = false;
  var errCode = ''.obs;
  var errWebUrl = ''.obs;
  var errArmUrl = ''.obs;
  var errName = ''.obs;
  var errCaption = ''.obs;
  var isLoading = false.obs;
  var isFlashOn = false.obs;
  var isPlayPauseOn = false.obs;
  var heading = "Add new Connection".obs;

  // QRViewController? qrViewController;
  MobileScannerController? scannerController;

  // Barcode? barcodeResult;

  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
//------------------
  String ConnectionListName = 'ConnectionListName';

  var projectList = [];

  @override
  void onInit() {
    selectedRadioValue = "QR".obs;
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // requestPermissionForCamera(QRViewController ctrl, bool p) {}

  doesDeviceHasFlash() {
    return true;
  }

//NOTE checkpoint 2
  bool validateProjectDetailsForm() {
    Pattern pattern = r"(https?|http)://([-a-z-A-Z0-9.]+)(/[-a-z-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[a-zA-Z0-9+&@#/%=~_|!:,.;]*)?";
    RegExp regex = RegExp(pattern.toString());
    errWebUrl.value = '';
    errArmUrl.value = '';
    errName.value = '';
    errCaption.value = '';
//web url
    if (webUrlController.text.toString().toLowerCase().trim() == "") {
      errWebUrl.value = "Enter Web Url";
      return false;
    }
    if (!regex.hasMatch(webUrlController.text)) {
      errWebUrl.value = "Enter Valid Web Url";
      return false;
    }
    //Arm url
    if (armUrlController.text.toString().toLowerCase().trim() == "") {
      errArmUrl.value = "Enter Arm Url";
      return false;
    }
    if (!regex.hasMatch(armUrlController.text)) {
      errArmUrl.value = "Enter Valid Arm Url";
      return false;
    }
    //connection name
    if (conNameController.text.toString().trim() == "") {
      errName.value = "Enter Connection Name";
      return false;
    }
    if (conCaptionController.text.toString().trim() == "") {
      errCaption.value = "Enter Caption Name";
      return false;
    }
    return true;
  }

  evaluateErrorText(controller) {
    return controller.value == '' ? null : controller.value;
  }

//NOTE checkpoint 1
  projectDetailsClicked({isQr = false}) async {
    ProjectModel projectModel;
    if (validateProjectDetailsForm()) {
      LoadingScreen.show();
      var baseUrl = armUrlController.text.trim();
      baseUrl += baseUrl.endsWith("/") ? "" : "/";
      var url = baseUrl + ServerConnections.API_GET_APPSTATUS;
      final data = await serverConnections.getFromServer(url: url);
      if (data != "" && data.toString().toLowerCase().contains("running successfully".toLowerCase())) {
        Future<bool> isValidConnName = validateConnectionName(baseUrl);
        if (await isValidConnName) {
          projectModel = ProjectModel(DateTime.now().toString(), conNameController.text.trim(), webUrlController.text.trim(),
              armUrlController.text.trim(), conCaptionController.text.trim());

          var json = projectModel.toJson();
          saveDatAndRedirect(projectModel, json, isQr: isQr);
        }
      }
      LoadingScreen.dismiss();
    } else {
      if (isQr) {
        Get.snackbar(
          "Invalid!",
          "Please choose a valid QR Code",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        scannerController!.start();
      }
    }
  }

  Future<bool> checkDuplicateProject1(ProjectModel model) async {
    var storedValue = await appStorage.retrieveValue(AppStorage.PROJECT_LIST);

    List<String> storedList = [];

    if (storedValue is String) {
      storedList = List<String>.from(jsonDecode(storedValue)); // Properly parse JSON
    } else if (storedValue is List) {
      storedList = List<String>.from(storedValue.first); // Unwrap nested list
    }

    log("storedList => $storedList");

    if (tempProjectId.isNotEmpty) {
      log("${model.projectCaption}");

      var project = appStorage.retrieveValue(tempProjectId);

      var pModel = ProjectModel.fromJson(project);

      if (webUrlController.text.trim() == pModel.web_url &&
          armUrlController.text.trim() == pModel.arm_url &&
          conNameController.text.trim() == pModel.projectname &&
          conCaptionController.text.trim() == pModel.projectCaption) {
        Get.snackbar("Element already exists . ", "",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        return true;
      } else {
        return false;
      }
    }

    // if (storedList.contains(model.id)) {
    //   Get.snackbar("Element already exists", "",
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    //   return true;
    // }

    return false;
  }

  Future<bool> checkDuplicateProject(ProjectModel model) async {
    var storedValue = await appStorage.retrieveValue(AppStorage.PROJECT_LIST);

    List<String> storedList = [];

    if (storedValue is String) {
      storedList = List<String>.from(jsonDecode(storedValue)); // Properly parse JSON
    } else if (storedValue is List) {
      storedList = List<String>.from(storedValue.first); // Unwrap nested list
    }

    log("storedList => $storedList");

    if (storedList.contains(model.projectCaption)) {
      log("${model.projectCaption}");

      var project = appStorage.retrieveValue(model.projectCaption);

      var pModel = ProjectModel.fromJson(project);

      if (webUrlController.text.trim() == pModel.web_url &&
          armUrlController.text.trim() == pModel.arm_url &&
          conNameController.text.trim() == pModel.projectname) {
        Get.snackbar("Element already exists", "",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        return true;
      } else {
        return false;
      }
    }

    return false;
  }

//NOTE checkpoint 4
  void saveDatAndRedirect(projectModel, json, {isQr = false}) async {
    // if (await checkDuplicateProject(projectModel)) {
    //   log("========================>>>>>>>>>>>>FOUND duplicate");
    // } else {
    //   log("========================>>>>>>>>>>>>NO duplicate");
    // }

    if (await checkDuplicateProject1(projectModel)) {
      log("========================>>>>>>>>>>>>FOUND duplicate");
    } else {
      log("========================>>>>>>>>>>>>NO duplicate");
      if (updateProjectDetails) {
        //project name is same as previous
        // if (tempProjectName == projectModel.projectname) {
        //   appStorage.storeValue(projectModel.projectname, json);
        // if (tempProjectName == projectModel.projectCaption) {
        log("checkpoint 4 {tempProjectCaption ($tempProjectCaption) == projectModel.projectCaption (${projectModel.projectCaption}) => ${tempProjectCaption == projectModel.projectCaption}");

        // if (tempProjectCaption == projectModel.projectCaption) {
        //   appStorage.storeValue(projectModel.projectCaption, json);
        //   projectListingController.needRefresh.value = true;
        //   Get.back(result: "{refresh:true}");
        //   updateProjectDetails = false;
        // } else {
        //   //project name is different from previous
        //   deleteExistingProjectWithProjectName(tempProjectCaption);
        //
        //   // deleteExistingProjectWithProjectName(tempProjectName);
        //   bool isSaved = createFreshNewProject(projectModel, json);
        //
        //   log("createFreshNewProject => isSaved => $isSaved");
        //
        //   projectListingController.needRefresh.value = isSaved;
        // }
      } else {
        //create a fresh one
        bool isSaved = createFreshNewProject(projectModel, json, isQr: isQr);
        projectListingController.needRefresh.value = isSaved;
      }
    }
  }

  createFreshNewProject(projectModel, json, {isQr = false}) {
    List<dynamic> projectList = [];
    var storedList = appStorage.retrieveValue(AppStorage.PROJECT_LIST);
    print(storedList);
    if (storedList == null) {
      projectList.add(projectModel.id);
      // projectList.add(projectModel.projectname);

      appStorage.storeValue(projectModel.id, json);
      appStorage.storeValue(AppStorage.PROJECT_LIST, jsonEncode(projectList));
      Get.back(result: "{refresh:true}");
      return true;
    } else {
      projectList = jsonDecode(storedList);
      log("projectList.toString() => $projectList");
      if (projectList.contains(projectModel.id)) {
        log("projectList.contains(projectModel.projectCaption) => ${projectList.contains(projectModel.id)}");

        Get.snackbar("Element already exists", "",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        if (isQr) {
          Timer(Duration(seconds: 2), () {
            scannerController!.start();
          });
        }
        return false;
      } else {
        projectList.add(projectModel.id);
        appStorage.storeValue(projectModel.id, json);
        appStorage.storeValue(AppStorage.PROJECT_LIST, jsonEncode(projectList));
        Get.back(result: "{refresh:true}");
        return true;
      }
    }
  }

  // ******************************************************************** methods for add connection through code
  bool validateConnectionForm() {
    errCode.value = '';
    print(connectionCodeController.text);
    if (connectionCodeController.text.trim().toString() == "") {
      errCode.value = "Please enter valid connection code";
      return false;
    }
    return true;
  }

  connectionCodeClick() async {
    if (validateConnectionForm()) {
      FocusManager.instance.primaryFocus?.unfocus();
      LoadingScreen.show();
      isLoading.value = true;
      var data = await serverConnections.postToServer(ClientID: connectionCodeController.text.toString().trim().toLowerCase());
      LoadingScreen.dismiss();
      if (data == "") {
        isLoading.value = false;
      }
      if (data != "") {
        isLoading.value = false;
        // print(data);
        try {
          var jsonObj = jsonDecode(data);
          jsonObj = jsonObj['result'][0];
          jsonObj = jsonObj['result'];
          jsonObj = jsonObj['row'][0];
          ProjectModel model = ProjectModel.fromJson(jsonObj);
          model.id = DateTime.now().toString();
          print(model.id);
          connectionCodeController.text = "";
          saveDatAndRedirect(model, jsonObj);
        } catch (e) {
          LogService.writeLog(message: "[ERROR] AddConnectionController\nScope: connectionCodeClick()\nError: $e");
          Get.snackbar("Invalid Project Code", "Please check project code and try again",
              backgroundColor: Colors.redAccent, snackPosition: SnackPosition.BOTTOM, colorText: Colors.white);
        }
      }
    }
  }

  void edit(String? keyValue) {
    updateProjectDetails = true;
    var json = appStorage.retrieveValue(keyValue ?? "");
    ProjectModel projectModel = ProjectModel.fromJson(json);
    webUrlController.text = projectModel.web_url;
    armUrlController.text = projectModel.arm_url;
    conNameController.text = projectModel.projectname;
    conCaptionController.text = projectModel.projectCaption;
    tempProjectName = projectModel.projectname;
    tempProjectCaption = projectModel.projectCaption;
    tempProjectId = projectModel.id;

    errArmUrl.value = errCaption.value = errCode.value = errName.value = errWebUrl.value = '';
    Get.toNamed(Routes.AddNewConnection, arguments: [2]);
  }

  Future<bool> delete(String? keyValue) async {
    await Get.defaultDialog(
        title: "Alert!",
        middleText: "Do you want to delete?",
        confirm: ElevatedButton(
          onPressed: () {
            deleteExistingProjectWithProjectName(keyValue);
            Get.back();
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
          child: Text("Yes"),
        ),
        cancel: TextButton(
            onPressed: () {
              Get.back();
              deleted.value = false;
            },
            child: Text("No")));
    return deleted.value;
  }

  deleteExistingProjectWithProjectName(projectName) {
    List<dynamic> projectList = [];
    var storedList = appStorage.retrieveValue(AppStorage.PROJECT_LIST);
    if (storedList != null) {
      projectList = jsonDecode(storedList);
      projectList.remove(projectName);
      appStorage.storeValue(AppStorage.PROJECT_LIST, jsonEncode(projectList));
      appStorage.remove(projectName ?? "");
      var cached = appStorage.retrieveValue(AppStorage.CACHED);
      if (cached != null) {
        if (cached == projectName) appStorage.remove(AppStorage.CACHED);
      }
    }
    deleteCredentials(projectName);
    projectListingController.getConnections();
    deleted.value = true;
    projectListingController.needRefresh.value = true;
  }

  void deleteCredentials(projectName) {
    print("project name to delete: $projectName");
    Map users = appStorage.retrieveValue(AppStorage.USERID) ?? {};
    users.remove(projectName);
    appStorage.storeValue(AppStorage.USERID, users);

    var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
    passes.remove(projectName);
    appStorage.storeValue(AppStorage.USER_PASSWORD, passes);

    var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
    groups.remove(projectName);
    appStorage.storeValue(AppStorage.USER_GROUP, groups);
  }

  void decodeQRResult(String data) {
    try {
      if (validateQRData(data)) {
        var json = jsonDecode(data);
        armUrlController.text = json['arm_url'];
        webUrlController.text = json['p_url'];
        conNameController.text = json['pname'];
        conCaptionController.text = json['pname'];
        // qrViewController!.stopCamera();
        scannerController!.stop();
        projectDetailsClicked(isQr: true);
      } else {
        Get.snackbar("Invalid!", "Please choose a valid QR Code",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      LogService.writeLog(message: "[ERROR] AddConnectionController\nScope: decodeQRResult()\nError: $e");
    }
  }

  // void pickImageFromGalleryCalled() async {
  //   qrViewController!.pauseCamera();
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //   if (image == null) {
  //     qrViewController!.resumeCamera();
  //     return;
  //   }
  //
  //   print(image.path);
  //   String path = image.path;
  //   String? result = await Scan.parse(path);
  //   //print(result);
  //   var data = result ?? "";
  //   if (data == "" || !validateQRData(data)) {
  //     qrViewController!.resumeCamera();
  //     Get.snackbar("Invalid!", "Please choose a valid QR Code",
  //         snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
  //   } else
  //     decodeQRResult(data);
  // }
// Enhance image before QR scanning
  Future<img.Image> enhanceImageQuality(img.Image inputImage) async {
    // Convert to grayscale
    img.Image grayscale = img.grayscale(inputImage);

    // Adjust brightness and contrast
    img.Image enhancedImage = img.adjustColor(grayscale, contrast: 2, brightness: 10);

    return enhancedImage;
  }

  void pickImageFromGalleryCalledML() async {
    scannerController!.pause();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      scannerController!.start();
      return;
    }
    final bytes = await image.readAsBytes();

    // Step 2: Decode the image
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage != null) {
      var enImage = enhanceImageQuality(decodedImage);
      print(image.path);
      String path = image.path;
      BarcodeCapture? result = await scannerController!.analyzeImage(path, formats: [BarcodeFormat.all]);

      print("barcodedata is null => ${result == null}");
    } else {
      print("enhance image is null");
    }
  }

  void pickImageFromGalleryCalled() async {
    scannerController!.pause();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      scannerController!.start();
      return;
    }

    print(image.path);
    String path = image.path;
    BarcodeCapture? result = await scannerController!.analyzeImage(path, formats: [BarcodeFormat.all]);
    //print(result);

    if (result == null) {
      scannerController!.start();
      Get.snackbar("Invalid!", "Please choose a valid QR Code",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } else {
      var data = result.barcodes.first.rawValue ?? "";
      if (data == "" || !validateQRData(data)) {
        scannerController!.start();
        Get.snackbar("Invalid Data!", "Please choose a valid QR Code",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } else
        decodeQRResult(data);
    }
  }

  validateQRData(data) {
    if (!data.toString().contains("arm_url")) return false;
    if (!data.toString().contains("p_url")) return false;
    if (!data.toString().contains("pname")) return false;
    if (!data.toString().contains("pname")) return false;
    return true;
  }

//NOTE checkpoint 3
  Future<bool> validateConnectionName(String baseUrl) async {
    var url = baseUrl + ServerConnections.API_GET_SIGNINDETAILS;
    var body = "{\"appname\":\"" + conNameController.text.trim() + "\"}";
    final response = await serverConnections.postToServer(url: url, body: body);

    if (response != "") {
      var json = jsonDecode(response);
      if (json["result"]["message"].toString().toLowerCase() == "success" && json["result"]["data"]["Value"] is! String)
        return true;
      else {
        errName.value = json["result"]["data"]["Value"].toString();
        return false;
      }
    }
    return false;
  }
}

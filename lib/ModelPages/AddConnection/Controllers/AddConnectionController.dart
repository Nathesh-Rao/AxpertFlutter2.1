import 'dart:convert';
import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Controller/ProjectListingController.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Model/ProjectModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class AddConnectionController extends GetxController {
  ProjectListingController projectListingController = Get.find();
  TextEditingController connectionCodeController = TextEditingController();
  TextEditingController webUrlController = TextEditingController();
  TextEditingController armUrlController = TextEditingController();
  TextEditingController conNameController = TextEditingController();
  TextEditingController conCaptionController = TextEditingController();

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
  var isPlayPauseOn = true.obs;
  QRViewController? qrViewController;
  Barcode? barcodeResult;
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();

  @override
  void onInit() {
    selectedRadioValue = "QR".obs;
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  requestPermissionForCamera(QRViewController ctrl, bool p) {}

  bool validateProjectDetailsForm() {
    Pattern pattern =
        r"(https?|http)://([-a-z-A-Z0-9.]+)(/[-a-z-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[a-zA-Z0-9+&@#/%=~_|!:,.;]*)?";
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

  evaluteErrorText(controller) {
    return controller.value == '' ? null : controller.value;
  }

  projetcDetailsClicked() async {
    ProjectModel projectModel;
    if (validateProjectDetailsForm()) {
      EasyLoading.show(dismissOnTap: false, status: "Please Wait...", maskType: EasyLoadingMaskType.black);
      var url = armUrlController.text.trim();
      url += url.endsWith("/") ? "api/v1/ARMAppStatus" : "/api/v1/ARMAppStatus";
      final data = await serverConnections.getFromServer(url: url);
      EasyLoading.dismiss();

      if (data != "" && data.toString().toLowerCase().contains("running successfully".toLowerCase())) {
        projectModel = ProjectModel(conNameController.text.trim(), webUrlController.text.trim(),
            armUrlController.text.trim(), conCaptionController.text.trim());
        conNameController.text = "";
        webUrlController.text = "";
        armUrlController.text = "";
        conCaptionController.text = "";
        var json = projectModel.toJson();
        saveDatAndRedirect(projectModel, json);
      }
    }
  }

  void saveDatAndRedirect(projectModel, json) {
    //if upodate is required
    if (updateProjectDetails) {
      appStorage.storeValue(projectModel.projectname, json);
      projectListingController.needRefresh.value = true;
      Get.back(result: "{refresh:true}");
      updateProjectDetails = false;
    } else {
      //create a fresh one
      List<dynamic> projectList = [];
      var storedList = appStorage.retrieveValue(AppStorage.projectList);
      print(storedList);
      if (storedList == null) {
        projectList.add(projectModel.projectname);
        appStorage.storeValue(projectModel.projectname, json);
        appStorage.storeValue(AppStorage.projectList, jsonEncode(projectList));
        Get.back(result: "{refresh:true}");
      } else {
        projectList = jsonDecode(storedList);
        if (projectList.contains(projectModel.projectname)) {
          Get.snackbar("Element already exists", "", snackPosition: SnackPosition.BOTTOM);
        } else {
          projectList.add(projectModel.projectname);
          appStorage.storeValue(projectModel.projectname, json);
          appStorage.storeValue(AppStorage.projectList, jsonEncode(projectList));
          Get.back(result: "{refresh:true}");
        }
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
      EasyLoading.show(status: "loading...", maskType: EasyLoadingMaskType.black, dismissOnTap: false);
      isLoading.value = true;
      var data =
          await serverConnections.postToServer(ClientID: connectionCodeController.text.toString().trim().toLowerCase());
      EasyLoading.dismiss();
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
          print(model!.projectCaption);
          connectionCodeController.text = "";
          saveDatAndRedirect(model, jsonObj);
        } catch (e) {
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
    webUrlController.text = projectModel!.web_url;
    armUrlController.text = projectModel!.arm_url;
    conNameController.text = projectModel!.projectname;
    conCaptionController.text = projectModel!.projectCaption;

    Get.toNamed(Routes.AddNewConnection, arguments: [2]);
  }

  Future<bool> delete(String? keyValue) async {
    await Get.defaultDialog(
        title: "Alert!",
        middleText: "Do you want to delete?",
        confirm: ElevatedButton(
          onPressed: () {
            List<dynamic> projectList = [];
            var storedList = appStorage.retrieveValue(AppStorage.projectList);
            if (storedList != null) {
              projectList = jsonDecode(storedList);
              projectList.remove(keyValue);
              appStorage.storeValue(AppStorage.projectList, jsonEncode(projectList));
              appStorage.remove(keyValue ?? "");
              var cached = appStorage.retrieveValue(AppStorage.cached);
              if (cached != null) {
                if (cached == keyValue) appStorage.remove(AppStorage.cached);
              }
            }
            projectListingController.getConnections();
            Get.back();
            deleted.value = true;
            projectListingController.needRefresh.value = true;
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
}

import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  DateTime currentBackPressTime = DateTime.now();
  ServerConnections serverConnections = ServerConnections();
  TextEditingController userCtrl = TextEditingController();
  TextEditingController oPassCtrl = TextEditingController();
  TextEditingController nPassCtrl = TextEditingController();
  TextEditingController cnPassCtrl = TextEditingController();
  var errOPass = ''.obs;
  var errNPass = ''.obs;
  var errCNPass = ''.obs;
  var showOldPass = false.obs;
  var showNewPass = false.obs;
  var showConNewPass = false.obs;
  var bottomIndex = 0.obs;
  var userName = 'j'.obs;
  var linkList = [].obs;
  AppStorage appStorage = AppStorage();
  HomePageController() {
    userName.value = appStorage.retrieveValue(AppStorage.USER_NAME) ?? "Demo";
    userCtrl.text = userName.value;
    linkList.value = [
      Const.getFullProjectUrl('aspx/AxMain.aspx?pname=ddashboard&authKey=AXPERT-') +
          appStorage.retrieveValue(AppStorage.SESSIONID).toString(),
      Const.getFullARMUrl('api/v1/ARMPages?page=ActiveList.html&') +
          'session=' +
          appStorage.retrieveValue(AppStorage.SESSIONID).toString(),
      Const.getFullProjectUrl('aspx/AxMain.aspx?pname=hMy Calendar&authKey=AXPERT-') +
          appStorage.retrieveValue(AppStorage.SESSIONID).toString(),
    ];
  }

  indexChange(val) {
    bottomIndex.value = val;
    print("Index: $bottomIndex");
    print("Link: " + linkList[bottomIndex.value].toString());
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Get.snackbar("Press back again to exit", "",
          colorText: Colors.red,
          isDismissible: true,
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  signOut() async {
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var url = Const.getFullARMUrl(ServerConnections.API_SIGNOUT);
    Get.defaultDialog(
        title: "Log out",
        middleText: "Are you sure you want to log out?",
        confirm: ElevatedButton(
            onPressed: () async {
              var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body));
              print(resp);
              if (resp != "" && !resp.toString().contains("error")) {
                var jsonResp = jsonDecode(resp);
                if (jsonResp['result']['success'].toString() == "true") {
                  Get.offAndToNamed(Routes.Login);
                } else {
                  error(jsonResp['result']['message'].toString());
                }
              } else {
                error("Some error occurred");
              }
            },
            child: Text("Yes")),
        cancel: ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
            onPressed: () {
              Get.back();
            },
            child: Text("No")));
  }

  error(var msg) {
    Get.snackbar("Error!", msg,
        snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
  }

  evalError(val) {
    return val.value == '' ? null : val.value;
  }

  void changePasswordCalled() {}
}

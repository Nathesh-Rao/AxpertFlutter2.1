import 'dart:async';
import 'dart:math';

import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Controller/LoginController.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetConnectivity extends GetxController {
  var isConnected = false.obs;
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      isConnected.value = true;
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      isConnected.value = true;
      return true;
    }
    isConnected.value = false;
    showError();
    return false;
  }

  get connectionStatus => check();

  void showError() {
    Get.defaultDialog(
      title: "Alert!",
      middleText: "No Internet Connections are available.\nPlease try again later",
      confirm: ElevatedButton(
          onPressed: () async {
            Get.back();
            Timer(Duration(milliseconds: 400), () async {
              check().then((value) {
                if (value == true) {
                  doRefresh(Get.currentRoute);
                }
              });
            });
          },
          child: Text("Ok")),
      // cancel: TextButton(
      //     onPressed: () {
      //       Get.back();
      //     },
      //     child: Text("Ok"))
    );
  }
}

doRefresh(String currentRoute) {
  print(currentRoute);
  switch (currentRoute) {
    case Routes.Login:
      LoginController loginController = Get.find();
      loginController.fetchUserTypeList();

      break;
    default:
      break;
  }
}

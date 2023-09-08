import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetConnctiviry extends GetxController {
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
          onPressed: () {
            Get.back();
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

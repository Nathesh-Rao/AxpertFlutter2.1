import 'dart:ui';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomePageController extends GetxController {
  DateTime currentBackPressTime = DateTime.now();
  var bottomIndex = 0.obs;
  var userName = 'j'.obs;
  AppStorage appStorage = AppStorage();
  HomePageController() {
    userName.value = appStorage.retrieveValue(AppStorage.userName) ?? "Demo";
  }

  indexChange(val) {
    bottomIndex.value = val;
    print(bottomIndex.value);
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
}

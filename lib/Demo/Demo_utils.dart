import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/ProjectListing/Model/ProjectModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DemoUtils {
  static const String PROJECT_NAME = "agileerpdemo";
  static const String PROJECT_CAPTION = "agileerpdemo";
  static const String PROJECT_WEB_URL =
      "https://dev.agilecloud.biz/Axpert11.3Web";
  static const String PROJECT_ARM_URL = "https://dev.agilecloud.biz/devarmtest";

  static demoSplashConfig() {
    AppStorage appStorage = AppStorage();
    final ProjectModel pModel = ProjectModel(
        DemoUtils.PROJECT_NAME,
        DemoUtils.PROJECT_WEB_URL,
        DemoUtils.PROJECT_ARM_URL,
        DemoUtils.PROJECT_CAPTION);
    appStorage.storeValue(AppStorage.CACHED, pModel.projectname);
    appStorage.storeValue(pModel.projectname, pModel.toJson());
    appStorage.storeValue(
        AppStorage.PROJECT_LIST, jsonEncode(["agileerpdemo"]));
  }

  static bool demoValidityCheck() {
    var today = DateTime.now();

    if (today.isBefore(Const.DEMO_END_DATE)) {
      return true;
    }

    return false;
  }

  static Future<void> showDemoNotice() async {
    AppStorage appStorage = AppStorage();
    var val = appStorage.retrieveValue(AppStorage.DEMO_IS_FIRST_INSTALL);
    if (val == null || val) {
      var remainingDays = Const.DEMO_END_DATE.difference(DateTime.now()).inDays;
      await Get.defaultDialog(
          barrierDismissible: false,
          title: "Demo Build Active",
          content: Text(
            "This is a demo version of the app. You have $remainingDays days remaining to explore its features. After the demo period, access will no longer be available. Thank you for trying our app!",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: MyColors.text1,
            ),
            textAlign: TextAlign.center,
          ),
          textConfirm: "Accept",
          onConfirm: () {
            Get.back();
          }).then((_) {
        appStorage.storeValue(AppStorage.DEMO_IS_FIRST_INSTALL, false);
        log("First install recorded");
      });
    } else {
      log("First install returned");
      return;
    }
  }

  static showDemoBarrier() async {
    await Get.defaultDialog(
        title: "Action Not Allowed",
        content: Text(
          "Sorry, the action you attempted cannot be performed in the demo version. Thank you for understanding!",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MyColors.text1,
          ),
          textAlign: TextAlign.center,
        ),
        textConfirm: "Close",
        onConfirm: () {
          Get.back();
        });
  }
}

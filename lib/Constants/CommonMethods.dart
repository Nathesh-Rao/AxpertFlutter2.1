import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'AppStorage.dart';
import 'const.dart';

isTablet() {
  return MediaQueryData.fromView(WidgetsBinding.instance.window).size.shortestSide < 600 ? true : false;
}

class CommonMethods {
  static String capitalize(String value) {
    var result = value[0].toUpperCase();
    bool cap = true;
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " " && cap == true) {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
        cap = false;
      }
    }
    return result;
  }

  static String activeList_CreateURL_MAKE(activeList, int index) {
    var url = "";
    if (activeList.recordid.toString().toLowerCase() == "" || activeList.recordid.toString().toLowerCase() == "null") {
      url = "aspx/AxMain.aspx?pname=t" +
          activeList.transid.toString() +
          "&authKey=AXPERT-" +
          AppStorage().retrieveValue(AppStorage.SESSIONID) +
          "&params=^act=open^" +
          activeList.keyfield.toString() +
          "=" +
          activeList.keyvalue.toString();
    } else {
      url = "aspx/AxMain.aspx?pname=t" +
          activeList.transid.toString() +
          "&authKey=AXPERT-" +
          AppStorage().retrieveValue(AppStorage.SESSIONID) +
          "&params=^act=load^recordid=" +
          activeList.recordid.toString();
    }
    return url;
  }

  static String activeList_CreateURL_MESSAGE(activeList, int index) {
    var url = "";
    var msgType = activeList.msgtype.toString().toUpperCase().trim();
    if (msgType == "MESSAGE" || msgType == "FORM NOTIFICATION" || msgType == "PERIODIC NOTIFICATION" || msgType == "CACHED SAVE") {
      var hlink_TRANID = activeList.hlink_transid.toString();
      var hlink_PARAMS =
          activeList.hlink_params.toString().startsWith("^") ? activeList.hlink_params.toString() : "^" + activeList.hlink_params.toString();
      url = "aspx/AxMain.aspx?pname=" +
          hlink_TRANID +
          "&authKey=AXPERT-" +
          AppStorage().retrieveValue(AppStorage.SESSIONID) +
          "&params=" +
          hlink_PARAMS;
    }
    return url;
  }
}

class LoadingScreen {
  static const backName = "DisableBack";

  static show({status = "Please Wait...", maskType = EasyLoadingMaskType.black}) {
    BackButtonInterceptor.add(myInterceptor, zIndex: 2, name: backName);
    EasyLoading.show(status: status, maskType: maskType, dismissOnTap: false);
    Timer(Duration(seconds: 20), () {
      if (EasyLoading.isShow) {
        dismiss();
        // Get.snackbar("Error", "Unable to fetch data",
        //     snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    });
  }

  static dismiss() {
    BackButtonInterceptor.removeByName(backName);
    EasyLoading.dismiss();
  }

  static bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }
}

import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';

class LoginController extends GetxController {
  ServerConnections serverConnections = ServerConnections();
  final googleLoginIn = GoogleSignIn();
  AppStorage appStorage = AppStorage();
  var rememberMe = false.obs;
  var googleSignInVisible = false.obs;
  var ddSelectedValue = "".obs;
  var userTypeList = [].obs;
  var showPassword = true.obs;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  var errUserName = ''.obs;
  var errPassword = ''.obs;
  var fcmId;

  LoginController() {
    fetchUserTypeList();
    userNameController.text = appStorage.retrieveValue(AppStorage.USERID) ?? "";
    userPasswordController.text = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? "";
    ddSelectedValue.value = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? "";
    dropDownItemChanged(ddSelectedValue);
    if (userNameController.text.toString() != "") rememberMe.value = true;
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) => fcmId = value);
  }

  fetchUserTypeList() async {
    LoadingScreen.show();

    // print(Const.ARM_URL);
    userTypeList.clear();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_USERGROUPS);
    var body = Const.getAppBody();
    var data = await serverConnections.postToServer(url: url, body: body);
    LoadingScreen.dismiss();

    if (data != "" && !data.toString().contains("error")) {
      data = data.toString().replaceAll("null", "\"\"");

      // print(data);

      var jsonData = jsonDecode(data)['result']['data'] as List;
      userTypeList.clear();
      for (var item in jsonData) {
        String val = item["usergroup"].toString();
        userTypeList.add(CommonMethods.capitalize(val));
      }
      userTypeList..sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
      if (ddSelectedValue.value == "") {
        ddSelectedValue.value = userTypeList[0];
        dropDownItemChanged(ddSelectedValue);
      }
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return MyColors.blue2;
    }
    return MyColors.blue2;
  }

  fetchSignInDetail() async {
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_SIGNINDETAILS);
    var body = Const.getAppBody();
    var data = await serverConnections.postToServer(url: url, body: body);
    LoadingScreen.dismiss();
  }

  dropdownMenuItem() {
    List<DropdownMenuItem<String>> myList = [];
    for (var item in userTypeList) {
      DropdownMenuItem<String> dditem = DropdownMenuItem(
        value: item.toString(),
        child: Text(item),
      );
      myList.add(dditem);
    }
    return myList;
  }

  dropDownItemChanged(Object? value) {
    ddSelectedValue.value = value.toString();
    if (ddSelectedValue.value.toLowerCase() == "external")
      googleSignInVisible.value = true;
    else
      googleSignInVisible.value = false;
    // print(value);
  }

  errMessage(rxMsg) {
    return rxMsg.value == "" ? null : rxMsg.value;
  }

  bool validateForm() {
    errPassword.value = errUserName.value = "";
    if (userNameController.text.toString().trim() == "") {
      errUserName.value = "Enter User Name";
      return false;
    }
    if (userPasswordController.text.toString().trim() == "") {
      errPassword.value = "Enter Password";
      return false;
    }
    return true;
  }

  getSignInBody() async {
    Map body = {
      "deviceid": Const.DEVICE_ID,
      "appname": Const.PROJECT_NAME,
      "username": userNameController.text.toString().trim(),
      "userGroup": ddSelectedValue.value.toString().toLowerCase(),
      "biometricType": "LOGIN",
      "password": userPasswordController.text.toString().trim()
    };
    return jsonEncode(body);
  }

  void loginButtonClicked() async {
    if (validateForm()) {
      FocusManager.instance.primaryFocus?.unfocus();
      LoadingScreen.show();

      var body = await getSignInBody();
      var url = Const.getFullARMUrl(ServerConnections.API_SIGNIN);
      // print(body.toString());
      // var response = await http.post(Uri.parse(url),
      //     headers: {"Content-Type": "application/json"}, body: body);
      // var data = serverConnections.parseData(response);
      var response = await serverConnections.postToServer(url: url, body: body);
      LoadingScreen.dismiss();

      if (response != "" || !response.toString().toLowerCase().contains("error")) {
        var json = jsonDecode(response);
        // print(json["result"]["sessionid"].toString());
        if (json["result"]["success"].toString().toLowerCase() == "true") {
          await appStorage.storeValue(AppStorage.TOKEN, json["result"]["token"].toString());
          await appStorage.storeValue(AppStorage.SESSIONID, json["result"]["sessionid"].toString());
          await appStorage.storeValue(AppStorage.USER_NAME, userNameController.text);
          await appStorage.storeValue(AppStorage.LAST_LOGIN_DATA, body);
          //Save Data
          if (rememberMe.value) {
            await appStorage.storeValue(AppStorage.USERID, userNameController.text);
            await appStorage.storeValue(AppStorage.USER_PASSWORD, userPasswordController.text);
            await appStorage.storeValue(AppStorage.USER_GROUP, ddSelectedValue.value);
          } else {
            appStorage.remove(AppStorage.USERID);
            appStorage.remove(AppStorage.USER_PASSWORD);
            appStorage.remove(AppStorage.USER_GROUP);
          }

          _processLoginAndGoToHomePage();
        } else {
          Get.snackbar("Error ", json["result"]["message"],
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }

      // print(data);
    }
  }

  void googleSignInClicked() async {
    try {
      final googleUser = await googleLoginIn.signIn();
      if (googleUser != null) {
        LoadingScreen.show();
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        Map body = {
          'appname': Const.PROJECT_NAME,
          'userid': googleUser.email.toString(),
          'userGroup': ddSelectedValue.value.toString(),
          'ssoType': 'Google',
          'ssodetails': {
            'id': googleUser.id,
            'token': googleAuth.accessToken.toString(),
          },
        };

        var url = Const.getFullARMUrl(ServerConnections.API_GOOGLESIGNIN_SSO);
        var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body));
        LoadingScreen.dismiss();
        if (resp != "" && !resp.toString().contains("error")) {
          var jsonResp = jsonDecode(resp);
          // print(jsonResp);
          if (jsonResp['result']['success'].toString() == "false") {
            Get.snackbar("Alert!", jsonResp['result']['message'].toString(),
                snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
          } else {
            await appStorage.storeValue(AppStorage.TOKEN, jsonResp["result"]["token"].toString());
            await appStorage.storeValue(AppStorage.SESSIONID, jsonResp["result"]["sessionid"].toString());
            await appStorage.storeValue(AppStorage.USER_NAME, googleUser.email.toString());
            //remove rememberer data
            appStorage.remove(AppStorage.USERID);
            appStorage.remove(AppStorage.USER_PASSWORD);
            appStorage.remove(AppStorage.USER_GROUP);
            _processLoginAndGoToHomePage();
          }
        } else {
          Get.snackbar("Error", "Some Error occured",
              backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        }
        // print(resp);
        // print(googleUser);
      }
    } catch (e) {
      Get.snackbar("Error", "User is not Registered!",
          snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  _processLoginAndGoToHomePage() async {
    //mobile Notification
    await _callApiForMobileNotification();
    //connect to Axpert
    var connectBody = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var cUrl = Const.getFullARMUrl(ServerConnections.API_CONNECTTOAXPERT);
    var connectResp = await serverConnections.postToServer(url: cUrl, body: jsonEncode(connectBody), isBearer: true);
    print(connectResp);
    // getArmMenu

    var jsonResp = jsonDecode(connectResp);
    if (jsonResp != "" && !jsonResp.toString().contains("error")) {
      if (jsonResp['result']['success'].toString() == "true") {
        Get.offAllNamed(Routes.LandingPage);
      } else {
        showErrorSnack();
      }
    } else {
      showErrorSnack();
    }
  }

  showErrorSnack() {
    Get.snackbar("Error", "Server busy, Please try again later.",
        snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
  }

  _callApiForMobileNotification() async {
    var imei = await PlatformDeviceId.getDeviceId ?? '0';
    var connectBody = {
      'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
      'firebaseId': fcmId ?? "0",
      'ImeiNo': imei,
    };
    var cUrl = Const.getFullARMUrl(ServerConnections.API_MOBILE_NOTIFICATION);
    var connectResp = await serverConnections.postToServer(url: cUrl, body: jsonEncode(connectBody), isBearer: true);
    print("Mobile: " + connectResp);
  }

  getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    var version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return version;
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
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
  var ddSelectedValue = "power".obs;
  var userTypeList = [].obs;
  var showPassword = true.obs;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  var errUserName = ''.obs;
  var errPassword = ''.obs;
  var fcmId;
  var willBio_userAuthenticate = false.obs;
  var isBiometricAvailable = false.obs;

  LoginController() {
    // fetchUserTypeList();

    fetchRememberedData();
    dropDownItemChanged(ddSelectedValue);
    if (userNameController.text.toString().trim() != "") rememberMe.value = true;

    setWillAuthenticate();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) => fcmId = value);
  }

  setWillAuthenticate() async {
    await checkBiometricFlag();
    var willAuth = await getWillBiometricAuthenticateForThisUser(userNameController.text.toString().trim());
    print(("Login willAuth: $willAuth"));
    LogService.writeLog(message: "[i] LoginController\nScope: setWillAuthenticate()\nLogin willAuth: $willAuth");

    if (willAuth != null) {
      willBio_userAuthenticate.value = willAuth;
    }
    if (isBiometricAvailable == true) displayAuthenticationDialog();
  }

  fetchUserTypeList() async {
    LoadingScreen.show();

    // print(Const.ARM_URL);
    userTypeList.clear();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_USERGROUPS);
    var body = Const.getAppBody();
    var data = await serverConnections.postToServer(url: url, body: body);
    LoadingScreen.dismiss();
    if (data != "") {
      data = data.toString().replaceAll("null", "\"\"");

      // print(data);

      var jsonData = jsonDecode(data)['result']['data'] as List;
      userTypeList.clear();

      for (var item in jsonData) {
        String val = item["usergroup"].toString();
        val = CommonMethods.capitalize(val);
        if (!userTypeList.contains(val)) userTypeList.add(val);
      }
      userTypeList..sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
      if (ddSelectedValue.value == "") {
        ddSelectedValue.value = userTypeList[0];
        dropDownItemChanged(ddSelectedValue);
      }
    }
  }

  Color getColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return MyColors.blue2;
    }
    return MyColors.blue2;
  }

  // fetchSignInDetail() async {
  //   LoadingScreen.show();
  //   var url = Const.getFullARMUrl(ServerConnections.API_GET_SIGNINDETAILS);
  //   var body = Const.getAppBody();
  //   await serverConnections.postToServer(url: url, body: body);
  //   LoadingScreen.dismiss();
  // }

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
    if (ddSelectedValue.value.toLowerCase() == "power" || ddSelectedValue.value.isEmpty) {
      newUserSigninVisible.value = false;
    } else {
      newUserSigninVisible.value = true;
    }
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
      "appname": Const.PROJECT_NAME,
      "username": userNameController.text.toString().trim(),
      "password": userPasswordController.text.toString().trim(),
      "Language": "English"
      //"deviceid": Const.DEVICE_ID,
      //"userGroup": "power",
      // "userGroup": ddSelectedValue.value.toString().toLowerCase(),
      //"biometricType": "LOGIN",
    };
    return jsonEncode(body);
  }

  void loginButtonClicked({bodyArgs = ''}) async {
    LogService.writeLog(message: "[i] LoginController\nSelected UserGroup : power");
    if (validateForm()) {
      FocusManager.instance.primaryFocus?.unfocus();
      LoadingScreen.show();
      var body = bodyArgs == '' ? await getSignInBody() : bodyArgs;
      //var url = Const.getFullARMUrl(ServerConnections.API_SIGNIN);
      var url = Const.getFullARMUrl(ServerConnections.API_AX_START_SESSION);
      var response = await serverConnections.postToServer(url: url, body: body);
      // LogService.writeLog(message: "[-] LoginController => loginButtonClicked() => LoginResponse : $response");

      if (response != "") {
        var json = jsonDecode(response);
        // print(json["result"]["sessionid"].toString());
        if (json["result"]["success"].toString().toLowerCase() == "true") {
          await appStorage.storeValue(AppStorage.TOKEN, json["result"]["token"].toString());
          await appStorage.storeValue(AppStorage.SESSIONID, json["result"]["sessionid"].toString());
          await appStorage.storeValue(AppStorage.USER_NAME, userNameController.text.trim());
          await appStorage.storeValue(AppStorage.USER_CHANGE_PASSWORD, json["result"]["ChangePassword"].toString());
          await appStorage.storeValue(AppStorage.NICK_NAME, json["result"]["NickName"].toString() ?? userNameController.text.trim());
          storeLastLoginData(body);
          print("User_change_password: ${appStorage.retrieveValue(AppStorage.USER_CHANGE_PASSWORD)}");
          LogService.writeLog(
              message:
                  "[-] LoginController\nScope: loginButtonClicked()\nUser_change_password: ${appStorage.retrieveValue(AppStorage.USER_CHANGE_PASSWORD)}");

          //Save Data
          if (rememberMe.value) {
            rememberCredentials();
          } else {
            dontRememberCredentials();
          }

          await _processLoginAndGoToHomePage();
        } else {
          Get.snackbar("Error ", json["result"]["message"],
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }
      LoadingScreen.dismiss();
    }
  }

  void googleSignInClicked() async {
    LogService.writeLog(message: "[-] LoginController\nScope: googleSignInClicked() : GoogleLogin Started");

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
          'userGroup': "power",
          // 'userGroup': ddSelectedValue.value.toString(),
          'ssoType': 'Google',
          'ssodetails': {
            'id': googleUser.id,
            'token': googleAuth.accessToken.toString(),
          },
        };

        var url = Const.getFullARMUrl(ServerConnections.API_GOOGLESIGNIN_SSO);
        var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body));

        if (resp != "") {
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
            // appStorage.remove(AppStorage.USERID);
            // appStorage.remove(AppStorage.USER_PASSWORD);
            // appStorage.remove(AppStorage.USER_GROUP);
            dontRememberCredentials();
            await _processLoginAndGoToHomePage();
          }
        } else {
          Get.snackbar("Error", "Some Error occured", backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        }
        LoadingScreen.dismiss();
        // print(resp);
        // print(googleUser);
      } else {
        LogService.writeLog(message: "[ERROR] LoginController\nScope: googleSignInClicked() : googleUser is null");
      }
    } catch (e) {
      LogService.writeLog(message: "[ERROR] LoginController\nScope: googleSignInClicked()\nError: $e");

      Get.snackbar("Error", "User is not Registered!", snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  _processLoginAndGoToHomePage() async {
    //mobile Notification
    await _callApiForMobileNotification();
    //connect to Axpert
    await _callApiForConnectToAxpert();
    // Get.offAllNamed(Routes.LandingPage);
    //
    //burnur code for navigating to ess portal - amrith--->
    if (isPortalDefault.value) {
      Get.offAllNamed(Routes.LandingPage);
    } else {
      Get.offAllNamed(Routes.EssHomePage);
    } //------------------------------------------------>
  }

  Future<void> _callApiForConnectToAxpert() async {
    var connectBody = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var cUrl = Const.getFullARMUrl(ServerConnections.API_CONNECTTOAXPERT);
    var connectResp = await serverConnections.postToServer(url: cUrl, body: jsonEncode(connectBody), isBearer: true);
    print(connectResp);
    // getArmMenu

    var jsonResp = jsonDecode(connectResp);
    if (jsonResp != "") {
      if (jsonResp['result']['success'].toString() == "true") {
        // Get.offAllNamed(Routes.LandingPage);
      } else {
        var message = jsonResp['result']['message'].toString();
        showErrorSnack(title: "Error - Connect To Axpert", message: message);
      }
    } else {
      showErrorSnack();
    }
  }

  _callApiForMobileNotification() async {
    var imei = await PlatformDeviceId.getDeviceId ?? '0';
    LogService.writeLog(message: "[i] IMEI : $imei");
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
    Const.APP_VERSION = version;
    return version;
  }

  void rememberCredentials() {
    int count = 1;
    try {
      count++;
      var users = appStorage.retrieveValue(AppStorage.USERID) ?? {};
      users[Const.PROJECT_NAME] = userNameController.text.trim();
      appStorage.storeValue(AppStorage.USERID, users);

      var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
      passes[Const.PROJECT_NAME] = userPasswordController.text;
      appStorage.storeValue(AppStorage.USER_PASSWORD, passes);

      var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
      groups[Const.PROJECT_NAME] = "power";
      // groups[Const.PROJECT_NAME] = ddSelectedValue.value;
      appStorage.storeValue(AppStorage.USER_GROUP, groups);
    } catch (e) {
      appStorage.remove(AppStorage.USERID);
      appStorage.remove(AppStorage.USER_PASSWORD);
      appStorage.remove(AppStorage.USER_GROUP);
      if (count < 10) rememberCredentials();
    }
  }

  void dontRememberCredentials() {
    Map users = appStorage.retrieveValue(AppStorage.USERID) ?? {};
    users.remove(Const.PROJECT_NAME);
    appStorage.storeValue(AppStorage.USERID, users);

    var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
    passes.remove(Const.PROJECT_NAME);
    appStorage.storeValue(AppStorage.USER_PASSWORD, passes);

    var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
    groups.remove(Const.PROJECT_NAME);
    appStorage.storeValue(AppStorage.USER_GROUP, groups);
  }

  void fetchRememberedData() {
    try {
      var users = appStorage.retrieveValue(AppStorage.USERID) ?? {};
      print(users);
      userNameController.text = users[Const.PROJECT_NAME].trim() ?? "";

      var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
      userPasswordController.text = passes[Const.PROJECT_NAME] ?? "";

      var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
      ddSelectedValue.value = "Power";
    } catch (e) {
      // appStorage.remove(AppStorage.USERID);
      // appStorage.remove(AppStorage.USER_PASSWORD);
      // appStorage.remove(AppStorage.USER_GROUP);
    }
  }

  void displayAuthenticationDialog() async {
    LogService.writeLog(message: "[^] LoginController\nScope: displayAuthenticationDialog()\n Fingerprint Clicked");

    if (willBio_userAuthenticate == true) {
      try {
        if (await showBiometricDialog()) {
          loginButtonClicked(bodyArgs: retrieveLastLoginData());
        }
      } catch (e) {
        print(e.toString());
        if (e.toString().contains('NotAvailable') && e.toString().contains('Authentication failure'))
          showErrorSnack(title: "Oops!", message: "Only Biometric is allowed.");
      }
    } else {
      print("willAuthenticate => $willBio_userAuthenticate");
    }
  }

  void storeLastLoginData(body) {
    AppStorage appStorage = AppStorage();
    var projectName = Const.PROJECT_NAME;
    Map lastData = appStorage.retrieveValue(AppStorage.LAST_LOGIN_DATA) ?? {};
    lastData[projectName] = body;
    appStorage.storeValue(AppStorage.LAST_LOGIN_DATA, lastData);
  }

  retrieveLastLoginData() {
    AppStorage appStorage = AppStorage();
    var projectName = Const.PROJECT_NAME;
    Map lastData = appStorage.retrieveValue(AppStorage.LAST_LOGIN_DATA) ?? {};
    return lastData[projectName] ?? '';
  }

//----------------------------------------------------
  //---------------------- to switch portal---------->
//----------------------------------------------------

  var portalDropdownValue = "Default".obs;
  var isPortalDefault = true.obs;
  var newUserSigninVisible = false.obs;

  List<String> portalNameList = ["Default", "ESS"];

//------methods-------------------
  portalDropdownMenuItem() {
    List<DropdownMenuItem<String>> portalList = [];

    for (var item in portalNameList) {
      DropdownMenuItem<String> dditem = DropdownMenuItem(
        value: item.toString(),
        child: Text(item),
      );
      portalList.add(dditem);
    }
    return portalList;
  }

//
  portalDropDownItemChanged(Object? value) {
    portalDropdownValue.value = value.toString();
    if (value.toString().toLowerCase() == "default") {
      isPortalDefault.value = true;
    } else {
      isPortalDefault.value = false;
    }
    // print(value);
  }

  checkBiometricFlag() async {
    var baseUrl = Const.ARM_URL.trim();
    baseUrl += baseUrl.endsWith("/") ? "" : "/";
    var url = baseUrl + ServerConnections.API_GET_SIGNINDETAILS;
    var body = "{\"appname\":\"" + Const.PROJECT_NAME.trim() + "\"}";
    final response = await serverConnections.postToServer(url: url, body: body);

    if (response != "") {
      var json = jsonDecode(response);
      var isBMValue = json["result"]["data"]["Value"]["result"]["data"]["enablefingerprint"].toString().toLowerCase();
      print("checkBiometricFlag() => isBMValue: $isBMValue");
      if (isBMValue == "true") {
        isBiometricAvailable.value = true;
      } else {
        isBiometricAvailable.value = false;
      }
    } else {
      isBiometricAvailable.value = false;
    }
  }
}

import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  ServerConnections serverConnections = ServerConnections();
  final googleLoginIn = GoogleSignIn();
  AppStorage appStorage = AppStorage();
  var rememberMe = false.obs;
  var googleSigninVisible = false.obs;
  var ddSelectedValue = "".obs;
  var userTypeList = [].obs;
  var showPassword = true.obs;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  var errUserName = ''.obs;
  var errPassword = ''.obs;

  LoginController() {
    fetchUserTypeList();
    userNameController.text = appStorage.retrieveValue(AppStorage.USERID) ?? "";
    userPasswordController.text = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? "";
    if (userNameController.text.toString() != "") rememberMe.value = true;
  }

  fetchUserTypeList() async {
    EasyLoading.show(status: "Please wait...", maskType: EasyLoadingMaskType.black);
    print(Const.ARM_URL);
    userTypeList.clear();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_USERGROUPS);
    var body = Const.getAppBody();
    var data = await serverConnections.postToServer(url: url, body: body);
    EasyLoading.dismiss();

    if (data != "" && !data.toString().contains("error")) {
      data = data.toString().replaceAll("null", "\"\"");

      print(data);

      var jsopnData = jsonDecode(data)['result']['data'] as List;
      userTypeList.clear();
      for (var item in jsopnData) {
        String val = item["usergroup"].toString();
        userTypeList.add(CommonMethods.capitalize(val));
      }
      userTypeList..sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
      ddSelectedValue.value = userTypeList[0];
      dropDownItemChanged(ddSelectedValue);
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.blue;
  }

  fetchSignInDetail() async {
    EasyLoading.show(status: "Please wait...", maskType: EasyLoadingMaskType.black);
    print(Const.ARM_URL);
    var url = Const.getFullARMUrl(ServerConnections.API_GET_SIGNINDETAILS);
    var body = Const.getAppBody();
    print(body);
    var data = await serverConnections.postToServer(url: url, body: body);
    EasyLoading.dismiss();
    // var jsopnData = jsonDecode(data);
    print(data);
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
      googleSigninVisible.value = true;
    else
      googleSigninVisible.value = false;
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
      EasyLoading.show(status: "Please wait.", maskType: EasyLoadingMaskType.black);

      var body = await getSignInBody();
      var url = Const.getFullARMUrl(ServerConnections.API_SIGNIN);
      print(body.toString());
      // var response = await http.post(Uri.parse(url),
      //     headers: {"Content-Type": "application/json"}, body: body);
      // var data = serverConnections.parseData(response);
      var response = await serverConnections.postToServer(url: url, body: body);
      EasyLoading.dismiss();

      if (response != "" || !response.toString().toLowerCase().contains("error")) {
        var json = jsonDecode(response);
        // print(json["result"]["sessionid"].toString());
        if (json["result"]["success"].toString().toLowerCase() == "true") {
          await appStorage.storeValue(AppStorage.TOKEN, json["result"]["token"].toString());
          await appStorage.storeValue(AppStorage.SESSIONID, json["result"]["sessionid"].toString());
          await appStorage.storeValue(AppStorage.USER_NAME, userNameController.text);
          //Save Data
          if (rememberMe.value) {
            await appStorage.storeValue(AppStorage.USERID, userNameController.text);
            await appStorage.storeValue(AppStorage.USER_PASSWORD, userPasswordController.text);
          } else {
            appStorage.remove(AppStorage.USERID);
            appStorage.remove(AppStorage.USER_PASSWORD);
          }

          ProcessLoginAndGoToHomePage();
        } else {
          Get.snackbar("Error ", json["result"]["message"],
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        }
      }

      // print(data);
    }
  }

  void googleSignInClicked() async {
    final googleUser = await googleLoginIn.signIn();
    if (googleUser != null) {
      EasyLoading.show(status: "Please wait...", maskType: EasyLoadingMaskType.black);
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      // print("data: $data");
      // print("access token : " + googleAuth.accessToken.toString());
      // print("ID Token : " + googleAuth.idToken.toString());
      // print("ID signInMethod : " + credential.signInMethod);
      // print("ID providerId : " + credential.providerId);
      // print("ID Token : " + credential.providerId);
      // print("ID Token : " + googleUser!.displayName.toString());
      // print("ID Token : " + googleUser!.email.toString());
      // print("ID Token : " + googleUser!.photoUrl.toString());
      // print("appname----loginsmallscreen.dart3");
      // "ssoType":"$ssotype","ssodetails":{"id":"$userid","token":"$token"}}';

      Map body = {
        'appname': Const.PROJECT_NAME,
        'userid': googleUser!.email.toString(),
        'userGroup': ddSelectedValue.value.toString(),
        'ssoType': 'Google',
        'ssodetails': {
          'id': googleUser!.id,
          'token': googleAuth.accessToken.toString(),
        },
      };

      var url = Const.getFullARMUrl(ServerConnections.API_GOOGLESIGNIN_SSO);
      var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body));
      EasyLoading.dismiss();
      if (resp != "" && !resp.toString().contains("error")) {
        var jsonResp = jsonDecode(resp);
        print(jsonResp);
        if (jsonResp['result']['success'].toString() == "false") {
          Get.snackbar("Alert!", jsonResp['result']['message'].toString(),
              snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
        } else {
          ProcessLoginAndGoToHomePage();
        }
      } else {
        Get.snackbar("Error", "Some Error occured",
            backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
      print(resp);
      // print(googleUser);
    }
  }

  ProcessLoginAndGoToHomePage() async {
    //connect to Axpert
    var conectBody = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var cUrl = Const.getFullARMUrl(ServerConnections.API_CONNECTTOAXPERT);

    var cHeader = {
      'Content-Type': "application/json",
      'Authorization': 'Bearer ' + appStorage.retrieveValue(AppStorage.TOKEN)
    };
    var connectResp = await serverConnections.postToServer(url: cUrl, body: jsonEncode(conectBody), header: cHeader);
    print(connectResp);
    // getArmMenu

    var jsonResp = jsonDecode(connectResp);
    if (jsonResp != "" && !jsonResp.toString().contains("error")) {
      if (jsonResp['result']['success'].toString() == "true") {
        Get.offAndToNamed(Routes.LandingPage);
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
}

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
    userNameController.text = appStorage.retrieveValue(AppStorage.userID) ?? "";
    userPasswordController.text = appStorage.retrieveValue(AppStorage.userPass) ?? "";
    if (userNameController.text.toString() != "") rememberMe.value = true;
  }

  fetchUserTypeList() async {
    EasyLoading.show(status: "Please wait...", maskType: EasyLoadingMaskType.black);
    print(Const.ARM_URL);
    var url = Const.getFullARMUrl(ServerConnections.groupEntryPoint);
    var body = Const.getAppBody();
    var data = await serverConnections.postToServer(url: url, body: body);
    EasyLoading.dismiss();

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
    var url = Const.getFullARMUrl(ServerConnections.signInDetailsEntryPoint);
    var body = Const.getAppBody();
    print(body);
    var data = await serverConnections.postToServer(url: url, body: body);
    EasyLoading.dismiss();
    var jsopnData = jsonDecode(data);
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
      var url = Const.getFullARMUrl(ServerConnections.userSignInEntryPoint);
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
          await appStorage.storeValue(AppStorage.token, json["result"]["token"].toString());
          await appStorage.storeValue(AppStorage.sessionId, json["result"]["sessionid"].toString());
          await appStorage.storeValue(AppStorage.userName, userNameController.text);
          //Save Data
          if (rememberMe.value) {
            await appStorage.storeValue(AppStorage.userID, userNameController.text);
            await appStorage.storeValue(AppStorage.userPass, userPasswordController.text);
          } else {
            appStorage.remove(AppStorage.userID);
            appStorage.remove(AppStorage.userPass);
          }

          Get.offAndToNamed(Routes.HomePage);
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

      var data = await FirebaseAuth.instance.signInWithCredential(credential);
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

      var url = Const.getFullARMUrl(ServerConnections.googleSignInSSOEntryPoint);
      var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body));
      EasyLoading.dismiss();
      if (resp != "" && !resp.toString().contains("error")) {
        var jsonResp = jsonDecode(resp);
        print(jsonResp);
        if (jsonResp['result']['success'].toString() == "false") {
          Get.snackbar("Alert!", jsonResp['result']['message'].toString(),
              snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
        } else {
          Get.offAndToNamed(Routes.HomePage);
        }
      } else {
        Get.snackbar("Error", "Some Error occured",
            backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
      print(resp);
      // print(googleUser);
    }
  }
}

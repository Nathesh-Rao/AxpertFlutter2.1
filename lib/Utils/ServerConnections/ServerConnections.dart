import 'dart:convert';
import 'package:axpertflutter/Constants/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ServerConnections {
  static var client = http.Client();
  static String groupEntryPoint = "api/v1/ARMUserGroups";
  static String signInDetailsEntryPoint = "api/v1/ARMSigninDetails";
  static String userSignInEntryPoint = "api/v1/ARMSignIn";
  static String appStatusEntryPoint = "api/v1/ARMAppStatus";
  static String addUserEntryPoint = "api/v1/ARMAddUser";
  static String otpValidationEntryPoint = "api/v1/ARMValidateAddUser";
  static String forgetPasswordEntryPoint = "api/v1/ARMForgetPassword";
  static String validateForgetPasswordEntryPoint = "api/v1/ARMValidateForgotPassword";
  static String googleSignInSSOEntryPoint = "api/v1/ARMSigninSSO";

  ServerConnections() {
    client = http.Client();
  }

  var _baseBody = "";

  String _baseUrl =
      "http://demo.agile-labs.com/axmclientidscripts/asbmenurest.dll/datasnap/rest/Tasbmenurest/getchoices";

  postToServer({String url = '', var header = '', String body = '', String ClientID = ''}) async {
    try {
      if (ClientID != '') _baseBody = _generateBody(ClientID.toLowerCase());
      if (url == '') url = _baseUrl;
      if (header == '') header = {"Content-Type": "application/json"};
      if (body == '') body = _baseBody;
      print("Post Url: $url");
      // print("Post header: $header");
      // print("Post body:" + body);
      var response = await client.post(Uri.parse(url), headers: header, body: body);
      if (response.statusCode == 200) return response.body;
      if (response.statusCode == 404) {
        Get.snackbar("Error " + response.statusCode.toString(), "Invalid Url",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      } else {
        if (response.statusCode == 400) {
          return response.body;
        } else {
          Get.snackbar("Error " + response.statusCode.toString(), "Internal server error",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error ", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
    return "";
  }

  // parseData(http.Response response) async {
  //   try {
  //     if (response.statusCode == 200) return response.body;
  //     if (response.statusCode == 404) {
  //       Get.snackbar("Error " + response.statusCode.toString(), "Invalid Url",
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.redAccent,
  //           colorText: Colors.white);
  //     } else {
  //       Get.snackbar(
  //           "Error " + response.statusCode.toString(), "Internal server error",
  //           snackPosition: SnackPosition.BOTTOM,
  //           backgroundColor: Colors.redAccent,
  //           colorText: Colors.white);
  //     }
  //   } catch (e) {
  //     Get.snackbar("Error ", e.toString(),
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.redAccent,
  //         colorText: Colors.white);
  //   }
  // }

  getFromServer({String url = '', var header = ''}) async {
    try {
      if (url == '') url = _baseUrl;
      if (header == '') header = {"Content-Type": "application/json"};
      print("Get Url: $url");
      var response = await client.get(Uri.parse(url), headers: header);
      if (response.statusCode == 200) return response.body;
      if (response.statusCode == 404) {
        Get.snackbar("Error " + response.statusCode.toString(), "Invalid Url",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      } else {
        Get.snackbar("Error " + response.statusCode.toString(), "Internal server error",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error ", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
    EasyLoading.dismiss();
  }

  _generateBody(String ClientId) {
    return "{\"_parameters\":[{\"getchoices\":"
        "{\"axpapp\":\"${Const.CLOUD_PROJECT}\","
        "\"username\":\"${Const.DUMMY_USER}\","
        "\"password\":\"${Const.DUMMYUSER_PWD}\","
        "\"seed\":\"${Const.SEED_V}\","
        "\"trace\":\"true\","
        "\"sql\":\"${Const.getSQLforClientID(ClientId)}\","
        "\"direct\":\"false\","
        "\"params\":\"\"}}]}";
  }
}

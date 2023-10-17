import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ServerConnections {
  static var client = http.Client();
  InternetConnectivity internetConnectivity = Get.find();
  static const String API_GET_USERGROUPS = "api/v1/ARMUserGroups";
  static const String API_GET_SIGNINDETAILS = "api/v1/ARMSigninDetails";
  static const String API_SIGNIN = "api/v1/ARMSignIn";
  static const String API_GET_APPSTATUS = "api/v1/ARMAppStatus";
  static const String API_ADDUSER = "api/v1/ARMAddUser";
  static const String API_OTP_VALIDATE_USER = "api/v1/ARMValidateAddUser";
  static const String API_FORGETPASSWORD = "api/v1/ARMForgetPassword";
  static const String API_VALIDATE_FORGETPASSWORD = "api/v1/ARMValidateForgotPassword";
  static const String API_GOOGLESIGNIN_SSO = "api/v1/ARMSigninSSO";
  static const String API_CONNECTTOAXPERT = "api/v1/ARMConnectToAxpert";
  static const String API_GET_HOMEPAGE_CARDS = "api/v1/ARMGetHomePageCards";
  static const String API_GET_HOMEPAGE_CARDSDATASOURCE = "api/v1/ARMGetDataResponse";

  static const String API_GET_MENU = "api/v1/ARMGetMenu";
  static const String API_SIGNOUT = "api/v1/ARMSignOut";

  ServerConnections() {
    client = http.Client();
  }

  var _baseBody = "";

  String _baseUrl =
      "http://demo.agile-labs.com/axmclientidscripts/asbmenurest.dll/datasnap/rest/Tasbmenurest/getchoices";

  postToServer({String url = '', var header = '', String body = '', String ClientID = ''}) async {
    if (await internetConnectivity.connectionStatus)
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
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
        } else {
          if (response.statusCode == 400) {
            return response.body;
          } else {
            Get.snackbar("Error " + response.statusCode.toString(), "Internal server error",
                snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
          }
        }
      } catch (e) {
        Get.snackbar("Error ", e.toString(),
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
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
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        Get.snackbar("Error " + response.statusCode.toString(), "Internal server error",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error ", e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
    LoadingScreen.dismiss();
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

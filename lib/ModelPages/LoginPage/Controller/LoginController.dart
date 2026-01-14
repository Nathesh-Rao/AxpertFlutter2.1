import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/db/offline_db_module.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Models/SigninDetailsModel.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Page/LoginPage.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:platform_device_id/platform_device_id.dart';
// import 'package:platform_device_id_plus/platform_device_id.dart';

import '../../../Constants/Enums.dart';
import '../../../Constants/GlobalVariableController.dart';
import '../Models/AuthUserDetailsModel.dart';

class LoginController extends GetxController {
  GlobalVariableController globalVariableController = Get.find();
  // InternetConnectivity internetConnectivity = Get.find();
  var isOfflineLogin = false.obs;
  ServerConnections serverConnections = ServerConnections();
  // final googleLoginIn = GoogleSignIn();
  AppStorage appStorage = AppStorage();
  var rememberMe = false.obs;
  var googleSignInVisible = false.obs;
  var ddSelectedValue = "power".obs;
  var userTypeList = [].obs;
  var showPassword = true.obs;
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController otpFieldController = TextEditingController();
  final passwordFocus = FocusNode();
  var errUserName = ''.obs;
  var errPassword = ''.obs;
  var fcmId;
  var willBio_userAuthenticate = false.obs;
  var isBiometricAvailable = false.obs;
  var currentProjectName = ''.obs;
  var isUserDataLoading = false.obs;
  var isOtpLoading = false.obs;
  var isOTP_auth = false.obs;
  var isPWD_auth = false.obs;
  var otpChars = '4'.obs;
  var otpExpiryTime = '2'.obs;
  var authType = AuthType.none.obs;
  var otpMsg = ''.obs;
  var otpLoginKey = ''.obs;
  var otpErrorText = ''.obs;
  bool isDuplicate_session = false;
  bool isAxpertConnectEstablished = false;

  LoginController() {
    // fetchUserTypeList();

    fetchRememberedData();
    dropDownItemChanged(ddSelectedValue);
    if (userNameController.text.toString().trim() != "")
      rememberMe.value = true;

    setWillAuthenticate();

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) => fcmId = value);

    // 16_KB_AMR
    _initializeGoogleSignIn();
  }
  @override
  void onInit() {
    super.onInit();
    listenInternetState();
  }

  void listenInternetState() async {
    final InternetConnectivity net = Get.find<InternetConnectivity>();

    // Set initial value
    isOfflineLogin.value = !await net.check();

    // Listen to future changes
    ever<bool>(net.isConnected, (connected) {
      isOfflineLogin.value = !connected;
    });
  }

  setWillAuthenticate() async {
    await checkBiometricFlag();
    var willAuth = await getWillBiometricAuthenticateForThisUser(
        userNameController.text.toString().trim());
    print(("Login willAuth: $willAuth"));
    LogService.writeLog(
        message:
            "[i] LoginController\nScope: setWillAuthenticate()\nLogin willAuth: $willAuth");

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
      userTypeList
        ..sort((a, b) =>
            a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
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
    if (ddSelectedValue.value.toLowerCase() == "power" ||
        ddSelectedValue.value.isEmpty) {
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
    if (isPWD_auth.value) {
      if (userPasswordController.text.toString().trim() == "") {
        errPassword.value = "Password is required";
        return false;
      }
    }
    return true;
  }

  bool validateOTPField() {
    otpErrorText.value = "";
    print("OTP text length: ${otpFieldController.text.length}");
    if (otpFieldController.text.length < int.parse(otpChars.value)) {
      otpErrorText.value = "Enter full ${int.parse(otpChars.value)}-digit OTP'";
      print("Enter full ");
      return false;
    }
    return true;
  }

  getSignInBody() async {
    Map body = {
      "appname": globalVariableController.PROJECT_NAME.value,
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
    LogService.writeLog(
        message: "[i] LoginController\nSelected UserGroup : power");
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
          await appStorage.storeValue(
              AppStorage.TOKEN, json["result"]["token"].toString());
          await appStorage.storeValue(
              AppStorage.SESSIONID, json["result"]["sessionid"].toString());
          await appStorage.storeValue(
              AppStorage.USER_NAME, userNameController.text.trim());
          await appStorage.storeValue(AppStorage.USER_CHANGE_PASSWORD,
              json["result"]["ChangePassword"].toString());
          await appStorage.storeValue(
              AppStorage.NICK_NAME,
              json["result"]["NickName"].toString() ??
                  userNameController.text.trim());
          storeLastLoginData(body);
          print(
              "User_change_password: ${appStorage.retrieveValue(AppStorage.USER_CHANGE_PASSWORD)}");
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
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
      }
      LoadingScreen.dismiss();
    }
  }

  _initializeGoogleSignIn() async {
    await GoogleSignIn.instance.initialize();
    // GoogleSignIn.instance.authenticationEvents.listen((event) async {
    //   if (event is GoogleSignInAuthenticationEventSignIn) {
    //     // googleUser = event.user;

    //     // LoadingScreen.show();

    //     // LoadingScreen.dismiss();
    //   }

    //   if (event is GoogleSignInAuthenticationEventSignOut) {
    //     await FirebaseAuth.instance.signOut();
    //     update(['google_signin']);
    //   }
    // });
  }

  void googleSignInClicked() async {
    LogService.writeLog(
        message:
            "[-] LoginController\nScope: googleSignInClicked() : GoogleLogin Started");

    try {
      //16_KB_AMR

      if (GoogleSignIn.instance.supportsAuthenticate()) {
        final googleUser =
            await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
        LoadingScreen.show();
        // final credential = GoogleAuthProvider.credential(
        //   accessToken: googleAuth.accessToken,
        //   idToken: googleAuth.idToken,
        // );

        // await FirebaseAuth.instance.signInWithCredential(credential);
        final googleAuth = await googleUser.authentication;
        final googleAuthorization = await googleUser.authorizationClient
            .authorizationForScopes(["email"]);
        final accessToken = await googleAuthorization?.accessToken;
        final idToken = googleAuth.idToken;

        final credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        Map body = {
          'appname': globalVariableController.PROJECT_NAME.value,
          'userid': googleUser.email.toString(),
          'userGroup': "power",
          // 'userGroup': ddSelectedValue.value.toString(),
          'ssoType': 'Google',
          'ssodetails': {
            'id': googleUser.id,
            'token': googleAuthorization?.accessToken.toString(),
          },
        };

        var url = Const.getFullARMUrl(ServerConnections.API_GOOGLESIGNIN_SSO);
        var resp = await serverConnections.postToServer(
            url: url, body: jsonEncode(body));

        if (resp != "") {
          var jsonResp = jsonDecode(resp);
          // print(jsonResp);
          if (jsonResp['result']['success'].toString() == "false") {
            Get.snackbar("Alert!", jsonResp['result']['message'].toString(),
                snackPosition: SnackPosition.BOTTOM,
                colorText: Colors.white,
                backgroundColor: Colors.red);
          } else {
            await appStorage.storeValue(
                AppStorage.TOKEN, jsonResp["result"]["token"].toString());
            await appStorage.storeValue(AppStorage.SESSIONID,
                jsonResp["result"]["sessionid"].toString());
            await appStorage.storeValue(
                AppStorage.USER_NAME, googleUser.email.toString());
            //remove rememberer data
            // appStorage.remove(AppStorage.USERID);
            // appStorage.remove(AppStorage.USER_PASSWORD);
            // appStorage.remove(AppStorage.USER_GROUP);
            dontRememberCredentials();
            await _processLoginAndGoToHomePage();
          }
        } else {
          Get.snackbar("Error", "Some Error occured",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
        LoadingScreen.dismiss();
        // print(resp);
        // print(googleUser);
      } else {
        LogService.writeLog(
            message:
                "[ERROR] LoginController\nScope: googleSignInClicked() : Does not support Authenticate");
      }
    } catch (e) {
      LogService.writeLog(
          message:
              "[ERROR] LoginController\nScope: googleSignInClicked()\nError: $e");

      Get.snackbar("Error", "User is not Registered!",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  _processLoginAndGoToHomePage() async {
    //mobile Notification
    await _callApiForMobileNotification();
    //connect to Axpert
    // await _callApiForConnectToAxpert();
    // Get.offAllNamed(Routes.LandingPage);
    //
    //burnur code for navigating to ess portal - amrith--->
    if (isPortalDefault.value) {
      Get.offAllNamed(Routes.LandingPage);
    } else {
      Get.offAllNamed(Routes.EssHomePage);
    } //------------------------------------------------>
  }

  Future<void> callApiForConnectToAxpert() async {
    var connectBody = {
      'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)
    };
    var cUrl = Const.getFullARMUrl(ServerConnections.API_CONNECTTOAXPERT);
    var connectResp = await serverConnections.postToServer(
        url: cUrl, body: jsonEncode(connectBody), isBearer: true);
    print(connectResp);
    // getArmMenu

    var jsonResp = jsonDecode(connectResp);
    if (jsonResp != "") {
      if (jsonResp['result']['success'].toString() == "true") {
        print("callApiForConnectToAxpert: ${jsonResp.toString()}");
        isAxpertConnectEstablished = true;
        // Get.offAllNamed(Routes.LandingPage);
      } else {
        var message = jsonResp['result']['message'].toString();
        showErrorSnack(title: "Error - Connect To Axpert", message: message);
      }
    } else {
      showErrorSnack();
    }
  }

//
  _callApiForMobileNotification() async {
    var imei = '';
    // var imei = await PlatformDeviceId.getDeviceId ?? '0';

    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = defaultTargetPlatform == TargetPlatform.android
        ? await deviceInfoPlugin.androidInfo
        : defaultTargetPlatform == TargetPlatform.iOS
            ? await deviceInfoPlugin.iosInfo
            : null;
    if (deviceInfo == null) {
      Const.DEVICE_ID = '';
    } else {
      final allInfo = deviceInfo.data;
      imei = allInfo['id'];
    }
    LogService.writeLog(message: "[i] IMEI : $imei");
    var connectBody = {
      'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
      'firebaseId': fcmId ?? "0",
      'ImeiNo': imei,
    };
    var cUrl = Const.getFullARMUrl(ServerConnections.API_MOBILE_NOTIFICATION);
    var connectResp = await serverConnections.postToServer(
        url: cUrl, body: jsonEncode(connectBody), isBearer: true);
    print("Mobile: " + connectResp);
  }

  getVersionName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    var version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    Const.APP_VERSION = version; //+ "." + Const.APP_RELEASE_ID;
    return Const.APP_VERSION;
  }

  void rememberCredentials() {
    int count = 1;
    try {
      count++;
      var users = appStorage.retrieveValue(AppStorage.USERID) ?? {};
      users[globalVariableController.PROJECT_NAME.value] =
          userNameController.text.trim();
      appStorage.storeValue(AppStorage.USERID, users);

      var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
      passes[globalVariableController.PROJECT_NAME.value] =
          userPasswordController.text;
      appStorage.storeValue(AppStorage.USER_PASSWORD, passes);

      var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
      groups[globalVariableController.PROJECT_NAME.value] =
          ddSelectedValue.value;
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
    users.remove(globalVariableController.PROJECT_NAME.value);
    appStorage.storeValue(AppStorage.USERID, users);

    var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
    passes.remove(globalVariableController.PROJECT_NAME.value);
    appStorage.storeValue(AppStorage.USER_PASSWORD, passes);

    var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
    groups.remove(globalVariableController.PROJECT_NAME.value);
    appStorage.storeValue(AppStorage.USER_GROUP, groups);
  }

  Future<void> fetchRememberedData() async {
    try {
      var users = appStorage.retrieveValue(AppStorage.USERID) ?? {};
      print(users);
      userNameController.text =
          users[globalVariableController.PROJECT_NAME.value].trim() ?? "";

      var passes = appStorage.retrieveValue(AppStorage.USER_PASSWORD) ?? {};
      userPasswordController.text =
          passes[globalVariableController.PROJECT_NAME.value] ?? "";

      var groups = appStorage.retrieveValue(AppStorage.USER_GROUP) ?? {};
      ddSelectedValue.value =
          groups[globalVariableController.PROJECT_NAME.value] ?? "Power";
    } catch (e) {
      // appStorage.remove(AppStorage.USERID);
      // appStorage.remove(AppStorage.USER_PASSWORD);
      // appStorage.remove(AppStorage.USER_GROUP);
    }
  }

  void displayAuthenticationDialog() async {
    LogService.writeLog(
        message:
            "[^] LoginController\nScope: displayAuthenticationDialog()\n Fingerprint Clicked");

    if (willBio_userAuthenticate == true) {
      try {
        if (await showBiometricDialog()) {
          loginButtonClicked(bodyArgs: retrieveLastLoginData());
        }
      } catch (e) {
        print(e.toString());
        if (e.toString().contains('NotAvailable') &&
            e.toString().contains('Authentication failure'))
          showErrorSnack(title: "Oops!", message: "Only Biometric is allowed.");
      }
    } else {
      print("willAuthenticate => $willBio_userAuthenticate");
    }
  }

  void storeLastLoginData(body) {
    AppStorage appStorage = AppStorage();
    var projectName = globalVariableController.PROJECT_NAME.value;
    Map lastData = appStorage.retrieveValue(AppStorage.LAST_LOGIN_DATA) ?? {};
    lastData[projectName] = body;
    appStorage.storeValue(AppStorage.LAST_LOGIN_DATA, lastData);
  }

  retrieveLastLoginData() {
    AppStorage appStorage = AppStorage();
    var projectName = globalVariableController.PROJECT_NAME.value;
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
    var baseUrl = globalVariableController.ARM_URL.trim();
    baseUrl += baseUrl.endsWith("/") ? "" : "/";
    var url = baseUrl + ServerConnections.API_GET_SIGNINDETAILS;
    var body = "{\"appname\":\"" +
        globalVariableController.PROJECT_NAME.value.trim() +
        "\"}";
    final response = await serverConnections.postToServer(url: url, body: body);

    if (response != "") {
      var json = jsonDecode(response);
      if (json["result"]["success"].toString().toLowerCase() == "true") {
        final signinDetails =
            SigninDetailsModel.fromJson(json["result"]["data"]);
        isBiometricAvailable.value = signinDetails.enablefingerprint!;
      } else {
        isBiometricAvailable.value = false;
      }
    }
  }

//// New Login Flow Methods and vars
  onLoad() async {
    currentProjectName.value =
        await appStorage.retrieveValue(AppStorage.PROJECT_NAME) ?? '';

    // initializeLoginPage();
  }

  startLoginProcess() async {
    if (isOfflineLogin.value) {
      startLoginProcessOffline();
    } else {
      authType.value = await getLoginUserDetailsAndAuthType();

      if (authType.value == AuthType.otpOnly) {
        await callSignInAPI();
      }

      if (isPWD_auth.value) {
        FocusScope.of(Get.context!).requestFocus(passwordFocus);
      }

      switch (authType.value) {
        case AuthType.both:
          print("✅ Both Password and OTP authentication are required.");
          break;
        case AuthType.passwordOnly:
          print("🔐 Only Password authentication is required.");
          break;
        case AuthType.otpOnly:
          print("📲 Only OTP authentication is required.");
          break;
        case AuthType.none:
          print("❌ No authentication required.");
          break;
      }
    }
  }

  startLoginProcessOffline() async {
    if (!validateForm()) return;
    isUserDataLoading.value = true;
    var isUserAvailable = await OfflineDbModule.hasOfflineUser(
        projectName: globalVariableController.PROJECT_NAME.value,
        username: userNameController.text.toString().trim());
    isUserDataLoading.value = false;

    if (isUserAvailable) {
      userPasswordController.text = '';
      authType.value = AuthType.passwordOnly;
      isPWD_auth.value = true;
      FocusScope.of(Get.context!).requestFocus(passwordFocus);
    } else {
      errUserName.value = "This account isn’t available offline.";
    }
    debugPrint("User Exist in offline => $isUserAvailable");
  }

  callSignInOffline() async {
    if (!validateForm()) return;
    isUserDataLoading.value = true;

    var isUserAuthenticated = await OfflineDbModule.validateOfflineLogin(
        projectName: globalVariableController.PROJECT_NAME.value,
        username: userNameController.text.toString().trim(),
        passwordHash: userPasswordController.text.toString().trim());

    isUserDataLoading.value = false;
    debugPrint("User Offline Authenticated? => $isUserAuthenticated");

    if (isUserAuthenticated) {
      Get.offAllNamed(Routes.LandingPage);
    } else {
      errPassword.value = "Incorrect Password";
    }
  }

  callSignInAPI() async {
    if (isOfflineLogin.value) {
      await callSignInOffline();
    } else if (validateForm()) {
      var signInBody = {
        "appname": globalVariableController.PROJECT_NAME.value,
        "username": userNameController.text.toString().trim(),
        "password": generateMd5(userPasswordController.text.toString().trim()),
        "Language": "English",
        "SessionId": getGUID(), //GUID
        "Globalvars": false
      };

      signInBody.addIf(isDuplicate_session, "ClearPreviousSession", true);

      // signInBody.addIf(isPWD_auth.value, "password", generateMd5(userPasswordController.text.toString().trim()));
      signInBody.addIf(isOTP_auth.value, "OtpAuth", "T");
      FocusManager.instance.primaryFocus?.unfocus();
      LoadingScreen.show();
      var _url = Const.getFullARMUrl(ServerConnections.API_SIGNIN);

      var response = await serverConnections.postToServer(
          url: _url, body: jsonEncode(signInBody));
      // LogService.writeLog(message: "[-] LoginController => loginButtonClicked() => LoginResponse : $response");

      if (response != "") {
        var json = jsonDecode(response);
        if (json["result"]["success"].toString().toLowerCase() == "true") {
          if (json["result"]["message"].toString() == "Login Successful.") {
            await OfflineDbModule.saveUser(
                projectName: globalVariableController.PROJECT_NAME.value,
                username: userNameController.text.toString().trim(),
                passwordHash: userPasswordController.text.toString().trim(),
                loginResult: json);
            await processSignInDataResponse(json["result"]);
          } else if (json["result"]?.containsKey("OTPLoginKey")) {
            // OTPPage
            otpMsg.value = json["result"]["message"].toString();
            otpLoginKey.value = json["result"]["OTPLoginKey"].toString();
            print("Otpmsg: ${otpMsg.value} \nOtpkey: ${otpLoginKey.value}");
            Get.toNamed(Routes.OtpPage);
          }
        } else if (json["result"]["success"].toString().toLowerCase() ==
                "false" &&
            json["result"].containsKey('duplicate_session')) {
          isDuplicate_session = true;
          showDialog_duplicateSession(json["result"]["message"].toString());
        } else {
          if (Get.isDialogOpen ?? false) {
            Get.back(); // closes the dialog
          }
          Get.snackbar("Error ", json["result"]["message"],
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white);
        }
      }
      LoadingScreen.dismiss();
    }
  }

  getLoginUserDetailsAndAuthType() async {
    isUserDataLoading.value = true;
    var _url = Const.getFullARMUrl(ServerConnections.API_GET_LOGINUSER_DETAILS);
    var body = {
      "appname": globalVariableController.PROJECT_NAME.value,
      "UserName": userNameController.text.toString().trim(),
    };

    var response =
        await serverConnections.postToServer(url: _url, body: jsonEncode(body));
    isUserDataLoading.value = false;
    if (response != "") {
      var json = jsonDecode(response);
      if (json["result"]["success"].toString().toLowerCase() == "true") {
        FocusManager.instance.primaryFocus?.unfocus();
        final authUserdetails = AuthUserDetailsModel.fromJson(json["result"]);
        isPWD_auth.value = authUserdetails.pwdauth!;
        if (authUserdetails.otpauth!) {
          isOTP_auth.value = authUserdetails.otpauth!;
          otpChars.value = authUserdetails.otpsettings!.otpchars!;
          otpExpiryTime.value = authUserdetails.otpsettings!.otpexpiry!;
        }

        if (isPWD_auth.value && isOTP_auth.value) return AuthType.both;
        if (isPWD_auth.value) return AuthType.passwordOnly;
        if (isOTP_auth.value) return AuthType.otpOnly;
      } else {
        Get.snackbar("Error ", json["result"]["message"],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    }

    return AuthType.none;
  }

  callVerifyOTP() async {
    if (validateOTPField()) {
      LoadingScreen.show();
      isOtpLoading.value = true;
      var _url = Const.getFullARMUrl(ServerConnections.API_VALIDATE_OTP);
      var body = {
        "OtpLoginKey": otpLoginKey.value,
        "OTP": otpFieldController.text.toString().trim(),
      };

      var response = await serverConnections.postToServer(
          url: _url, body: jsonEncode(body));
      isOtpLoading.value = false;
      if (response != "") {
        var json = jsonDecode(response);
        if (json["result"]["success"].toString().toLowerCase() == "true") {
          await processSignInDataResponse(json["result"]);
        } else {
          otpErrorText.value = json["result"]["message"].toString();
          /* Get.snackbar("Error ", json["result"]["message"],
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);*/
        }
      }
    }
    LoadingScreen.dismiss();
  }

  processSignInDataResponse(json) async {
    await appStorage.storeValue(AppStorage.TOKEN, json["token"].toString());
    await appStorage.storeValue(
        AppStorage.SESSIONID, json["ARMSessionId"].toString());
    await appStorage.storeValue(
        AppStorage.USER_NAME, userNameController.text.trim());
    //await appStorage.storeValue(AppStorage.USER_CHANGE_PASSWORD, json["result"]["ChangePassword"].toString());
    await appStorage.storeValue(AppStorage.NICK_NAME,
        json["nickname"].toString() ?? userNameController.text.trim());
    //storeLastLoginData(_body);
    //print("User_change_password: ${appStorage.retrieveValue(AppStorage.USER_CHANGE_PASSWORD)}");
    LogService.writeLog(
        message:
            "[-] LoginController\nScope:SignInResponse()\nUser_change_password: ${appStorage.retrieveValue(AppStorage.USER_CHANGE_PASSWORD)}");

    //Save Data
    if (rememberMe.value) {
      rememberCredentials();
    } else {
      dontRememberCredentials();
    }
    await _processLoginAndGoToHomePage();
  }

  callResendOTP() async {
    otpErrorText.value = '';
    otpFieldController.clear();
    isOtpLoading.value = true;
    var _url = Const.getFullARMUrl(ServerConnections.API_RESEND_OTP);
    var body = {"OtpLoginKey": otpLoginKey.value};

    var response =
        await serverConnections.postToServer(url: _url, body: jsonEncode(body));
    isOtpLoading.value = false;
    if (response != "") {
      var json = jsonDecode(response);
      if (json["result"]["success"].toString().toLowerCase() == "true") {
        Get.snackbar("Success", json["result"]["message"],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      } else {
        otpErrorText.value = json["result"]["message"].toString();
        /* Get.snackbar("Error ", json["result"]["message"],
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);*/
      }
    }
  }

  void showDialog_duplicateSession(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "Duplicate Session",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MyColors.blue2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      //foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.offAll(LoginPage());
                    },
                    child: const Text("No"),
                  ),

                  // Confirm button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.blue2,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () async {
                      callSignInAPI();
                    },
                    child: const Text("Yes"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    /* Get.defaultDialog(
              barrierDismissible: false,
              titleStyle: TextStyle(color: MyColors.blue2),
              titlePadding: EdgeInsets.only(top: 20,),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              title: "Duplicate Session",
              middleText: json["result"]["message"].toString(),
              confirm: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                  },
                  child: Text("Yes")),
              cancel: ElevatedButton(
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.grey)),
                  onPressed: () {
                    Get.offAll(LoginPage());
                    Get.back();
                  },
                  child: Text("No")));*/
  }
}

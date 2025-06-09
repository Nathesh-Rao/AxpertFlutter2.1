import 'dart:async';
import 'dart:io';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/VersionUpdateClearOldData.dart';
import 'package:axpertflutter/Constants/Const.dart';

import 'package:axpertflutter/ModelPages/ProjectListing/Model/ProjectModel.dart';
import 'package:axpertflutter/ModelPages/location_permission.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../Utils/ServerConnections/ServerConnections.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  var _animationController;
  AppStorage appStorage = AppStorage();
  ProjectModel? projectModel;

  @override
  void initState() {
    LogService.writeLog(message: "[>] SplashPage");
    // LogService.writeOnConsole(message: "[>] SplashPage");
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _animationController.forward();
    VersionUpdateClearOldData.clearAllOldData();
    checkIfDeviceSupportBiometric();
    //

//
    Future.delayed(Duration(milliseconds: 1800), () {
      _animationController.stop();

      var cached = appStorage.retrieveValue(AppStorage.CACHED);

      try {
        if (cached == null)
          Get.offAllNamed(Routes.ProjectListingPage);
        else {
          var jsonProject = appStorage.retrieveValue(cached);
          projectModel = ProjectModel.fromJson(jsonProject);
          Const.PROJECT_NAME = projectModel!.projectname;
          Const.PROJECT_URL = projectModel!.web_url;
          Const.ARM_URL = projectModel!.arm_url;
          LogService.writeOnConsole(message: " splash-page projectModel => $jsonProject");
          Get.offAllNamed(Routes.Login);
        }
      } catch (e) {
        LogService.writeLog(message: "[ERROR] \nPage: SplashPage\nScope: initState()\nError: $e");
        LogService.writeOnConsole(message: "[ERROR] \nPage: SplashPage\nScope: initState()\nError: $e");
        Get.offAllNamed(Routes.ProjectListingPage);
      }
    });
  }

  _askLocationPermission() async {
    if (Platform.isAndroid) {
      var permission = await Permission.locationAlways.request();

      // print("Location Permission: ${permission}");
      LogService.writeLog(message: "[i] SplashPage \nScope: askLocationPermission() : $permission ");
      if (permission != PermissionStatus.granted) {
        Get.to(RequestLocationPage());
      }
    }
    if (Platform.isIOS) {
      await Geolocator.requestPermission();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _askLocationPermission();
      // await ensureLocalNetworkPermission();
    });

    return Scaffold(
      // color: Colors.red,
      body: Stack(
        children: [
          Center(
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
              child: Container(
                height: 80,
                width: 80,
                child: Image.asset(
                  'assets/images/agilelabs-app-icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: Padding(
          //     padding: EdgeInsets.only(right: 20, bottom: 20),
          //     child: Text("Version: "),
          //   ),
          // )
        ],
      ),
    );
  }

  void checkIfDeviceSupportBiometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    LogService.writeOnConsole(message: "canAuthenticate: $canAuthenticate");
    LogService.writeLog(message: "[i] SplashPage\nScope:checkIfDeviceSupportBiometric()\nCanAuthenticate: $canAuthenticate");
    if (canAuthenticate) {
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      LogService.writeOnConsole(message: "List: $availableBiometrics");
      LogService.writeLog(
          message: "[i] SplashPage\nScope:checkIfDeviceSupportBiometric()\nAvailable Biometrics: $availableBiometrics");

      // if (availableBiometrics.contains (BiometricType.fingerprint) ||
      //     availableBiometrics.contains(BiometricType.weak) ||
      //     availableBiometrics.contains(BiometricType.strong))
      if (availableBiometrics.isNotEmpty) {
        AppStorage().storeValue(AppStorage.CAN_AUTHENTICATE, canAuthenticate);
      } else {
        AppStorage().remove(AppStorage.CAN_AUTHENTICATE);
      }
    }
  }
}

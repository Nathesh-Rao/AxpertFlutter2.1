import 'dart:async';
import 'dart:io';

import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/Services/LocationServiceManager/LocationServiceManager.dart';
import 'package:axpertflutter/Utils/FirebaseHandler/FirebaseMessagesHandler.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:axpertflutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:platform_device_id/platform_device_id.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails('Default', 'Default',
        icon: "@mipmap/ic_launcher",
        channelDescription: 'Default Notification',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker'));
var hasNotificationPermission = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CommonMethods.requestLocationPermission();
  await GetStorage.init();
  await FlutterDownloader.initialize(debug: true);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initialize();
  initLocationService();
  LogService.initLogs();
  await FirebaseMessaging.onMessage.listen(onMessageListener);
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessageListner);
  await FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenAppListener);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  configureEasyLoading();
  // configureLogging();
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.black38));
  try {
    Const.DEVICE_ID = await PlatformDeviceId.getDeviceId ?? "00";
  } on PlatformException {}
}

void configureEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..progressColor = Colors.red
    ..indicatorColor = MyColors.blue2
    ..textColor = MyColors.blue2
    ..backgroundColor = Colors.white
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 55.0
    ..radius = 20.0;
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final InternetConnectivity internetConnectivity = Get.put(InternetConnectivity());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LogService.writeLog(message: "[>] App initialized");
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Axpert Flutter',
      darkTheme: Const.THEMEDATA,
      themeMode: ThemeMode.light,
      theme: Const.THEMEDATA,
      initialRoute: Routes.SplashScreen,

      // initialRoute: Routes.SettingsPage,
      getPages: RoutePages.pages,
      // builder: EasyLoading.init(),
      builder: EasyLoading.init(
        builder: (context, child) {
          ErrorWidget.builder = (errorDetails) => Scaffold(
                body: Center(
                  child: InkWell(
                      onTap: () => Get.toNamed(Routes.ProjectListingPage),
                      child: Text("Some Error occurred. \n ${errorDetails.exception.toString()}")),
                ),
              );
          if (child != null) return child;
          throw StateError('widget is null');
        },
      ),
    );
  }
}

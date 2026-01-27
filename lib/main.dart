import 'dart:async';
import 'dart:io';

import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/db/offline_db_module.dart';
import 'package:axpertflutter/Services/LocationServiceManager/LocationServiceManager.dart';
import 'package:axpertflutter/Utils/FirebaseHandler/FirebaseMessagesHandler.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:axpertflutter/Utils/Utility/initial_bindings.dart';
import 'package:axpertflutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_local_network_ios/flutter_local_network_ios.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:platform_device_id_plus/platform_device_id.dart';
// import 'package:platform_device_id/platform_device_id.dart';
import 'package:device_info_plus/device_info_plus.dart';

void testAssets() async {
  try {
    final s = await rootBundle.loadString('AssetManifest.json');
    print("ASSET MANIFEST LENGTH = ${s.length}");
  } catch (e) {
    print("ASSET SYSTEM BROKEN: $e");
  }
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
  LogService.writeOnConsole(message: "Main method started.......");
  await CommonMethods.requestLocationPermission();
  await GetStorage.init();
  await FlutterDownloader.initialize(debug: true);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await initPlatformState();
  //
  // await fetchData();
  //

  await triggerLocalNetworkPrompt();
  await Future.delayed(Duration(seconds: 1));
  //
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
  try {
    await OfflineDbModule.init();
    LogService.writeLog(
      message: "[OFFLINE_DB_INIT_001][SUCCESS] Offline DB initialized",
    );
  } catch (e, st) {
    LogService.writeLog(
      message: "[OFFLINE_DB_INIT_001][FAILED] Offline DB init failed => $e",
    );
    LogService.writeLog(message: "[OFFLINE_DB_INIT_001][STACK] $st");
  }
  // GoogleFonts.config.allowRuntimeFetching = false;
  testAssets();
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black38));
  try {
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
      Const.DEVICE_ID = allInfo['id'];
    }
    // Const.DEVICE_ID = await PlatformDeviceId.getDeviceId ?? "00";
  } on PlatformException {}
}

// Future<void> initPlatformState() async {
//   final _flutterLocalNetworkIosPlugin = FlutterLocalNetworkIos();
//   bool? result = await _flutterLocalNetworkIosPlugin.requestAuthorization();
//   print("result  $result");
// }

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

@pragma('vm:entry-point')
Future<void> triggerLocalNetworkPrompt() async {
  try {
    var url = "192.168.1.1";
    // var url = "google.com";
    var addrss = await InternetAddress.lookup(url);
    LogService.writeLog(
        message: "triggerLocalNetworkPrompt()=> addrss => $addrss");
    // print("triggerLocalNetworkPrompt()=> addrss => $addrss");
    await Future.delayed(Duration(seconds: 3));
  } catch (e) {
    LogService.writeLog(
        message:
            "triggerLocalNetworkPrompt()=> Local network prompt triggered err => : $e");
    // print("triggerLocalNetworkPrompt()=> Local network prompt triggered err => : $e");
  }
}

Future<void> fetchData() async {
  try {
    var url = "192.168.1.1";
    final response = await http.get(Uri.parse(url));
    LogService.writeLog(
        message: "fetchData()=> url=> $url\n response => ${response.body}");

    // handle response
  } catch (e) {
    if (e is SocketException) {
      await Future.delayed(Duration(seconds: 2));
      LogService.writeLog(message: "fetchData() triggered err 1 => : $e");
      // Retry once
      // final response = await http.get(Uri.parse("http://192.168.1.1"));
    }
    LogService.writeLog(message: "fetchData() triggered err 2 => : $e");
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final InternetConnectivity internetConnectivity =
      Get.put(InternetConnectivity());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LogService.writeLog(message: "[>] App initialized");
      // LogService.writeOnConsole(message: "[>] App initialized");
    });

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Axpert Flutter',
      darkTheme: Const.THEMEDATA,
      themeMode: ThemeMode.light,
      theme: Const.THEMEDATA,
      initialRoute: Routes.SplashScreen,
      initialBinding: InitialBindings(),
      // initialRoute: Routes.SettingsPage,
      getPages: RoutePages.pages,
      // builder: EasyLoading.init(),
      builder: EasyLoading.init(
        builder: (context, child) {
          ErrorWidget.builder = (errorDetails) => Scaffold(
                body: Center(
                  child: InkWell(
                      onTap: () => Get.toNamed(Routes.ProjectListingPage),
                      child: Text(
                          "Some Error occurred. \n ${errorDetails.exception.toString()}")),
                ),
              );
          if (child != null) return child;
          throw StateError('widget is null');
        },
      ),
    );
  }
}

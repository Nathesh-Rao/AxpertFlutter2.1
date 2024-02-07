import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Models/FirebaseMessageModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:axpertflutter/firebase_options.dart';
import 'package:background_location/background_location.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_device_id/platform_device_id.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails('Default', 'Default',
        channelDescription: 'Default Notification', importance: Importance.max, priority: Priority.high, ticker: 'ticker'));
var hasNotificationPermission = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  handleNotification();
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  configureEasyLoading();
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
  InternetConnectivity internetConnectivity = Get.put(InternetConnectivity());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Axpert Flutter 2.1',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
        elevatedButtonTheme:
            ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(MyColors.blue2))),
        primaryColor: Color(0xff003AA5),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.indigo),
      ),
      initialRoute: Routes.SplashScreen,
      // initialRoute: Routes.LandingPage,
      getPages: RoutePages.pages,
      builder: EasyLoading.init(),
    );
  }
}

handleNotification() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  if (Platform.isAndroid) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
  }
  NotificationSettings settings = await messaging.requestPermission(
      alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    hasNotificationPermission = true;
  } else
    hasNotificationPermission = false;

  AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

  var fcmID = await messaging.getToken();
  print("FCMID: $fcmID");
  await FirebaseMessaging.onMessage.listen(onMessageListener);
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessageListener);
  await FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenAppListener);
}

onMessageListener(RemoteMessage message) async {
  print("Message Received:" + message.data.toString());
  FirebaseMessageModel data;
  try {
    data = jsonDecode(message.data.toString());
  } catch (e) {
    data = FirebaseMessageModel("Axpert", "You have received a new notification");
  }
  if (hasNotificationPermission) {
    try {
      await flutterLocalNotificationsPlugin.show(0, data.title ?? "", data.body ?? "", notificationDetails, payload: 'item x');
    } catch (e) {}
  }

  //save message
  AppStorage appStorage = AppStorage();
  var messageList = [];
  messageList.add(jsonEncode(message.data));
  messageList.addAll(appStorage.retrieveValue(AppStorage.NOTIFICATION_LIST) ?? []);
  var notNo = appStorage.retrieveValue(AppStorage.NOTIFICATION_UNREAD) ?? "0";
  notNo = int.parse(notNo) + 1;
  appStorage.storeValue(AppStorage.NOTIFICATION_UNREAD, notNo.toString());
  appStorage.storeValue(AppStorage.NOTIFICATION_LIST, messageList);
  try {
    LandingPageController landingPageController = Get.find();
    landingPageController.needRefreshNotification.value = true;
    landingPageController.notificationPageRefresh.value = true;
    landingPageController.showBadge.value = true;
    landingPageController.badgeCount.value = notNo;
  } catch (e) {}
}

onMessageOpenAppListener(RemoteMessage message) {
  print("Opened in android");
  try {
    Get.toNamed(Routes.NotificationPage);
  } catch (e) {}
}

void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  print("Opened in iOS");
  try {
    Get.toNamed(Routes.NotificationPage);
  } catch (e) {}
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessageListener(RemoteMessage message) async {
  // await Firebase.initializeApp();
  // onMessageListener(message);
  // BackgroundLocation.setAndroidNotification(
  //   title: "Location In Use",
  //   message: "Using",
  //   icon: "@mipmap/ic_launcher",
  // );
  // print("Hit: ");
  // //do it after login
  // await BackgroundLocation.startLocationService(forceAndroidLocationManager: true);
  // await BackgroundLocation.getLocationUpdates((location) {
  //   print(location);
  // });
  // //Do it before logout
  // await BackgroundLocation.stopLocationService();
}

onDidReceiveLocalNotification(id, title, body, payload) {}

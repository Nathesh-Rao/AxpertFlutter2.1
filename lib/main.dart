import 'dart:async';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:axpertflutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:platform_device_id/platform_device_id.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0;
}

// ignore: must_be_immutable
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

//   DateTime currentBackPressTime = DateTime.now();
//
//   Future<bool> onWillPop() {
//     DateTime now = DateTime.now();
//     if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
//       currentBackPressTime = now;
//       print('single exit');
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Press back again to exit'),
//       ));
//       return Future.value(false);
//     } else {
//       print('exit');
//       SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
//       exit(0);
//     }
//   }
// }
//
// class JsonFile {
//   JsonFile({
//     required this.type,
//     required this.title,
//     required this.subtitle,
//     required this.icon1,
//     required this.icon2,
//     required this.button1,
//     required this.button2,
//     required this.icon3,
//     required this.icon4,
//     required this.icon5,
//     required this.icon6,
//     required this.icon7,
//     required this.text,
//     required this.text1,
//     required this.value,
//   });
//
//   late final String type;
//   late final String title;
//   late final String subtitle;
//   late final String icon1;
//   late final String icon2;
//   late final String button1;
//   late final String button2;
//   late final String icon3;
//   late final String icon4;
//   late final String icon5;
//   late final String icon6;
//   late final String icon7;
//   late final String text;
//   late final String text1;
//   late final List<Value> value;
//
//   JsonFile.fromJson(Map<String, dynamic> json) {
//     type = json['type'];
//     title = json['title'];
//     subtitle = json['subtitle'];
//     icon1 = json['icon1'];
//     icon2 = json['icon2'];
//     button1 = json['button1'];
//     button2 = json['button2'];
//     icon3 = json['icon3'];
//     icon4 = json['icon4'];
//     icon5 = json['icon5'];
//     icon6 = json['icon6'];
//     icon7 = json['icon7'];
//     text = json['text'];
//     text1 = json['text1'];
//     value = List.from(json['value']).map((e) => Value.fromJson(e)).toList();
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['type'] = type;
//     _data['title'] = title;
//     _data['subtitle'] = subtitle;
//     _data['icon1'] = icon1;
//     _data['icon2'] = icon2;
//     _data['button1'] = button1;
//     _data['button2'] = button2;
//     _data['icon3'] = icon3;
//     _data['icon4'] = icon4;
//     _data['icon5'] = icon5;
//     _data['icon6'] = icon6;
//     _data['icon7'] = icon7;
//     _data['text'] = text;
//     _data['text1'] = text1;
//     _data['value'] = value.map((e) => e.toJson()).toList();
//     return _data;
//   }
// }
//
// class Value {
//   Value({
//     required this.title,
//     required this.imageurl,
//     required this.fields,
//   });
//
//   late final String title;
//   late final String imageurl;
//   late final List<Fields> fields;
//
//   Value.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     imageurl = json['imageurl'];
//     fields = List.from(json['fields']).map((e) => Fields.fromJson(e)).toList();
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['title'] = title;
//     _data['imageurl'] = imageurl;
//     _data['fields'] = fields.map((e) => e.toJson()).toList();
//     return _data;
//   }
// }
//
// class Fields {
//   Fields({
//     required this.type,
//     required this.key,
//     required this.placeholder,
//     required this.value,
//     required this.required,
//     required this.items,
//   });
//
//   late final String type;
//   late final String key;
//   late final String placeholder;
//   late final String value;
//   late final bool required;
//   late final List<String> items;
//
//   Fields.fromJson(Map<String, dynamic> json) {
//     type = json['type'] ?? "";
//     key = json['key'] ?? "";
//     placeholder = json['placeholder'] ?? "";
//     value = json['value'] ?? "";
//     required = json['required'] ?? true;
//     items = List.castFrom<dynamic, String>(json['items'] ?? [""]);
//   }
//
//   Map<String, dynamic> toJson() {
//     final _data = <String, dynamic>{};
//     _data['type'] = type;
//     _data['key'] = key;
//     _data['placeholder'] = placeholder;
//     _data['value'] = value;
//     _data['required'] = required;
//     _data['items'] = items;
//     return _data;
//   }
// }

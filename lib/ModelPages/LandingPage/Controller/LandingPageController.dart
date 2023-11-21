import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/page/WebViewActiveList.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Page/MenuActiveListPage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuCalendarPage/Page/MenuCalendarPage.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/page/WebViewCalendar.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuDashboardPage/Page/MenuDashboardPage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Page/MenuHomePage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Page/MenuMorePage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Models/FirebaseMessageModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetNotification.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LandingPageController extends GetxController {
  TextEditingController userCtrl = TextEditingController();
  TextEditingController oPassCtrl = TextEditingController();
  TextEditingController nPassCtrl = TextEditingController();
  TextEditingController cnPassCtrl = TextEditingController();
  var errOPass = ''.obs;
  var errNPass = ''.obs;
  var errCNPass = ''.obs;
  var showOldPass = false.obs;
  var showNewPass = false.obs;
  var showConNewPass = false.obs;
  var userName = 'Demo'.obs; //update with user name
  var bottomIndex = 0.obs;
  var carouselIndex = 0.obs;
  var needRefreshNotification = false.obs;
  var notificationPageRefresh = false.obs;
  var showBadge = false.obs;
  var badgeCount = 0.obs;
  var fool = false.obs;
  final CarouselController carouselController = CarouselController();

  DateTime currentBackPressTime = DateTime.now();

  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  var pageList = [
    MenuHomePage(),
    WebViewActiveList(),
    // MenuActiveListPage(),
    MenuDashboardPage(),
    // MenuCalendarPage(),
    WebViewCalendar(),
    MenuMorePage(),
  ];
  var list = [
    WidgetNotification(FirebaseMessageModel("Title 1", "Body 1")),
    // WidgetNotification(FirebaseMessageModel("Title 2", "Body 2")),
    // WidgetNotification(FirebaseMessageModel("Title 3", "Body 3")),
    // WidgetNotification(FirebaseMessageModel("Title 4", "Body 4")),
    // WidgetNotification(FirebaseMessageModel("Title 5", "Body 5")),
  ];
  get getPage => pageList[bottomIndex.value];

  LandingPageController() {
    userName.value = appStorage.retrieveValue(AppStorage.USER_NAME) ?? userName.value;
    userCtrl.text = userName.value;
  }

  indexChange(value) {
    MenuHomePageController menuHomePageController = Get.find();
    menuHomePageController.switchPage.value = false;
    deleteController(bottomIndex.value, value);
    bottomIndex.value = value;
  }

  showNotificationIconPressed() {}

  Future<bool> onWillPop() {
    try {
      MenuHomePageController menuHomePageController = Get.find();
      if (menuHomePageController.switchPage.value == true) {
        menuHomePageController.switchPage.toggle();
        return Future.value(false);
      }
    } catch (e) {}
    DateTime now = DateTime.now();
    if (bottomIndex.value != 0) {
      bottomIndex.value = 0;
      return Future.value(false);
    }
    if (now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Get.snackbar("Press back again to exit", "",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          isDismissible: true,
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM);
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void showNotifications() {
    showBadge.value = false;
    appStorage.storeValue(AppStorage.NOTIFICATION_UNREAD, "0");
    if (getNotificationList())
      Get.dialog(Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.only(bottom: 20, top: 50),
          child: Column(
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
                child: Padding(
                  padding: EdgeInsets.only(left: 30, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 30,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: Text(
                        "Messages",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Colors.red,
                            size: 30,
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) {
                      return Container(height: 1, color: Colors.grey.shade300);
                    },
                    itemBuilder: (context, index) {
                      return list[index];
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 60,
                width: double.maxFinite,
                decoration: BoxDecoration(border: Border(top: BorderSide(width: 1))),
                child: Padding(
                  padding: EdgeInsets.only(left: 30, right: 20),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(Routes.NotificationPage);
                        },
                        child: Text("View All"),
                      )),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ));
    else
      Get.defaultDialog(
          title: "Alert!",
          middleText: "No new Notifications",
          confirm: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Text("Ok")));
  }

  void deleteController(int bottomIndex, value) {
    // switch (bottomIndex) {
    //   case 0:
    //     Get.delete<MenuHomePageController>();
    //     break;
    // }
    // switch (value) {
    //   case 0:
    //     MenuHomePageController m = Get.put(MenuHomePageController());
    //     break;
    // }
  }

  signOut() async {
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var url = Const.getFullARMUrl(ServerConnections.API_SIGNOUT);
    Get.defaultDialog(
        title: "Log out",
        middleText: "Are you sure you want to log out?",
        confirm: ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              } catch (e) {}
              var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body));
              // print(resp);
              if (resp != "" && !resp.toString().contains("error")) {
                var jsonResp = jsonDecode(resp);
                if (jsonResp['result']['success'].toString() == "true") {
                  appStorage.remove(AppStorage.SESSIONID);
                  appStorage.remove(AppStorage.TOKEN);
                  Get.offAllNamed(Routes.Login);
                } else {
                  error(jsonResp['result']['message'].toString());
                }
              } else {
                error("Some error occurred");
              }
            },
            child: Text("Yes")),
        cancel: ElevatedButton(
            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
            onPressed: () {
              Get.back();
            },
            child: Text("No")));
  }

  void changePasswordCalled() {
    //change Password

    // if success
    closeProfileDialog();
  }

  error(var msg) {
    Get.snackbar("Error!", msg, snackPosition: SnackPosition.BOTTOM, colorText: Colors.white, backgroundColor: Colors.red);
  }

  void closeProfileDialog() {
    cnPassCtrl.text = "";
    oPassCtrl.text = "";
    nPassCtrl.text = "";
    Get.back();
  }

  getNotificationList() {
    list.clear();
    // appStorage.remove(AppStorage.NOTIFICATION_LIST);
    List notList = appStorage.retrieveValue(AppStorage.NOTIFICATION_LIST) ?? [];
    if (notList.isEmpty) return false;
    for (var item in notList) {
      var val = jsonDecode(item);
      list.add(WidgetNotification(FirebaseMessageModel.fromJson(val)));
    }
    // var rList = list.reversed.toList();
    // list = rList;
    return true;
  }

  Future<bool> deleteNotification(int index) async {
    var value;
    await Get.defaultDialog(
        title: "Delete?",
        middleText: "Do you want to delete this notification?",
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
            value = true;
            _deleteNotificationFromStorage(index);
          },
          child: Text("Yes"),
        ),
        cancel: TextButton(
            onPressed: () {
              Get.back();
              value = false;
            },
            child: Text("No")));
    return value;
  }

  _deleteNotificationFromStorage(int index) async {
    List notiList = await appStorage.retrieveValue(AppStorage.NOTIFICATION_LIST) ?? [];
    notiList.removeAt(index);
    await appStorage.storeValue(AppStorage.NOTIFICATION_LIST, notiList);
    needRefreshNotification.value = true;
    notificationPageRefresh.value = true;
  }
}

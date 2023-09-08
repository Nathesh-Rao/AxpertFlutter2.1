import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/MenuHomePageConroller.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Page/MenuActiveListPage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Page/MenuCalendarPage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Page/MenuDashboardPage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Page/MenuHomePage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Page/MenuMorePage.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingPageController extends GetxController {
  var bottomIndex = 0.obs;

  DateTime currentBackPressTime = DateTime.now();

  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  var pageList = [MenuHomePage(), MenuActiveListPage(), MenuDashboardPage(), MenuCalendarPage(), MenuMorePage()];

  get getPage => pageList[bottomIndex.value];

  indexChange(value) => bottomIndex.value = value;

  showNotificationIconPressed() {}

  Future<bool> onWillPop() {
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
    MenuHomePageController menuHomePageController = Get.find();
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
                  itemCount: menuHomePageController.list.length,
                  separatorBuilder: (context, index) {
                    return Container(height: 1, color: Colors.grey.shade300);
                  },
                  itemBuilder: (context, index) {
                    return menuHomePageController.list[index];
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
  }
}

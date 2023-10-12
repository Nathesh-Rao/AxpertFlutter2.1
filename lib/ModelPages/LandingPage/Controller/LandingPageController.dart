import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/ModelPages/HomePage_old/controller/HomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageConroller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Page/MenuActiveListPage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuCalendarPage/Page/MenuCalendarPage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuDashboardPage/Page/MenuDashboardPage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Page/MenuHomePage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Page/MenuMorePage.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetNotification.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingPageController extends GetxController {
  var bottomIndex = 0.obs;
  var carouselIndex = 0.obs;
  final CarouselController carouselController = CarouselController();

  DateTime currentBackPressTime = DateTime.now();

  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  var pageList = [MenuHomePage(), MenuActiveListPage(), MenuDashboardPage(), MenuCalendarPage(), MenuMorePage()];
  var list = [
    WidgetNotification("1"),
    WidgetNotification("2"),
    WidgetNotification("3"),
    WidgetNotification("4"),
    WidgetNotification("5"),
    WidgetNotification("6"),
  ];
  get getPage => pageList[bottomIndex.value];

  indexChange(value) {
    deleteController(bottomIndex.value, value);
    bottomIndex.value = value;
  }

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
}

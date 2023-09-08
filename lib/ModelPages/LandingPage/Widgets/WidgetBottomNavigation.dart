import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomNavigation extends StatelessWidget {
  AppBottomNavigation({super.key});
  LandingPageController landingPageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            unselectedItemColor: Colors.black,
            selectedItemColor: Colors.blue,
            currentIndex: landingPageController.bottomIndex.value,
            onTap: (value) => landingPageController.indexChange(value),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: "Active List"),
              BottomNavigationBarItem(icon: Icon(Icons.speed_outlined), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_outlined), label: "More"),
            ]));
  }
}

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomNavigation extends StatelessWidget {
  AppBottomNavigation({super.key});
  final LandingPageController landingPageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(color: Colors.black),
            child: BottomNavigationBar(
                currentIndex: landingPageController.bottomIndex.value,
                fixedColor: MyColors.blue2,
                unselectedItemColor: MyColors.grey,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 8,
                unselectedFontSize: 8,
                backgroundColor: Colors.grey.shade100,
                elevation: 10,
                onTap: (value) => landingPageController.indexChange(value),
                items: [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.view_list_outlined), label: "Active List"),
                  BottomNavigationBarItem(icon: Icon(Icons.speed_outlined), label: "Dashboard"),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
                  BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_outlined), label: "More"),
                ]),
          ),
        ));
  }
}

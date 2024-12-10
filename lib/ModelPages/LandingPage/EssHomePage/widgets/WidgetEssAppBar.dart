import 'dart:convert';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetDisplayProfileDetails.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/EssController.dart';

class WidgetEssAppBar extends StatelessWidget implements PreferredSizeWidget {
  WidgetEssAppBar({super.key});

  final LandingPageController landingPageController = Get.find();
  final MenuHomePageController menuHomePageController = Get.find();
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      // backgroundColor: Color(0xff3764FC),
      flexibleSpace: Obx(
        () => Container(
          decoration: BoxDecoration(
              gradient: controller.bottomIndex.value != 0
                  ? controller.appbarStaticColorGradient
                  : controller.appbarHomeGradient.value),
        ),
      ),
      titleSpacing: 5,
      // leading: Icon(Icons.menu),
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/axpert_03.png",
              height: 35,
              // width: 25,
            ),
            Text(
              "xpert",
              style: TextStyle(
                fontFamily: 'Gellix-Black',
                // color: HexColor("#133884"),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 5),
            Obx(() => Visibility(
                  visible: menuHomePageController
                          .client_info_logo_base64String.value !=
                      "",
                  child: Image.memory(
                    base64Decode(menuHomePageController
                        .client_info_logo_base64String.value),
                    height: 40,
                    width: 40,
                  ),
                )),
          ],
        ),
      ),
      centerTitle: false,
      actions: [
        /*IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 33, maxWidth: 33),
              onPressed: () {
                Get.toNamed(Routes.SettingsPage);
              },
              icon: Icon(Icons.settings)),*/
        Obx(() => IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 33, maxWidth: 33),
              onPressed: () {
                landingPageController.showNotifications();
              },
              icon: Badge(
                isLabelVisible: landingPageController.showBadge.value,
                label: Text(landingPageController.badgeCount.value.toString()),
                child: Icon(Icons.notifications_active_outlined),
              ),
            )),
        SizedBox(
          width: 5,
        ),
        // IconButton(onPressed: () {}, icon: Icon(Icons.dashboard_customize_outlined)),
        IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 33, maxWidth: 40),
            onPressed: () {
              Get.toNamed(Routes.SettingsPage);
              //Get.dialog(WidgetDisplayProfileDetails());
            },
            icon: Icon(Icons.person_pin, size: 30)),
        // InkWell(
        //   onTap: () {},
        //   child: Icon(Icons.person_pin, color: MyColors.black, size: 35),
        //   // child: CircleAvatar(
        //   //   // backgroundImage: AssetImage('assets/images/profpic.jpg'),
        //   //   backgroundColor: Colors.blue,
        //   //   backgroundImage: AssetImage("assets/images/appversion"),
        //   // ),
        // ),
        SizedBox(
          width: 8,
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(AppBar().preferredSize.height);
}

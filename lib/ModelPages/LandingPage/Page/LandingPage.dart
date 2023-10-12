import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetBottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});
  LandingPageController landingPageController = Get.put(LandingPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/axpert.png",
                height: 25,
              ),
              Text(
                "xpert",
                style: TextStyle(fontFamily: 'Gellix-Black', color: HexColor("#133884"), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                landingPageController.showNotifications();
              },
              icon: Icon(Icons.notifications_active_outlined)),
          IconButton(onPressed: () {}, icon: Icon(Icons.dashboard_customize_outlined)),
          CircleAvatar(
            // backgroundImage: AssetImage('assets/images/profpic.jpg'),
            backgroundColor: Colors.blue,
            backgroundImage: AssetImage("assets/images/axpert.png"),
          ),
          SizedBox(
            width: 8,
          )
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(),
      body: WillPopScope(
        onWillPop: landingPageController.onWillPop,
        child: Obx(() => landingPageController.getPage),
      ),
    );
  }
}

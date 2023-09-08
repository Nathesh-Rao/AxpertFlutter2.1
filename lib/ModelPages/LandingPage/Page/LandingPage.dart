import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetBottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});
  LandingPageController landingPageController = Get.put(LandingPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text("Axpert"),
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

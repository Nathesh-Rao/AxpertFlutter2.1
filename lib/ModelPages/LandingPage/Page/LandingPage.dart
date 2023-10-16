import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetBottomNavigation.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetLandingAppBar.dart';
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
      appBar: WidgetLandingAppBar(),
      bottomNavigationBar: AppBottomNavigation(),
      body: WillPopScope(
        onWillPop: landingPageController.onWillPop,
        child: Obx(() => landingPageController.getPage),
      ),
    );
  }
}

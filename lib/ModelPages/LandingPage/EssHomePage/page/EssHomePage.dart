import 'package:axpertflutter/ModelPages/InApplicationWebView/page/InApplicationWebView.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssAnnouncement.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssAppDrawer.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssAttendanceCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssHomeCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssKPICards.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetEssOtherServiceCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/widgets/WidgetHeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import '../widgets/WidgetEssAppBar.dart';
import '../widgets/WidgetEssMenuFolderWidget.dart';
import '../widgets/WidgetEssRecentActivity.dart';

class EssHomePage extends StatelessWidget {
  EssHomePage({super.key});
  final EssController controller = Get.put(EssController());
  final MenuHomePageController menuHomePageController =
      Get.put(MenuHomePageController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.onWillPop,
      child: Scaffold(
        drawer: WidgetEssAppDrawer(),
        extendBodyBehindAppBar: true,
        appBar: WidgetEssAppBar(),
        body: Obx(
          () => Stack(
            children: [
              controller.getPage(),
              Visibility(
                  visible: menuHomePageController.switchPage.value,
                  child: InApplicationWebViewer(menuHomePageController.webUrl))
            ],
          ),
        ),
      ),
    );
  }
}

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
import '../widgets/WidgetEssRecentActivity.dart';

class EssHomePage extends StatelessWidget {
  EssHomePage({super.key});
  final EssController controller = Get.put(EssController());
  final MenuHomePageController menuHomePageController =
      Get.put(MenuHomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: WidgetEssAppDrawer(),
      extendBodyBehindAppBar: true,
      appBar: WidgetEssAppBar(),
      body:
          //       landingPageController.getPage(),

          Obx(
        () => Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: controller.scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      WidgetHeaderWidget(),
                      WidgetEssAttendanceCard(),
                      _heightBox(),
                      WidgetEssHomecard(),
                      _heightBox(),
                      WidgetEssKPICards(),
                      _heightBox(),
                      WidgetEssOtherServiceCard(),
                      _heightBox(),
                      WidgetRecentActivity(),
                      WidgetEssAnnouncement(),
                      _heightBox(),
                    ],
                  ),
                ),
              ],
            ),
            Visibility(
                visible: menuHomePageController.switchPage.value,
                child: InApplicationWebViewer(menuHomePageController.webUrl))
          ],
        ),
      ),
    );
  }

  Widget _heightBox({double height = 15}) => SizedBox(height: height);
}

import 'package:axpertflutter/ModelPages/InApplicationWebView/controller/webview_controller.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/page/InApplicationWebView.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/UpdatedActiveTaskListController/ActiveTaskListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetBottomNavigation.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetDrawer.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetLandingAppBarUpdated.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});

  final LandingPageController landingPageController = Get.find();
  final MenuHomePageController menuHomePageController = Get.put(MenuHomePageController());
  final WebViewController webViewController = Get.find();
  final ActiveTaskListController _c = Get.put(ActiveTaskListController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => IndexedStack(
        index: webViewController.currentIndex.value,
        children: [
          Scaffold(
            appBar: WidgetLandingAppBarUpdated(),
            // appBar: WidgetLandingAppBar(),
            drawer: WidgetDrawer(),
            bottomNavigationBar: AppBottomNavigation(),
            body: WillPopScope(
              onWillPop: landingPageController.onWillPop,
              child: Obx(
                () => Stack(
                  children: [
                    landingPageController.getPage(),
                  ],
                ),
              ),
              /* menuHomePageController.switchPage.value == true
                      ? InApplicationWebViewer(menuHomePageController.webUrl)
                      : landingPageController.getPage(),
                  ),*/
            ),
          ),
          Obx(() => InApplicationWebViewer(webViewController.currentUrl.value)),
        ],
      ),
    );
  }
}

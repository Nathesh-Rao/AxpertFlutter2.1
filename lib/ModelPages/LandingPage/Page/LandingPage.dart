import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/controller/webview_controller.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/page/InApplicationWebView.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/UpdatedActiveTaskListController/ActiveTaskListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetBottomNavigation.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetDrawer.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetLandingAppBarUpdated.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../LandingMenuPages/MenuDashboardPage/Controllers/MenuDashboaardController.dart';

class LandingPage extends StatelessWidget {
  LandingPage({super.key});

  final LandingPageController landingPageController = Get.find();
  final MenuHomePageController menuHomePageController =
      Get.put(MenuHomePageController());
  final WebViewController webViewController = Get.find();
  final ActiveTaskListController _c = Get.put(ActiveTaskListController());
  final OfflineFormController offlineFormController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return; // already popped, no action needed

          if (webViewController.currentIndex.value == 1) {
            // If WebView is visible, go back to Home instead of closing app
            webViewController.currentIndex.value = 0;
          } else {
            // If already on Home, allow normal app close
            final shouldPop = await landingPageController.onWillPop();
            /*if (shouldPop) {
                  // Completely close the app
                  SystemNavigator.pop();
                }*/
          }
        },
        child: IndexedStack(
          index: webViewController.currentIndex.value,
          children: [
            Scaffold(
              appBar: WidgetLandingAppBarUpdated(),
              // appBar: WidgetLandingAppBar(),
              drawer: _getDrawerWidget(context),
              bottomNavigationBar: AppBottomNavigation(),
              body: /*WillPopScope(
                onWillPop: landingPageController.onWillPop,
                child:*/
                  Obx(
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
            //  ),
            Obx(() =>
                InApplicationWebViewer(webViewController.currentUrl.value)),
          ],
        ),
      ),
    );
  }

  Widget _getDrawerWidget(BuildContext context) {
    if (landingPageController.bottomIndex.value == 5) {
      return _buildDrawer(context);
    } else {
      return WidgetDrawer();
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final bg = const Color(0xFFF8F7F4);

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                "Offline Data Manager",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyColors.AXMDark,
                ),
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                children: [
                  _sectionHeader("Sync"),
                  _simpleRow(
                    icon: Icons.sync,
                    color: MyColors.blue2,
                    title: "Sync All",
                    subtitle: "Push pending & refetch everything",
                    onTap: offlineFormController.actionSyncAll,
                  ),
                  _simpleRow(
                    icon: Icons.description,
                    color: Colors.indigo,
                    title: "Refetch Forms",
                    subtitle: "Reload offline forms",
                    onTap: offlineFormController.actionRefetchForms,
                  ),
                  _simpleRow(
                    icon: Icons.storage,
                    color: Colors.teal,
                    title: "Refetch Datasources",
                    subtitle: "Reload lookup data",
                    onTap: offlineFormController.actionRefetchDatasources,
                  ),
                  const Divider(),
                  _sectionHeader("Queue"),
                  _simpleRow(
                    icon: Icons.upload_file,
                    color: Colors.deepOrange,
                    title: "Push Pending Uploads",
                    subtitle: "Upload queued data to server",
                    onTap: offlineFormController.actionPushPending,
                  ),
                  _simpleRow(
                    isDisabled: true,
                    icon: Icons.clear_all,
                    color: Colors.brown,
                    title: "Clear Pending Queue",
                    subtitle: "Delete all pending submissions",
                    onTap: offlineFormController.actionClearPending,
                  ),
                  const Divider(),
                  _sectionHeader("Storage"),
                  _simpleRow(
                    isDisabled: true,
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    title: "Clear Forms Cache",
                    subtitle: "Remove offline forms",
                    onTap: offlineFormController.actionClearForms,
                  ),
                  _simpleRow(
                    isDisabled: true,
                    icon: Icons.delete_sweep,
                    color: Colors.red,
                    title: "Clear Datasources Cache",
                    subtitle: "Remove cached datasources",
                    onTap: offlineFormController.actionClearDatasources,
                  ),
                  const Divider(),
                  _sectionHeader("Danger Zone"),
                  _simpleRow(
                    // isDisabled: true,
                    icon: Icons.warning,
                    color: Colors.red.shade900,
                    title: "Clear ALL Offline Data",
                    subtitle: "Deletes everything except user",
                    onTap: offlineFormController.actionClearAll,
                    isDanger: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: MyColors.AXMGray,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _simpleRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
    bool isDisabled = false,
  }) {
    final Color iconColor = isDisabled ? Colors.grey.shade400 : color;

    final Color titleColor = isDisabled
        ? Colors.grey.shade400
        : (isDanger ? Colors.red : MyColors.AXMDark);

    final Color subTitleColor =
        isDisabled ? Colors.grey.shade300 : MyColors.AXMGray;

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      enabled: !isDisabled,
      leading: Icon(icon, size: 20, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: subTitleColor,
        ),
      ),
      trailing: isDisabled ? null : const Icon(Icons.chevron_right, size: 18),
      onTap: isDisabled ? null : onTap,
    );
  }
}

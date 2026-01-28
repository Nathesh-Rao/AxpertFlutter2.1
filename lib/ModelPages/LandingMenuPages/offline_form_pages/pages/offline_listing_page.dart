import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/InApplicationWebView/controller/webview_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_static_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/inward_entry_dynamic_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/inward_entry_dynamic_page_v1.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/widgets/form_action_tile.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/inward_entry/widgets/report_action_tile.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/pages/offline_static_page.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/widgets/offline_page_card.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineListingPage extends GetView<OfflineFormController> {
  const OfflineListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OfflineStaticFormController());
    var inwardEntryDynamicController = Get.put(InwardEntryDynamicController());
    InternetConnectivity connectionController = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllPages();
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFF8F7F4),
        foregroundColor: MyColors.AXMDark,
        automaticallyImplyLeading: false,
        title: Text("Offline Forms"),
      ),
      backgroundColor: Color(0xFFF8F7F4),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(
              () => GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                itemCount: controller.allPages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                // itemBuilder: (context, index) => _pageTile(
                //   controller.allPages[index],
                //   index,
                // ),
                itemBuilder: (_, index) {
                  return _getGridTile(index, inwardEntryDynamicController);

                  // if (page.transId != "inward_entry") {
                  //   return OfflinePageCardCupertino(
                  //     page: page,
                  //     index: index,
                  //     onTap: () => controller.loadPage(page),
                  //     useColoredTile: true,
                  //   );

                  //   // return CircleAvatar();
                  // } else {
                  //   final rawpage = controller.allRawPages[index];
                  //   return SquareActionTile(
                  //     icon: Icons.pages,
                  //     title: rawpage["caption"],
                  //     onTap: () async {
                  //       await inwardEntryDynamicController.prepareForm(rawpage);
                  //       Get.to(
                  //         () => InwardEntryDynamicPageV1(schema: rawpage),
                  //         transition: Transition.rightToLeft,
                  //       );
                  //     },
                  //   );
                  // }
                },
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Get.to(OfflineStaticFormPageV2Compact());

      //   },
      //   child: Icon(Icons.pages),
      // ),
    );
  }

  Widget _getGridTile(
      int index, InwardEntryDynamicController inwardEntryDynamicController) {
    final page = controller.allPages[index];
    final rawPage = controller.allRawPages[index];

    if (page.pageType == "form") {
      if (page.transId == "inward_entry") {
        return FormActionTile(
          icon: Icons.pages,
          title: rawPage["caption"],
          onTap: () async {
            await inwardEntryDynamicController.prepareForm(rawPage);
            Get.to(
              () => InwardEntryDynamicPageV1(schema: rawPage),
              transition: Transition.rightToLeft,
            );
          },
        );
      } else {
        return OfflinePageCardCupertino(
          page: page,
          index: index,
          onTap: () => controller.loadPage(page),
          useColoredTile: true,
        );
      }
    } else if (page.pageType == "iview") {
      return Obx(
        () => ReportActionTile(
          isDisabled: !controller.isConnected.value,
          icon: Icons.report,
          title: rawPage["caption"],
          onTap: () {
            controller.onReportCardClick(rawPage['transid']);
          },
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class OfflinePageCardCupertino extends StatelessWidget {
  final OfflineFormPageModel page;
  final int index;
  final VoidCallback onTap;
  final bool useColoredTile;

  const OfflinePageCardCupertino({
    super.key,
    required this.page,
    required this.index,
    required this.onTap,
    this.useColoredTile = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = useColoredTile
        ? MyColors.getOfflineColorByIndex(index)
        : Colors.blueGrey.shade600;

    final Color bgColor = accentColor.withOpacity(0.12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- ICON ----------
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 24,
                color: accentColor,
              ),
            ),

            const Spacer(),

            // ---------- TITLE ----------
            Text(
              page.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            // ---------- ATTACHMENT INDICATOR ----------
            if (page.attachments)
              Row(
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 14,
                    color: accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Attachments',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

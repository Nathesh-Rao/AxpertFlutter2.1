import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/widgets/offline_page_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineListingPage extends GetView<OfflineFormController> {
  const OfflineListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllPages();
    });

    return Scaffold(
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
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1),
                // itemBuilder: (context, index) => _pageTile(
                //   controller.allPages[index],
                //   index,
                // ),
                itemBuilder: (_, index) {
                  final page = controller.allPages[index];
                  return OfflinePageCard2(
                    page: page,
                    index: index,
                    onTap: () => controller.loadPage(page),
                    useColoredTile: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

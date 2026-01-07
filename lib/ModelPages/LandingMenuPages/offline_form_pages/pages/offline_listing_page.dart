import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_static_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/models/form_page_model.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/pages/offline_static_page.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/widgets/offline_page_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OfflineListingPage extends GetView<OfflineFormController> {
  const OfflineListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OfflineStaticFormController());
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
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                // itemBuilder: (context, index) => _pageTile(
                //   controller.allPages[index],
                //   index,
                // ),
                itemBuilder: (_, index) {
                  final page = controller.allPages[index];
                  return OfflinePageCardCupertino(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(OfflineStaticFormPageV2Compact());
        },
        child: Icon(Icons.pages),
      ),
    );
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

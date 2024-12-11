import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ESSAnnouncementModel.dart';

class WidgetEssAnnouncement extends StatelessWidget {
  WidgetEssAnnouncement({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));
    return Obx(
      () => Visibility(
        visible: controller.listOfAnnouncementHomeScreenWidgets.isNotEmpty,
        child: Card(
          elevation: 5,
          margin: EdgeInsets.only(left: 15, right: 15, top: 25),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Row(
                  children: [
                    Text(
                      "Announcement",
                      style: style,
                    ),
                    Spacer(),
                    // InkWell(
                    //   onTap: () {
                    //     controller.getESSAnnouncement();
                    //   },
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Text(
                    //         "See all",
                    //         style: style.copyWith(
                    //           fontSize: 12,
                    //           color: Colors.blue.shade900,
                    //         ),
                    //       ),
                    //       Icon(
                    //         Icons.chevron_right,
                    //         size: 16,
                    //         color: Colors.blue.shade900,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              Divider(
                thickness: 1.5,
              ),
              SizedBox(
                height: 10,
              ),
              ...controller.listOfAnnouncementHomeScreenWidgets,
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ESSRecentActivityModel.dart';

class WidgetRecentActivity extends StatelessWidget {
  WidgetRecentActivity({super.key});
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
        visible: controller.listOfRecentActivityHomeScreenWidgets.isNotEmpty,
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
                      "Recent Activity",
                      style: style,
                    ),
                    Spacer(),
                    // InkWell(
                    //   onTap: () {},
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
              // ...List.generate(
              //     controller.listOfESSRecentActivity.length > 5
              //         ? 5
              //         : controller.listOfESSRecentActivity.length,
              //     (index) =>
              //         _activityItem(controller.listOfESSRecentActivity[index])),
              ...controller.listOfRecentActivityHomeScreenWidgets
            ],
          ),
        ),
      ),
    );
  }

  // _activityItem(EssRecentActivityModel model) {
  //   var color = MyColors.getRandomColor();

  //   return ListTile(
  //     onTap: () {},
  //     leading: CircleAvatar(
  //       backgroundColor: color.withAlpha(35),
  //       foregroundColor: color,
  //       child: Icon(controller.generateIcon(model, 1)),
  //     ),
  //     title: Text(
  //       model.caption,
  //       style: GoogleFonts.poppins(
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //     subtitle: Text(
  //       model.subheading,
  //       style: GoogleFonts.poppins(
  //         fontSize: 13,
  //       ),
  //     ),
  //     trailing: Text(
  //       model.info1,
  //       style: GoogleFonts.poppins(
  //         fontSize: 11,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   );
  // }
}

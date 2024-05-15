import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetTopHeaderSection extends StatelessWidget {
  WidgetTopHeaderSection({super.key});
  final LandingPageController landingPageController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Padding(
                padding: EdgeInsets.only(left: 20),
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Hello, ${CommonMethods.capitalize(landingPageController.userName.value)}",
                    // + CommonMethods.capitalize(landingPageController.userName.value),
                    style:
                        GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
              )),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Container(
              // padding: EdgeInsets.only(top: 1),
              child: Text(
                "Agile Labs Pvt. Ltd.",
                style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
          ),
          Container(
            width: double.maxFinite,
            margin: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 20, right: 5),
                  child: Text(
                    landingPageController.toDay,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.blue2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 20, right: 5, bottom: 10),
                  child: Text(
                    "Hooray! Today is pay day!",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'WidgetEssSearchBar.dart';

class WidgetHeaderWidget extends StatelessWidget {
  WidgetHeaderWidget({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.29,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff3764FC),
              Color(0xff9764DA),
            ]),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -35,
            top: -60,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(15),
              radius: size.height * 0.16,
            ),
          ),
          Positioned(
            right: 5,
            bottom: 60,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(15),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
            ),
          ),
          _userInfoWidget(
              username: controller.userName.value, companyName: "Agile Labs"),
          WidgetEssSearchBar(),
        ],
      ),
    );
  }

  Widget _userInfoWidget({
    required String username,
    required String companyName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 32,
              child: CircleAvatar(
                // backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/images/profilesample.jpg"),
                radius: 30,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warehouse,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      companyName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/controller/AttendanceController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetAttendanceTopBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  AttendanceAppBar({super.key});

  final AttendanceController attendanceController = Get.find<AttendanceController>();
  @override
  Size get preferredSize => Size(double.infinity, attendanceController.appbarHeight);
  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding;
    var borderRadius = 25.0;
    return Material(
      type: MaterialType.canvas,
      elevation: 4.0,
      shadowColor: Colors.grey.withOpacity(0.5),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: Container(
        padding: topPadding,
        decoration: BoxDecoration(
          gradient: MyColors.subBGGradientVertical,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacer(),
              _topBarWidget(),
              Spacer(flex: 2),
              _userInfoWidget(username: "Amrithanath", companyName: "Agile Labs"),
              Spacer(flex: 2),
              WidgetAttendanceTopBar()
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfoWidget({
    required String username,
    required String companyName,
  }) {
    return GestureDetector(
      onTap: attendanceController.openProfileBottomSheet,
      child: Container(
        padding: EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Color(0xffD9D9D9).withAlpha(44),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withAlpha(56),
              radius: 25,
              child: CircleAvatar(
                backgroundColor: Colors.white.withAlpha(56),
                radius: 23,
                child: CircleAvatar(
                  // backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/images/profilesample.jpg"),
                  radius: 28,
                ),
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
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
                Text(
                  companyName,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withAlpha(150),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  _topBarWidget() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withAlpha(40),
              radius: 18,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(3),
                child: Image.asset("assets/images/axpert_03.png"),
              )),
            ),
            SizedBox(
              width: 10,
            ),
            Text("Axpert Attendance\nManagement",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w600,
                  height: 1,
                )),
            Spacer(),
            IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 26,
                  color: Colors.white.withAlpha(100),
                ))
          ],
        ),
      );
}

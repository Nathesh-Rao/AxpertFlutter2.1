import 'package:animate_do/animate_do.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/controller/AttendanceController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/TeamMemberModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetProfileBottomSheet extends StatelessWidget {
  WidgetProfileBottomSheet({super.key});
  final AttendanceController attendanceController = Get.find();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.profileBottomSheetInIt();
    });
    return Container(
      clipBehavior: Clip.hardEdge,
      height: MediaQuery.of(context).size.height / 1.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Obx(
        () {
          return ListView(
            padding: EdgeInsets.all(15),
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  color: Color(0xff5BB3F0),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              SizedBox(height: 10),
              Container(
                // height: MediaQuery.of(context).size.height / 3.5,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      padding: EdgeInsets.only(left: 15),
                      // margin: EdgeInsets.only(bottom: 10),
                      color: Color(0xffD9D9D9),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              "Your Team",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _getMainWidget(),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  _getMainWidget() {
    if (attendanceController.isBottomSheetLoading.value) {
      return Column(
        children: [
          LinearProgressIndicator(
            color: Color(0xff3764FC),
            minHeight: 2,
          ),
          SizedBox(height: 100),
          Text(
            "Getting Team members info...",
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 100),
        ],
      );
    }
    if (attendanceController.teamMemberList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/no_data_found.png',
              width: 200,
            ),
            Text(
              "No team member found",
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    }
    return FadeInUp(
      from: 20,
      duration: Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(attendanceController.teamMemberList.length,
            (index) => _teamUserInfoWidget(attendanceController.teamMemberList[index])),
      ),
    );
  }

  _teamUserInfoWidget(TeamMemberModel member) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withAlpha(56),
            radius: 25,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha(56),
              radius: 23,
              child: CircleAvatar(
                backgroundColor: MyColors.white1,
                // backgroundImage: AssetImage("assets/images/profilesample.jpg"),
                radius: 28,
                child: Icon(
                  Icons.person,
                  color: MyColors.text1,
                ),
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
                member.empname,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              Text(
                member.designation,
                style: GoogleFonts.poppins(
                  color: Colors.black.withAlpha(150),
                  fontSize: 12,
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
    );
  }
}

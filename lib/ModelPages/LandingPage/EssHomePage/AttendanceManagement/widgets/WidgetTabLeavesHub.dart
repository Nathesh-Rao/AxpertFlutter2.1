import 'dart:developer';
import 'dart:ffi';

import 'package:animate_do/animate_do.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/LeaveBalanceModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/page/AttendanceApplyLeavePage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/AttendanceController.dart';
import 'WidgetButton.dart';
import 'WidgetProgressIndicator.dart';

class WidgetTabLeavesHub extends StatelessWidget {
  WidgetTabLeavesHub({super.key});
  final AttendanceController attendanceController = Get.find();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.leavesHubInIt();
    });
    return Padding(
      padding: MediaQuery.of(context).padding,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                flex: 3,
                child: Hero(
                  tag: "leaveApply",
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        offset: Offset(0, -2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      )
                    ]),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          padding: EdgeInsets.only(left: 15),
                          width: double.infinity,
                          color: Color(0xffF2F1F7),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  "Leaves",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Obx(() {
                              var isLoading = attendanceController.isLeavesHubLoading.isTrue;
                              var isEmpty = attendanceController.totalLeaveData.isEmpty;

                              if (isLoading) {
                                return Column(
                                  children: [
                                    LinearProgressIndicator(
                                      color: Color(0xff3764FC),
                                      minHeight: 2,
                                    ),
                                  ],
                                );
                              }
                              if (isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/no_data_found.png',
                                        width: 200,
                                      ),
                                      Text(
                                        "No Leave data found",
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  _mainLeaveIndicator(),
                                  Spacer(),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              attendanceController.totalLeaveData.length.toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'Leave Types',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Color(0xff919191),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              attendanceController.totalLeaves.toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'Total Leave',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Color(0xff919191),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: Get.height * 0.02),
                                  Spacer(),
                                  _subLeaveIndicatorRow(),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Expanded(
                child: Center(
              child: ButtonWidget(
                  label: "Apply Leave",
                  onTap: () {
                    Get.to(() => AttendanceApplyLeavePage());
                  }),
            )),
          ],
        ),
      ),
    );
  }

  _mainLeaveIndicator() {
    var style = GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w700,
    );
    return GradientCircularProgressIndicator(
      size: 170,
      // progress: 0.8,
      progress: (attendanceController.totalBalanceLeaves.value / attendanceController.totalLeaves.value),

      stroke: 7,
      gradient: MyColors.subBGGradientHorizontal,
      backgroundColor: Color(0xffE6E6E6),
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            attendanceController.totalBalanceLeaves.value.toString(),
            style: style,
          ),
          Text(
            'Leave Balance',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xff919191),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )),
    );
  }

  _subLeaveIndicatorRow() {
    var style = GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      height: 110,
      width: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20),
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
              attendanceController.totalLeaveData.length,
              (index) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientCircularProgressIndicator(
                          size: 55,

                          progress: _getLeaveProgressValue(attendanceController.totalLeaveData[index]),
                          // progress: data[data.keys.toList()[index]]! * 0.1,
                          stroke: 3,
                          gradient: MyColors.subBGGradientHorizontal,
                          backgroundColor: Color(0xffE6E6E6),
                          child: Center(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                attendanceController.totalLeaveData[index].balanceLeaves,
                                style: style,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: MyColors.text1,
                                ),
                              ),
                              Text(
                                attendanceController.totalLeaveData[index].totalLeaves,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.text1,
                                ),
                              ),
                            ],
                          )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Leaves",
                          // "${data.keys.toList()[index].split(" ")[0]}\nLeaves",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: style.copyWith(
                            fontSize: 11,
                            color: MyColors.text2,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  )),
        ),
      ),
    );
  }

  double _getLeaveProgressValue(LeaveBalanceModel data) {
    var total = double.parse(data.totalLeaves);
    var balance = double.parse(data.balanceLeaves);
    log((balance / total).toString());
    return balance / total;
  }
}

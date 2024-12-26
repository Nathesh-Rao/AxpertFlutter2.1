import 'dart:ffi';

import 'package:axpertflutter/Constants/MyColors.dart';
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
    return Container(
      padding: MediaQuery.of(context).padding,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Hero(
                tag: "leaveApply",
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  margin: EdgeInsets.only(top: 20, bottom: 40),
                  padding: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(35),
                      offset: Offset(0, -2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        padding: EdgeInsets.only(left: 15),
                        margin: EdgeInsets.only(bottom: 20),
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
                                  '16',
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
                            ),
                            Spacer(),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '16',
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
                      Spacer(),
                      _subLeaveIndicatorRow(),
                    ],
                  ),
                ),
              ),
            ),
            ButtonWidget(
                label: "Apply Leave",
                onTap: () {
                  Get.to(() => AttendanceApplyLeavePage());
                })
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
      progress: 0.8,
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
            '08',
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

    var data = {
      "Casual Leaves": 8,
      "Medical Leaves": 4,
      "Annual Leaves": 5,
      "Maternity Leaves": 6,
      "Paternity Leaves": 3,
      "Study Leaves": 2,
      "Bereavement Leaves": 1,
      "Unpaid Leaves": 7,
    };

    return SizedBox(
      height: 110,
      width: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20),
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
              data.length,
              (index) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientCircularProgressIndicator(
                          size: 55,
                          progress: data[data.keys.toList()[index]]! * 0.1,
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
                                data[data.keys.toList()[index]].toString(),
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
                                '10',
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
                          "${data.keys.toList()[index].split(" ")[0]}\nLeaves",
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
}

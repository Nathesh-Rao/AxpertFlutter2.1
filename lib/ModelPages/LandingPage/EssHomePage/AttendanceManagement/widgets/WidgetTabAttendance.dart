import 'package:animate_do/animate_do.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/AttendanceDataModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/AttendanceReportModel.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/AttendanceController.dart';

class WidgetTabAttendance extends StatelessWidget {
  WidgetTabAttendance({super.key});
  // final AttendanceController controller;
  final AttendanceController attendanceController = Get.find();
  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceController.tabAttendanceInIt();
    });

    return Container(
      padding: MediaQuery.of(context).padding,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Row(
              children: [Text("Attendance", style: style), Spacer(), _yearPickerWidget(context)],
            ),
          ),
          SizedBox(height: 15),
          Obx(() => _attendanceListView(value: attendanceController.selectedMonthIndex.value)),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      offset: Offset(0, -2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ]),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(gradient: MyColors.subBGGradientHorizontal),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    height: 42,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Date",
                            style: style.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Clock In",
                            style: style.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(width: 25),
                        Expanded(
                          child: Text(
                            "Clock Out",
                            style: style.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Working Hrs",
                            style: style.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () {
                        if (attendanceController.isAttendanceReportLoading.value) {
                          // return Center(
                          //   child: CircularProgressIndicator(),
                          // );
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                color: Color(0xff3764FC),
                                minHeight: 2,
                              ),
                              Spacer(),
                              FadeInUp(
                                  duration: Duration(milliseconds: 400),
                                  from: 25,
                                  // child: Text.rich(
                                  //   TextSpan(text: "Getting ", children: [
                                  //     TextSpan(
                                  //         text: "${attendanceController.months[attendanceController.selectedMonthIndex.value]}",
                                  //         style: GoogleFonts.poppins(
                                  //             fontSize: 20, fontWeight: FontWeight.w500, color: MyColors.text1)),
                                  //     TextSpan(text: " report...")
                                  //   ]),

                                  // style: GoogleFonts.poppins(
                                  //   fontSize: 15,
                                  //   fontWeight: FontWeight.w500,
                                  //   color: MyColors.text1,
                                  // ),
                                  child: Text(
                                    "${attendanceController.months[attendanceController.selectedMonthIndex.value]}\n${attendanceController.selectedYear.value}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: MyColors.text1),
                                  )
                                  // ),
                                  ),
                              Spacer(),
                            ],
                          );
                        }

                        if (attendanceController.attendanceReportList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/no_data_found.png',
                                  width: 200,
                                ),
                                Text(
                                  "No Data found for this month",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                        return FadeInUp(
                          duration: Duration(milliseconds: 400),
                          from: 25,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              children: List.generate(attendanceController.attendanceReportList.length,
                                  (index) => _attendanceListTile(attendanceController.attendanceReportList[index])),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _attendanceListTile(AttendanceReportModel data) {
    var style = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black);

    return Container(
      decoration:
          BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: _getTileWidgetBorderColor(data.status)))),
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 52,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _getTileDateWidget(data),
          ),
          Expanded(
            child: _statusCheck(data.status)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.intime,
                        style: style,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        "📍Location",
                        style: style.copyWith(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xff919191)),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  )
                : Text(
                    data.status,
                    style: style.copyWith(
                      color: _getTileWidgetBorderColor(data.status),
                    ),
                  ),
          ),
          SizedBox(width: 25),
          Expanded(
            child: _statusCheck(data.status)
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.outtime,
                        style: style,
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        "📍Location",
                        style: style.copyWith(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xff919191)),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              data.workingHours,
              style: style,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTileDateWidget(AttendanceReportModel data) {
    var color = _getTileDateWidgetColor(data.status);
    var date = data.date;
    return Row(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          height: 30,
          width: 30,
          decoration: BoxDecoration(color: color.withOpacity(0.28), borderRadius: BorderRadius.circular(5)),
          child: Column(
            children: [
              Expanded(
                  child: Center(
                child: Text(date.split(" ")[0].trim(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    )),
              )),
              Expanded(
                child: Container(
                  color: color,
                  child: Center(
                    child: Text(
                      date.split(" ")[1].trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  bool _statusCheck(String status) {
    if (status.toLowerCase().contains("active") || status.toLowerCase().contains("half")) {
      return true;
    }

    return false;
  }

  Color _getTileDateWidgetColor(String status) {
    if (status.toLowerCase().contains("off")) {
      return MyColors.baseRed;
    } else if (status.toLowerCase().contains("leave")) {
      return MyColors.baseYellow;
    } else {
      return MyColors.baseBlue;
    }
  }

  Color _getTileWidgetBorderColor(String status) {
    if (status.toLowerCase().contains("off")) {
      return MyColors.baseRed;
    } else if (status.toLowerCase().contains("leave")) {
      return MyColors.baseYellow;
    } else {
      return MyColors.basegray;
    }
  }

  Widget _attendanceListView({required int value}) {
    var style = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500);
    return SizedBox(
      height: 40,
      child: Center(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 15),
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 12,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              attendanceController.updateMonthIndex(index);
            },
            child: Text(
              attendanceController.months[index],
              style: style.copyWith(
                fontSize: 18,
                color: value == index ? MyColors.baseBlue : MyColors.text1,
                fontWeight: value == index ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          separatorBuilder: (context, index) => SizedBox(width: 20),
        ),
      ),
    );
  }

  Widget _yearPickerWidget(BuildContext context) {
    var style = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500);
    return Obx(
      () => GestureDetector(
        onTap: () {
          BottomPicker(
            items: List.generate(attendanceController.years.length, (index) => Text(attendanceController.years[index])),
            pickerTitle: Text(
              "Select Year",
              style: style.copyWith(
                fontSize: 20,
              ),
            ),
            pickerTextStyle: style.copyWith(
              fontSize: 24,
              color: MyColors.blue9,
            ),
            onChange: (index) {
              print(index);
            },
            onSubmit: attendanceController.updateSelectedYear,
            bottomPickerTheme: BottomPickerTheme.plumPlate,
          ).show(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: MyColors.blue10.withAlpha(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                color: MyColors.blue10,
                size: 20,
              ),
              SizedBox(width: 5),
              Text(
                attendanceController.selectedYear.value,
                style: style.copyWith(color: MyColors.blue10, fontSize: 14),
              ),
              SizedBox(width: 30),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: MyColors.blue10,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

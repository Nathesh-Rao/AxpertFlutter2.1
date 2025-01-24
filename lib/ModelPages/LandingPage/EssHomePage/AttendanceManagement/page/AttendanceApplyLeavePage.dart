import 'dart:developer';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/controller/AttendanceController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetButton.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetHorizontalProgressIndicator.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceApplyLeavePage extends StatelessWidget {
  AttendanceApplyLeavePage({super.key});

  final AttendanceController attendanceController = Get.find();

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
      color: MyColors.text1,
      fontWeight: FontWeight.w600,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _appbarWidget(context),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: MediaQuery.of(context).padding.top + 80,
            child: Hero(
              tag: "leaveApply",
              child: Container(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Leave Type",
                        style: style,
                      ),
                      Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _dropDownWidget(),
                            _progressIndicator(),
                          ],
                        ),
                      ),
                      _heightBox(15),
                      Obx(
                        () => Row(
                          children: [
                            Flexible(
                                child: datePicker(
                                    label: "Start Date",
                                    value: attendanceController.startDate.value,
                                    onSelect: attendanceController.onStartDateSelect,
                                    context: context)),
                            SizedBox(width: 20),
                            Flexible(
                                child: datePicker(
                                    label: "End Date",
                                    value: attendanceController.endDate.value,
                                    onSelect: attendanceController.onEndDateSelect,
                                    context: context)),
                          ],
                        ),
                      ),
                      _heightBox(15),
                      Text(
                        "Leave Mode",
                        style: style,
                      ),
                      _heightBox(10),
                      Obx(
                        () => Row(
                          children: [
                            Radio(
                                activeColor: MyColors.baseBlue,
                                value: attendanceController.leaveModeValue.value,
                                groupValue: 0,
                                onChanged: (_) {
                                  attendanceController.updateLeaveMode(0);
                                }),
                            Text(
                              "Half Day",
                              style: GoogleFonts.poppins(
                                  color: attendanceController.leaveModeValue.value == 0 ? MyColors.baseBlue : MyColors.text2),
                            ),
                            Radio(
                                activeColor: MyColors.baseBlue,
                                value: attendanceController.leaveModeValue.value,
                                groupValue: 1,
                                onChanged: (_) {
                                  attendanceController.updateLeaveMode(1);
                                }),
                            Text(
                              "Full Day",
                              style: GoogleFonts.poppins(
                                  color: attendanceController.leaveModeValue.value == 1 ? MyColors.baseBlue : MyColors.text2),
                            ),
                          ],
                        ),
                      ),
                      _heightBox(15),
                      Text(
                        "Reason",
                        style: style,
                      ),
                      _heightBox(10),
                      TextFormField(
                        maxLines: 8,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color(0xffECF2FF),
                        ),
                      ),
                      _heightBox(20),
                      ButtonWidget(label: "Apply", onTap: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _heightBox(double height) {
    return SizedBox(height: height);
  }

  Widget _dropDownWidget() {
    var style = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Color(0xffECF2FF), borderRadius: BorderRadius.circular(7)),
      child: Center(
        child: DropdownButton<String>(
          enableFeedback: true,
          isExpanded: true,
          borderRadius: BorderRadius.circular(20),

          hint: Text(
            "Select Leave Type",
            style: GoogleFonts.poppins(
              color: MyColors.text2,
              fontWeight: FontWeight.w500,
            ),
          ),
          value: attendanceController.selectedLeave.value == '' ? null : attendanceController.selectedLeave.value,
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          // alignment: AlignmentDirectional.bottomCenter,
          elevation: 16,
          style: style,
          underline: SizedBox.shrink(),

          onChanged: attendanceController.updateLeaveType,
          items: attendanceController.leaveTypes.keys.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: style,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _progressIndicator() {
    var value = attendanceController.totalLeaveCount.value;
    return Row(
      children: [
        Flexible(child: WidgetHorizontalProgressIndicator(value: value * 0.1)),
        _heightBox(10),
        RichText(
          text: TextSpan(
              text: value.toString(),
              style: GoogleFonts.poppins(
                color: MyColors.baseBlue,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: "/10",
                  style: GoogleFonts.poppins(
                    color: MyColors.text1,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ]),
        )
      ],
    );
  }

  Widget datePicker(
      {required String label, required String value, required BuildContext context, required Function(dynamic) onSelect}) {
    var style = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
    );
    return InkWell(
        onTap: () {
          BottomPicker.date(
            pickerTitle: Text(
              label,
              style: style.copyWith(
                fontSize: 20,
              ),
            ),
            dateOrder: DatePickerDateOrder.dmy,
            initialDateTime: DateTime.now(),
            maxDateTime: DateTime(2025),
            minDateTime: DateTime(2021),
            pickerTextStyle: style.copyWith(
              fontSize: 24,
              color: MyColors.blue9,
            ),
            onChange: (index) {
              print(index);
            },
            onSubmit: onSelect,
            bottomPickerTheme: BottomPickerTheme.plumPlate,
          ).show(context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: MyColors.text1,
                fontWeight: FontWeight.w600,
              ),
            ),
            _heightBox(10),
            Container(
              height: 60,
              decoration: BoxDecoration(color: Color(0xffECF2FF), borderRadius: BorderRadius.circular(7)),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: value != 'DD-MM-YYYY' ? Colors.black : Color(0xff7A7B95),
                    ),
                    Spacer(),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: value != 'DD-MM-YYYY' ? FontWeight.bold : FontWeight.w500,

                        color: value != 'DD-MM-YYYY' ? Colors.black : Color(0xff7A7B95),
                        // Color(0xff7A7B95)
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget _datePicker({required String label, required bool isStart, required BuildContext context}) {
    var style = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
    );
    return InkWell(
      onTap: () {
        BottomPicker.date(
          pickerTitle: Text(
            'Select Date',
            style: style.copyWith(
              fontSize: 20,
            ),
          ),
          dateOrder: DatePickerDateOrder.dmy,
          initialDateTime: DateTime.now(),
          maxDateTime: DateTime(2025),
          minDateTime: DateTime(2021),
          pickerTextStyle: style.copyWith(
            fontSize: 24,
            color: MyColors.blue9,
          ),
          onChange: (index) {
            print(index);
          },
          onSubmit: (index) {
            _setDate(index as DateTime, isStart);

            print(index);
          },
          bottomPickerTheme: BottomPickerTheme.plumPlate,
        ).show(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: MyColors.text1,
              fontWeight: FontWeight.w600,
            ),
          ),
          _heightBox(10),
          Container(
            height: 60,
            decoration: BoxDecoration(color: Color(0xffECF2FF), borderRadius: BorderRadius.circular(7)),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.calendar_month),
                  Spacer(),
                  Obx(
                    () => Text(
                      isStart ? attendanceController.startDate.value : attendanceController.endDate.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isStart
                            ? attendanceController.startDate.value != 'DD-MM-YYYY'
                                ? FontWeight.bold
                                : FontWeight.w500
                            : attendanceController.endDate.value != 'DD-MM-YYYY'
                                ? FontWeight.bold
                                : FontWeight.w500,
                        color: isStart
                            ? attendanceController.startDate.value != 'DD-MM-YYYY'
                                ? Colors.black
                                : Color(0xff7A7B95)
                            : attendanceController.endDate.value != 'DD-MM-YYYY'
                                ? Colors.black
                                : Color(0xff7A7B95),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _setDate(DateTime index, bool isStart) {
    var selectedDate = DateFormat('dd-MM-yyyy').format(index);

    if (isStart) {
      attendanceController.startDate.value = selectedDate;
    } else {
      attendanceController.endDate.value = selectedDate;
    }
  }

  _appbarWidget(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.only(bottom: 50, top: MediaQuery.of(context).padding.top),
        height: MediaQuery.of(context).padding.top + 130,
        decoration: BoxDecoration(
          gradient: MyColors.subBGGradientVertical,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text(
                "Request Leave",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
        ),
      ),
    );
  }
}

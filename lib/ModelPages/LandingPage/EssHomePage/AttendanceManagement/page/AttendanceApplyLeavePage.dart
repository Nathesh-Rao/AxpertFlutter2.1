import 'dart:developer';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetButton.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetHorizontalProgressIndicator.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceApplyLeavePage extends StatefulWidget {
  const AttendanceApplyLeavePage({super.key});

  @override
  State<AttendanceApplyLeavePage> createState() =>
      _AttendanceApplyLeavePageState();
}

class _AttendanceApplyLeavePageState extends State<AttendanceApplyLeavePage> {
  final Map<String, int> leaveTypes = {
    "Casual ": 8,
    "Medical ": 4,
    "Annual ": 5,
    "Maternity ": 6,
    "Paternity ": 3,
    "Study ": 2,
    "Bereavement ": 1,
    "Unpaid ": 7,
  };

  String? selectedLeave;
  String? startDate;
  String? endDate;
  int groupValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              // margin: MediaQuery.of(context).padding,
              padding: EdgeInsets.only(
                  bottom: 50, top: MediaQuery.of(context).padding.top),
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
          ),
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
                        style: GoogleFonts.poppins(
                          color: MyColors.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              color: Color(0xffECF2FF),
                              borderRadius: BorderRadius.circular(7)),
                          child: Center(child: _dropDownWidget())),
                      _progressIndicator(value: leaveTypes[selectedLeave] ?? 0),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Flexible(
                              child: _datePicker(
                                  label: "Start Date", isStart: true)),
                          SizedBox(width: 20),
                          Flexible(
                              child: _datePicker(
                                  label: "End Date", isStart: false)),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Leave Mode",
                        style: GoogleFonts.poppins(
                          color: MyColors.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Radio(
                              activeColor: MyColors.baseBlue,
                              value: 0,
                              groupValue: groupValue,
                              onChanged: (_) {
                                setState(() {
                                  groupValue = 0;
                                });
                              }),
                          Text(
                            "Half Day",
                            style: GoogleFonts.poppins(
                                color: groupValue == 0
                                    ? MyColors.baseBlue
                                    : MyColors.text2),
                          ),
                          Radio(
                              activeColor: MyColors.baseBlue,
                              value: 1,
                              groupValue: groupValue,
                              onChanged: (_) {
                                setState(() {
                                  groupValue = 1;
                                });
                              }),
                          Text(
                            "Full Day",
                            style: GoogleFonts.poppins(
                                color: groupValue == 1
                                    ? MyColors.baseBlue
                                    : MyColors.text2),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Reason",
                        style: GoogleFonts.poppins(
                          color: MyColors.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        maxLines: 8,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Color(0xffECF2FF),
                        ),
                      ),
                      SizedBox(height: 20),
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

  Widget _dropDownWidget() {
    return DropdownButton<String>(
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
      value: selectedLeave,
      icon: Icon(Icons.keyboard_arrow_down_rounded),
      // alignment: AlignmentDirectional.bottomCenter,
      elevation: 16,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      underline: SizedBox.shrink(),

      onChanged: (String? newValue) {
        setState(() {
          selectedLeave = newValue!;
        });
      },
      items: leaveTypes.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _progressIndicator({required int value}) {
    return Row(
      children: [
        Flexible(child: WidgetHorizontalProgressIndicator(value: value * 0.1)),
        SizedBox(width: 10),
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

  Widget _datePicker({required String label, required bool isStart}) {
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
          SizedBox(height: 10),
          Container(
            height: 60,
            decoration: BoxDecoration(
                color: Color(0xffECF2FF),
                borderRadius: BorderRadius.circular(7)),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.calendar_month),
                  Spacer(),
                  Text(
                    isStart
                        ? startDate ?? "DD-MM-YYYY"
                        : endDate ?? "DD-MM-YYYY",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isStart
                          ? startDate != null
                              ? FontWeight.bold
                              : FontWeight.w500
                          : endDate != null
                              ? FontWeight.bold
                              : FontWeight.w500,
                      color: isStart
                          ? startDate != null
                              ? Colors.black
                              : Color(0xff7A7B95)
                          : endDate != null
                              ? Colors.black
                              : Color(0xff7A7B95),
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

    setState(() {
      if (isStart) {
        startDate = selectedDate;
      } else {
        endDate = selectedDate;
      }
    });
  }
}

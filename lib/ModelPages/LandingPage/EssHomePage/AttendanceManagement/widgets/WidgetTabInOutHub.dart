import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/controller/AttendanceController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetButton.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'WidgetMapView.dart';

class WidgetTabInOutHub extends StatelessWidget {
  WidgetTabInOutHub({super.key});
  final AttendanceController attendanceController = Get.find();
  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
    );

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top - 25),
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/map.png"), fit: BoxFit.cover)),
        //   ),
        // ),
        Expanded(
          child: WidgetMapView(),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _dateTimeDisplayWidget(style),
                  Spacer(),
                  _datePickerWidget(context, style),
                ],
              ),
              SizedBox(height: 20),
              _clockInOutWidget(style),
              SizedBox(height: 20),
              ButtonWidget(label: "Click Out", onTap: () {})
            ],
          ),
        )
      ],
    );
  }

  _clockInOutWidget(TextStyle style) {
    return Container(
      clipBehavior: Clip.hardEdge,
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.blue10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
            color: MyColors.blue10,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "IN TIME",
                        style: style.copyWith(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: "09:12", style: style.copyWith(fontSize: 22, height: 1, color: Colors.white)),
                    TextSpan(text: "am", style: style.copyWith(color: Colors.white))
                  ])),
                ],
              ),
            ),
          )),
          Expanded(
              child: Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: MyColors.text1,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "OUT TIME",
                        style: style.copyWith(fontSize: 16, color: MyColors.text1),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Text.rich(TextSpan(children: [
                    TextSpan(text: "00:00", style: style.copyWith(fontSize: 22, height: 1, color: MyColors.text1)),
                    TextSpan(text: "am", style: style.copyWith(color: MyColors.text1))
                  ])),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  _datePickerWidget(BuildContext context, TextStyle style) {
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
          initialDateTime: DateTime(2024, 12, 1),
          maxDateTime: DateTime(2025),
          minDateTime: DateTime(2023),
          pickerTextStyle: style.copyWith(
            fontSize: 24,
            color: MyColors.blue9,
          ),
          onChange: (index) {
            print(index);
          },
          onSubmit: (index) {
            print(index);
          },
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
              "Today",
              style: style.copyWith(color: MyColors.blue10),
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
    );
  }

  _dateTimeDisplayWidget(TextStyle style) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          TextSpan(text: "09:12", style: style.copyWith(fontSize: 44, height: 1)),
          TextSpan(text: "am", style: style)
        ])),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 5),
            Text(
              "Wednesday, Dec 25",
              style: style.copyWith(
                color: MyColors.text1,
              ),
            ),
          ],
        )
      ],
    );
  }
}

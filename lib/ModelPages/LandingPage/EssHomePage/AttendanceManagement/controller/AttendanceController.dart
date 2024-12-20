import 'dart:developer';

import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetTabAttendance.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetTabInOutHub.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetTabLeavesHub.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
//topbar-control--------------
  final PageController pageController = PageController();

  Map<int, String> topBarMap = {
    0: "In-Out Hub",
    1: "Attendance",
    2: "Leaves Hub",
  };
  List<Widget> homePages = [
    WidgetTabInOutHub(),
    WidgetTabAttendance(),
    WidgetTabLeavesHub(),
  ];

  RxInt currentTopbarIndex = 0.obs;

  double appbarHeight = 210;

  double getAppBarHeight() {
    return 0.0;
  }

  updatePageIndexFromPageBuilder(int index) {
    currentTopbarIndex.value = index;
  }

  updatePageIndexFromTopBar(int index) {
    var diff = currentTopbarIndex.value - index;
    currentTopbarIndex.value = index;
    if (diff.abs() == 2) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }
  }

//-Attendance---------------------------------------------------------
  RxInt currentSelectedMonthIndex = 11.obs;
  updateMonthIndex(index) {
    currentSelectedMonthIndex.value = index;
  }

//----------------------------------------------------------
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

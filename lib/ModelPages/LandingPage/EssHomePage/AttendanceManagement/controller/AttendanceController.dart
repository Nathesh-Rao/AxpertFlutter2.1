import 'dart:developer';

import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetProfileBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceController extends GetxController {
//topBar-control--------------
  final PageController pageController = PageController();

  // AttendanceController() {
  //   print("Attendance controller created");
  //   pageController = PageController(initialPage: 0);
  // }

  Map<int, String> topBarMap = {
    0: "In-Out Hub",
    1: "Attendance",
    2: "Leaves Hub",
  };

  var currentTopBarIndex = 0.obs;

  double appbarHeight = 210;

  double getAppBarHeight() {
    return 0.0;
  }

  updatePageIndexFromPageBuilder(int index) {
    currentTopBarIndex.value = index;
  }

  updatePageIndexFromTopBar(int index) {
    var diff = currentTopBarIndex.value - index;
    currentTopBarIndex.value = index;
    if (diff.abs() == 2) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(index, duration: Duration(milliseconds: 400), curve: Curves.easeIn);
    }
  }

//-InOut tab--------
  openProfileBottomSheet() {
    Get.bottomSheet(WidgetProfileBottomSheet());
  }
//-Attendance------

  var months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  var years = [
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
  ];

  var selectedMonthIndex = 11.obs;
  var selectedYear = DateFormat("yyyy").format(DateTime.now()).obs;

  updateSelectedYear(dynamic date) {
    selectedYear.value = years[date];
  }

  updateMonthIndex(int index) {
    selectedMonthIndex.value = index;
  }

//applyLeave-control--------------
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
  var selectedLeave = ''.obs;
  var startDate = 'DD-MM-YYYY'.obs;
  var endDate = 'DD-MM-YYYY'.obs;
  var leaveModeValue = 0.obs;
  var totalLeaveCount = 0.obs;

  updateLeaveType(String? type) {
    selectedLeave.value = type!;
    totalLeaveCount.value = leaveTypes[type] ?? 0;
  }

  onStartDateSelect(dynamic date) {
    var selectedDate = DateFormat('dd-MM-yyyy').format(date as DateTime);
    startDate.value = selectedDate;
  }

  onEndDateSelect(dynamic date) {
    var selectedDate = DateFormat('dd-MM-yyyy').format(date as DateTime);
    endDate.value = selectedDate;
  }

  updateLeaveMode(int value) {
    leaveModeValue.value = value;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

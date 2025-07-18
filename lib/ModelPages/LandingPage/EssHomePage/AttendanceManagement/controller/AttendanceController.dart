import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/AttendanceReportModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/LeaveBalanceModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/models/TeamMemberModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/AttendanceManagement/widgets/WidgetProfileBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../Constants/AppStorage.dart';
import '../../../../../Constants/Const.dart';
import '../../../../../Constants/GlobalVariableController.dart';
import '../../../../../Utils/ServerConnections/ExecuteApi.dart';
import '../../../../../Utils/ServerConnections/ServerConnections.dart';

class AttendanceController extends GetxController {
  AppStorage appStorage = AppStorage();
  ServerConnections serverConnections = ServerConnections();
// topBar-control--------------
  final PageController pageController = PageController();
  final globalVariableController = Get.find<GlobalVariableController>();

  AttendanceController() {}

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

//--BottomSheet----
  var isBottomSheetLoading = false.obs;
  var teamMemberList = [].obs;
  profileBottomSheetInIt() {
    if (teamMemberList.isEmpty) {
      _getTeamMembers();
    }
  }

  _getTeamMembers() async {
    isBottomSheetLoading.value = true;
    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "publickey": ExecuteApi.API_PUBLICKEY_ATTENDANCE_TEAMMEMBERS,
      "Project": globalVariableController.PROJECT_NAME.value,
      "getsqldata": {"trace": "true"},
      "sqlparams": {"username": "EID001"}
    };
    var resp = await ExecuteApi().CallFetchData_ExecuteAPI(
      body: jsonEncode(body),
      isBearer: true,
    );

    var jsonResp = jsonDecode(resp);

    if (jsonResp["success"].toString() == "true") {
      teamMemberList.clear();
      var listItems = jsonResp["ds_get_team_members"]["rows"];
      for (var item in listItems) {
        var member = TeamMemberModel.fromJson(item);
        teamMemberList.add(member);
      }
    }
    isBottomSheetLoading.value = false;
  }
//-InOut tab--------

  inoutTabInIt() {}
  openProfileBottomSheet() {
    Get.bottomSheet(WidgetProfileBottomSheet(), isScrollControlled: true);
  }

  updateYear(dynamic date) {}

  _getInOutData() {}

//-Attendance------
  var attendanceReportList = [].obs;
  var isAttendanceReportLoading = false.obs;
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
    if (selectedYear.value == years[date]) return;
    selectedYear.value = years[date];
    _getAttendanceReport();
  }

  updateMonthIndex(int index) {
    if (selectedMonthIndex.value == index) return;
    selectedMonthIndex.value = index;
    _getAttendanceReport();
  }

  tabAttendanceInIt() {
    if (attendanceReportList.isEmpty) {
      _getAttendanceReport();
    }
  }

  _getAttendanceReport() async {
    isAttendanceReportLoading.value = true;
    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "publickey": ExecuteApi.API_PUBLICKEY_ATTENDANCE_ATTENDANCEREPORT,
      "Project": globalVariableController.PROJECT_NAME.value,
      "getsqldata": {"trace": "true"},
      "sqlparams": {"username": "EID001"}
    };
    var resp = await ExecuteApi().CallFetchData_ExecuteAPI(
      body: jsonEncode(body),
      isBearer: true,
    );

    var jsonResp = jsonDecode(resp);

    if (jsonResp["success"].toString() == "true") {
      attendanceReportList.clear();
      var listItems = jsonResp["ds_get_attendance_report"]["rows"];
      for (var item in listItems) {
        var reportItem = AttendanceReportModel.fromJson(item);
        attendanceReportList.add(reportItem);
      }
    }
    isAttendanceReportLoading.value = false;
  }

//leaves hub--------------

  var isLeavesHubLoading = false.obs;
  var totalLeaves = 0.obs;
  var totalBalanceLeaves = 0.obs;
  var totalLeaveData = [].obs;
  leavesHubInIt() {
    if (totalLeaveData.isEmpty) {
      _getLeaveBalanceData();
    }
  }

  _getLeaveBalanceData() async {
    isLeavesHubLoading.value = true;
    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "publickey": ExecuteApi.API_PUBLICKEY_ATTENDANCE_LEAVEDETAILS,
      "Project": globalVariableController.PROJECT_NAME.value,
      "getsqldata": {"trace": "true"},
      "sqlparams": {"username": "EID001"}
    };
    var resp = await ExecuteApi().CallFetchData_ExecuteAPI(
      body: jsonEncode(body),
      isBearer: true,
    );

    var jsonResp = jsonDecode(resp);

    if (jsonResp["success"].toString() == "true") {
      totalLeaveData.clear();
      var listItems = jsonResp["ds_get_leave_details"]["rows"];

      for (var item in listItems) {
        var leaveItem = LeaveBalanceModel.fromJson(item);
        totalLeaveData.add(leaveItem);
      }

      _setLeaveData();
    }
    isLeavesHubLoading.value = false;
  }

  _setLeaveData() {
    totalLeaves.value = 0;
    totalBalanceLeaves.value = 0;
    if (totalLeaveData.isNotEmpty) {
      for (LeaveBalanceModel item in totalLeaveData) {
        totalLeaves.value += int.parse(item.totalLeaves);
        totalBalanceLeaves.value += int.parse(item.balanceLeaves);
      }
    }
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

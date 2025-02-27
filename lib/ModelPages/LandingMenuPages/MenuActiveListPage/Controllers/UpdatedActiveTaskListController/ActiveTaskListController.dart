import 'dart:convert';

import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/UpdatedActiveTaskListModel/ActiveTaskListModel.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../Constants/AppStorage.dart';
import '../../../../../Constants/Const.dart';
import '../../../../../Constants/MyColors.dart';
import '../../../../../Utils/ServerConnections/ServerConnections.dart';

class ActiveTaskListController extends GetxController {
  //----
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  var body = {};
  var url = Const.getFullARMUrl(ServerConnections.API_GET_ALL_ACTIVE_TASKS);
  //----
  int pageNumber = 1;
  static const int pageSize = 40;
  var isListLoading = false.obs;
  var hasMoreData = true.obs;
  var isRefreshable = true.obs;
  var showFetchInfo = false.obs;
  var activeTaskList = [].obs;
  List<ActiveTaskListModel> activeTempList = [];
  //--------
  var activeTaskMap = {}.obs;
  //-----
  late ScrollController taskListScrollController;
  late List<ExpandedTileController> expandedListControllers;
  //-----

  //-----
  @override
  void onInit() {
    taskListScrollController = ScrollController();
    taskListScrollController.addListener(() {
      if (taskListScrollController.position.pixels >= taskListScrollController.position.minScrollExtent + 100) {
        isRefreshable.value = false;
      } else {
        isRefreshable.value = true;
      }

      if (taskListScrollController.position.pixels >= taskListScrollController.position.maxScrollExtent &&
          !isListLoading.value &&
          hasMoreData.value) {
        fetchActiveTaskLists();
      }

      if (taskListScrollController.position.pixels >= taskListScrollController.position.maxScrollExtent - 100 &&
          !hasMoreData.value) {
        showFetchInfo.value = true;
      } else {
        showFetchInfo.value = false;
      }
      ;
    });

    super.onInit();
  }

  init() {
    if (activeTaskList.isEmpty) {
      hasMoreData.value = true;
      fetchActiveTaskLists();
    }
    ;
  }

  refreshList() {
    pageNumber = 1;
    hasMoreData.value = true;
    taskListScrollController
        .animateTo(taskListScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 700), curve: Curves.decelerate)
        .then((_) {
      fetchActiveTaskLists(isRefresh: true);
    });
  }

  prepAPI({required int pageNo, required int pageSize}) {
    body = {
      'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
      "AxSessionId": "meecdkr3rfj4dg5g4131xxrt",
      "AppName": Const.PROJECT_NAME.toString(),
      "Trace": "false",
      "PageSize": pageSize,
      "PageNo": pageNo,
      "Filter": "all"
    };
  }

  Future<void> fetchActiveTaskLists({bool isRefresh = false}) async {
    if (!hasMoreData.value) return;
    LogService.writeLog(message: " fetchActiveTaskLists() => started");
    isListLoading.value = true;
    activeTempList = [];
    prepAPI(pageNo: pageNumber, pageSize: pageSize);
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);

    if (resp != "") {
      var jsonResp = jsonDecode(resp);

      if (jsonResp['result']['message'].toString().toLowerCase() == "success") {
        var activeList = jsonResp['result']['tasks'];

        for (var item in activeList) {
          ActiveTaskListModel activeListModel = ActiveTaskListModel.fromJson(item);
          activeTempList.add(activeListModel);
        }
      }
      if (activeTempList.isEmpty) {
        hasMoreData.value = false;
      } else {
        if (isRefresh) {
          activeTaskList.clear();
          activeTaskMap.value = {};
        }
        LogService.writeLog(message: "PageNumber: $pageNumber, PageSize: $pageSize, currentLength: ${activeTaskList.length}");

        activeTaskList.addAll(activeTempList);
        //-----------------------------------------
        // write one function to parse the below things
        activeTaskMap.value = {};
        for (var t in activeTaskList) {
          activeTaskMap.putIfAbsent(categorizeDate(t.eventdatetime.toString()), () => []).add(t);
        }

        //----------------------------------------

        //----------------------------------------

        pageNumber++;
      }
    }

    isListLoading.value = false;
  }

  String formatToDayTime(String dateString) {
    DateTime inputDate = DateFormat("dd/MM/yyyy HH:mm:ss").parse(dateString);
    String category = categorizeDate(dateString);

    if (category == "Today" || category == "Yesterday") {
      return DateFormat('h:mm a').format(inputDate);
    } else if (category == "This Week" || category == "Last Week") {
      return DateFormat('E d').format(inputDate);
    } else {
      return DateFormat('E M/yy').format(inputDate);
    }
  }

  String categorizeDate(String dateString) {
    DateTime inputDate = DateFormat("dd/MM/yyyy HH:mm:ss").parse(dateString);
    DateTime now = DateTime.now();

    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    DateTime lastWeekStart = startOfWeek.subtract(Duration(days: 7));
    DateTime lastWeekEnd = startOfWeek.subtract(Duration(days: 1));

    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastMonthStart = DateTime(now.year, now.month - 1, 1);
    DateTime lastMonthEnd = startOfMonth.subtract(Duration(days: 1));

    if (inputDate.isAfter(today)) {
      return "Today";
    } else if (inputDate.isAfter(yesterday)) {
      return "Yesterday";
    } else if (inputDate.isAfter(startOfWeek)) {
      return "This Week";
    } else if (inputDate.isAfter(lastWeekStart) && inputDate.isBefore(lastWeekEnd)) {
      return "Last Week";
    } else if (inputDate.isAfter(startOfMonth)) {
      return "This Month";
    } else if (inputDate.isAfter(lastMonthStart) && inputDate.isBefore(lastMonthEnd)) {
      return "Last Month";
    } else {
      return DateFormat('MMM yyyy').format(inputDate);
    }
  }

  List<TextSpan> formatDateTimeSpan(String formattedDate) {
    final regex = RegExp(r'(\d{1,2}:\d{2})\s?(AM|PM)');
    final match = regex.firstMatch(formattedDate);

    if (match != null) {
      String timePart = match.group(1)!;
      String amPmPart = match.group(2)!;
      String prefix = formattedDate.replaceAll(match.group(0)!, '').trim();

      return [
        TextSpan(text: '$prefix '),
        TextSpan(text: timePart),
        TextSpan(
          text: ' $amPmPart',
          style: GoogleFonts.poppins(
            fontSize: 8,
            color: MyColors.grey9,
            // color: Color(0xff666D80),
            fontWeight: FontWeight.w600,
          ),
        ),
      ];
    } else {
      return [
        TextSpan(
          text: formattedDate,
        )
      ];
    }
  }
}

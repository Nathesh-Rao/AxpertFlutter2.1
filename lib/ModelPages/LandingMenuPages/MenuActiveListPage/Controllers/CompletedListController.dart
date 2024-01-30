import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingListModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingProcessFlowModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingTaskModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompletedListController extends GetxController {
  var subPage = true.obs;
  var needRefresh = true.obs;
  var pending_activeList = [].obs;
  var completedCount = "0";

  var selectedIconNumber = 1.obs; //1->default, 2-> reload, 3->accesstime, 4-> filter, 5=> checklist
  PendingTaskModel? completedTaskModel;
  List<PendingListModel> activeList_Main = [];
  PendingListModel? openModel;
  String selectedTaskID = "";
  var processFlowList = [].obs;
  TextEditingController searchController = TextEditingController();
  var statusListActiveIndex = 2;
  ScrollController scrollController = ScrollController(initialScrollOffset: 100 * 3.0);
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  var widgetProcessFlowNeedRefresh = true.obs;

  TextEditingController dateFromController = TextEditingController();
  TextEditingController dateToController = TextEditingController();
  TextEditingController searchTextController = TextEditingController();
  TextEditingController processNameController = TextEditingController();
  TextEditingController fromUserController = TextEditingController();
  var errDateFrom = "".obs;
  var errDateTo = "".obs;

  CompletedListController() {
    // print("-----------CompletedListController Called-------------");
    getNoOfCompletedActiveTasks();
    // getPendingActiveList();
  }

  Future<void> getNoOfCompletedActiveTasks() async {
    LoadingScreen.show();
    var url = Const.getFullARMUrl_SecondServer(ServerConnections.API_GET_COMPLETED_ACTIVETASK_COUNT);
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['message'].toString() == "success") {
        completedCount = jsonResp['result']['data'].toString();
      }
    }
    await getPendingActiveList();
    LoadingScreen.dismiss();
  }

  Future<void> getPendingActiveList() async {
    var url = Const.getFullARMUrl_SecondServer(ServerConnections.API_GET_COMPLETED_ACTIVETASK);
    var body = {
      'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
      "Trace": "false",
      "AppName": Const.PROJECT_NAME.toString(),
      "pagesize": int.parse(completedCount),
      "pageno": 1,
    };

    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['message'].toString() == "success") {
        activeList_Main.clear();
        var dataList = jsonResp['result']['completedtasks'];

        for (var item in dataList) {
          PendingListModel pendingActiveListModel = PendingListModel.fromJson(item);
          activeList_Main.add(pendingActiveListModel);
        }
      }
      pending_activeList.value = activeList_Main;
      needRefresh.value = true;
    }
  }

  String getDateValue(String? eventdatetime) {
    var parts = eventdatetime!.split(' ');
    return parts[0].trim() ?? "";
  }

  String getTimeValue(String? eventdatetime) {
    var parts = eventdatetime!.split(' ');
    return parts[1].trim() ?? "";
  }

  filterList(value) {
    value = value.toString().trim();
    needRefresh.value = true;
    if (value == "") {
      pending_activeList.value = activeList_Main;
      FocusManager.instance.primaryFocus?.unfocus();
    } else {
      needRefresh.value = true;
      var newList = activeList_Main.where((oldValue) {
        return oldValue.displaytitle.toString().toLowerCase().contains(value.toString().toLowerCase()) ||
            oldValue.eventdatetime.toString().toLowerCase().contains(value.toString().toLowerCase());
      });
      // print("new list: " + newList.length.toString());
      pending_activeList.value = newList.toList();
    }
  }

  void clearCalled() {
    searchController.text = "";
    filterList("");
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

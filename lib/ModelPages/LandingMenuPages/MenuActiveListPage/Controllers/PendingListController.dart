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

class PendingListController extends GetxController {
  var subPage = true.obs;
  var needRefresh = true.obs;
  var pending_activeList = [].obs;
  var pendingCount = "0";

  var selectedIconNumber = 1.obs; //1->default, 2-> reload, 3->accesstime, 4-> filter, 5=> checklist
  // PendingTaskModel? pendingTaskModel;
  List<PendingListModel> activeList_Main = [];
  // PendingListModel? openModel;
  // String selectedTaskID = "";
  // var processFlowList = [].obs;
  TextEditingController searchController = TextEditingController();
  var statusListActiveIndex = 2;
  // ScrollController scrollController = ScrollController(initialScrollOffset: 100 * 3.0);
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  // var widgetProcessFlowNeedRefresh = true.obs;

  TextEditingController dateFromController = TextEditingController();
  TextEditingController dateToController = TextEditingController();
  TextEditingController searchTextController = TextEditingController();
  TextEditingController processNameController = TextEditingController();
  TextEditingController fromUserController = TextEditingController();
  var errDateFrom = "".obs;
  var errDateTo = "".obs;

  PendingListController() {
    // print("-----------PendingListController Called-------------");
    getNoOfPendingActiveTasks();
    // getPendingActiveList();
  }
  Future<void> getNoOfPendingActiveTasks() async {
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_PENDING_ACTIVETASK_COUNT);
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['message'].toString() == "success") {
        pendingCount = jsonResp['result']['data'].toString();
      }
    }
    await getPendingActiveList();
    LoadingScreen.dismiss();
  }

  Future<void> getPendingActiveList() async {
    var url = Const.getFullARMUrl(ServerConnections.API_GET_PENDING_ACTIVETASK);
    var body = {
      'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
      "Trace": "false",
      "AppName": Const.PROJECT_NAME.toString(),
      "pagesize": int.parse(pendingCount),
      "pageno": 1,
    };

    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['message'].toString() == "success") {
        activeList_Main.clear();
        var dataList = jsonResp['result']['pendingtasks'];

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

  ////////////////////////************************** Pending List Item Details *****************

  void applyFilter() async {
    var url = Const.getFullARMUrl(ServerConnections.API_GET_FILTERED_PENDING_TASK);
    Map<String, dynamic> body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "AppName": Const.PROJECT_NAME.toString(),
      "pagesize": 1000,
      "pageno": 1,
    };
    if (fromUserController.text.trim() != "") body["fromuser"] = fromUserController.text.trim();
    if (processNameController.text.trim() != "") body["processname"] = processNameController.text.trim();
    if (searchTextController.text.trim() != "") body["searchtext"] = searchTextController.text.trim();
    if (dateFromController.text.trim() != "" && dateToController.text.trim() != "") {
      body["fromdate"] = dateFromController.text.trim();
      body["todate"] = dateToController.text.trim();
    } else {
      if (dateFromController.text.trim() == "" && dateToController.text.trim() != "") {
        errDateFrom.value = "Enter from Date";
        return;
      }
      if (dateFromController.text.trim() != "" && dateToController.text.trim() == "") {
        errDateTo.value = "Enter To Date";
        return;
      }
    }
    Get.back();
    print(body.length);
    if (body.length > 4) {
      selectedIconNumber.value = 4;
      LoadingScreen.show();
      var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
      LoadingScreen.dismiss();
      if (resp != "" && !resp.toString().contains("error")) {
        var jsonResp = jsonDecode(resp);
        if (jsonResp['result']['message'].toString() == "success") {
          var taskList = jsonResp['result']['pendingtasks'];
          pending_activeList.clear();
          for (var item in taskList) {
            PendingListModel activeListModel = PendingListModel.fromJson(item);
            pending_activeList.add(activeListModel);
          }
          if (pending_activeList.length == 0) {
            pending_activeList.value = activeList_Main;
            Get.snackbar("Oops!", "No details found!",
                duration: Duration(seconds: 1),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white);
          }
          needRefresh.value = true;
        }
      }
    }
  }

  void removeFilter() {
    dateFromController.text =
        dateToController.text = searchTextController.text = processNameController.text = fromUserController.text = "";
    if (selectedIconNumber != 1) getNoOfPendingActiveTasks();
    selectedIconNumber.value = 1;
  }

  errText(String value) {
    if (value == "")
      return null;
    else
      return value;
  }

  // void refreshList() async {
  //   LoadingScreen.show();
  //   if (selectedIconNumber.value != 1) {
  //     await getNoOfPendingActiveTasks();
  //   }
  //   selectedIconNumber.value = 1;
  //
  //   Future.delayed(Duration(milliseconds: 500), () {
  //     LoadingScreen.dismiss();
  //   });
  // }
}

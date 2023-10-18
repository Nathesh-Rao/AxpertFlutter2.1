import 'dart:convert';

import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/ActiveListModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/StatusModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../Constants/AppStorage.dart';
import '../../../../Constants/const.dart';
import '../../../../Utils/ServerConnections/ServerConnections.dart';

class PendingListController extends GetxController {
  var subPage = true.obs;
  var needRefresh = true.obs;
  var pending_activeList = [].obs;
  List<ActiveListModel> activeList_Main = [];
  List<StatusModel> StatusList = [
    StatusModel("1", "Ticket Initiation"),
    StatusModel("2", "Support Check"),
    StatusModel("3", "RM Approval"),
    StatusModel("4", "Approval By Developer"),
  ];
  TextEditingController searchController = TextEditingController();
  var statusListActiveIndex = 3;

  ScrollController scrollController = ScrollController(initialScrollOffset: 100 * 3.0);
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();

  PendingListController() {
    print("-----------PendingListController Called-------------");
    getPendingActiveList();
  }

  Future<void> getPendingActiveList() async {
    var url = Const.getFullARMUrl(ServerConnections.API_GET_PENDING_ACTIVELIST);
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['message'].toString() == "success") {
        activeList_Main.clear();
        var dataList = jsonDecode(jsonResp['result']['data']);
        for (var item in dataList) {
          ActiveListModel activeListModel = ActiveListModel.fromJson(item);
          activeList_Main.add(activeListModel);
        }
      }
      pending_activeList.value = activeList_Main;
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
        return oldValue.displaytitle.toString().toLowerCase().contains(value.toString().toLowerCase());
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

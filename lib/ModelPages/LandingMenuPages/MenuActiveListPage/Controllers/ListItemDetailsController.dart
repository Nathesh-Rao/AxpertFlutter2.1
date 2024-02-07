import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingListModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingProcessFlowModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingTaskModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ListItemDetailsController extends GetxController {
  AppStorage appStorage = AppStorage();
  String selectedTaskID = "";
  PendingListModel? openModel;
  var widgetProcessFlowNeedRefresh = true.obs;
  PendingTaskModel? pendingTaskModel;
  ServerConnections serverConnections = ServerConnections();
  var processFlowList = [].obs;
  ScrollController scrollController = ScrollController(initialScrollOffset: 100 * 3.0);

  fetchDetails({hasArgument = false, PendingProcessFlowModel? pendingProcessFlowModel = null}) async {
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_ACTIVETASK_DETAILS);
    var body;
    var shouldCall = true;
    if (hasArgument) {
      if (pendingProcessFlowModel!.taskid.toString() == "" || pendingProcessFlowModel!.taskid.toString().toLowerCase() == "null")
        shouldCall = false;

      body = {
        'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
        "AppName": Const.PROJECT_NAME.toString(),
        "processname": pendingProcessFlowModel!.processname,
        "tasktype": pendingProcessFlowModel!.tasktype,
        "taskid": pendingProcessFlowModel!.taskid,
        "keyvalue": pendingProcessFlowModel!.keyvalue,
      };
      selectedTaskID = pendingProcessFlowModel!.taskid;
    } else {
      if (openModel!.taskid.toString() == "" || openModel!.taskid.toString().toLowerCase() == "null") shouldCall = false;
      body = {
        'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
        "AppName": Const.PROJECT_NAME.toString(),
        "processname": openModel!.processname,
        "tasktype": openModel!.tasktype,
        "taskid": openModel!.taskid,
        "keyvalue": openModel!.keyvalue
      };
      selectedTaskID = openModel!.taskid;
    }
    if (!shouldCall) {
      widgetProcessFlowNeedRefresh.value = true;
      LoadingScreen.dismiss();
      pendingTaskModel = null;
      return;
    }

    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['message'].toString() == "success") {
        //process Flow ********************************
        if (!hasArgument) {
          var dataList = jsonResp['result']['processflow'];
          processFlowList.clear();
          for (var item in dataList) {
            PendingProcessFlowModel processFlowModel = PendingProcessFlowModel.fromJson(item);
            processFlowList.add(processFlowModel);
          }
        }

        // Task details *************************
        // var taskList = jsonResp['result']['taskdetails'];
        // for (var task in taskList) {
        //
        // }
        var task = jsonResp['result']['taskdetails'][0];
        if (task != null)
          pendingTaskModel = PendingTaskModel.fromJson(task);
        else {
          pendingTaskModel = null;
          // Get.snackbar("Oops!", "No details found!",
          //     duration: Duration(seconds: 1),
          //     snackPosition: SnackPosition.BOTTOM,
          //     backgroundColor: Colors.redAccent,
          //     colorText: Colors.white);
        }
      }
    }
    // print("Length: ${processFlowList.length}");
    widgetProcessFlowNeedRefresh.value = true;
    LoadingScreen.dismiss();
  }

  String getDateValue(String? eventdatetime) {
    var parts = eventdatetime!.split(' ');
    return parts[0].trim() ?? "";
  }

  String getTimeValue(String? eventdatetime) {
    var parts = eventdatetime!.split(' ');
    return parts[1].trim() ?? "";
  }
}

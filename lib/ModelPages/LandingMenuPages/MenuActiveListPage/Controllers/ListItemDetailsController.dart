import 'dart:convert';
import 'dart:developer';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/Constants/Const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/CompletedListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingListModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingProcessFlowModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingTaskModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Constants/GlobalVariableController.dart';

class ListItemDetailsController extends GetxController {
  final globalVariableController = Get.find<GlobalVariableController>();
  AppStorage appStorage = AppStorage();
  String selectedTaskID = "";
  PendingListModel? openModel;
  var widgetProcessFlowNeedRefresh = true.obs;
  PendingTaskModel? pendingTaskModel;
  ServerConnections serverConnections = ServerConnections();
  var processFlowList = [].obs;
  ScrollController scrollController = ScrollController(initialScrollOffset: 100 * 3.0);
  TextEditingController comments = TextEditingController();
  var errCom = ''.obs;
  var selected_processFlow_taskType = ''.obs;

  var ddSelectedValue = "Initiator".obs;
  var ddSendToUsers_SelectedValue = "".obs;
  var sendToUsersList = [].obs;
  //bool isKeyboardVisible = false;

  /*@override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    bool newKeyboardState = bottomInset > 0;

    if (isKeyboardVisible != newKeyboardState) {
      isKeyboardVisible = newKeyboardState;
      update(); // Update controller state, NOT the UI
    }
  }*/

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
        "AppName": globalVariableController.PROJECT_NAME.value.toString(),
        "processname": pendingProcessFlowModel!.processname,
        "tasktype": pendingProcessFlowModel!.tasktype,
        "taskid": pendingProcessFlowModel!.taskid,
        "keyvalue": pendingProcessFlowModel!.keyvalue,
      };
      selectedTaskID = pendingProcessFlowModel!.taskid;
      selected_processFlow_taskType.value = pendingProcessFlowModel!.tasktype;
    } else {
      if (openModel!.taskid.toString() == "" || openModel!.taskid.toString().toLowerCase() == "null") shouldCall = false;
      body = {
        'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID),
        "AppName": globalVariableController.PROJECT_NAME.value.toString(),
        "processname": openModel!.processname,
        "tasktype": openModel!.tasktype,
        "taskid": openModel!.taskid,
        "keyvalue": openModel!.keyvalue
      };
      selectedTaskID = openModel!.taskid;
      selected_processFlow_taskType.value = openModel!.tasktype;
    }
    if (!shouldCall) {
      widgetProcessFlowNeedRefresh.value = true;
      LoadingScreen.dismiss();
      pendingTaskModel = null;
      return;
    }

    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    log("Fetch details => ${resp.toString()}");
    if (resp != "") {
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

        try {
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
        } catch (e) {
          pendingTaskModel = null;
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

  void actionApproveOrRejectOrCheck(bool hasComments, action) async {
    print("Approve called 1");
    errCom.value = "";
    // if (hasComments) {
    //   if (comments.text.toString().trim() == "") errCom.value = "Please enter comments";
    //   return;
    // }
    print("Approve called 2");

    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "TaskId": pendingTaskModel!.taskid ?? "",
      "TaskType": pendingTaskModel!.tasktype ?? "",
      "Action": action,
      "StatusReason": "Approved by Manager",
      "StatusText": comments.text.toString().trim(),
    };
    print("Approve called 3");

    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_DO_TASK_ACTIONS);
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    print(resp.toString());
    LoadingScreen.dismiss();
    if (!resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString().toLowerCase() == "true") {
        PendingListController pendingListController = Get.find();
        CompletedListController completedListController = Get.find();
        pendingListController.getNoOfPendingActiveTasks();
        completedListController.getNoOfCompletedActiveTasks();
        Get.back();
        Get.back();
        showSuccessSnack("Done!", "Action Performed Successfully");
      } else {
        Get.back();
        showErrorSnack("Oops!", "Some Error Occured");
      }
    } else {
      showErrorSnack("Oops!", "Some Error Occured");
    }
  }

  void actionReturn(bool hasComments) async {
    errCom.value = "";
    if (hasComments) {
      if (comments.text.toString().trim() == "") errCom.value = "Please enter comments";
      return;
    }

    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "TaskId": pendingTaskModel!.taskid ?? "",
      "TaskType": pendingTaskModel!.tasktype ?? "",
      "Action": "Return",
      "StatusReason": "Performed by user",
      "StatusText": comments.text,
      "ReturnTo": ddSelectedValue.value
    };
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_DO_TASK_ACTIONS);
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    LoadingScreen.dismiss();
    if (!resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString().toLowerCase() == "true") {
        PendingListController pendingListController = Get.find();
        CompletedListController completedListController = Get.find();
        pendingListController.getNoOfPendingActiveTasks();
        completedListController.getNoOfCompletedActiveTasks();
        Get.back();
        Get.back();
        showSuccessSnack("Done!", "Action Performed Successfully");
      } else {
        Get.back();
        showErrorSnack("Oops!", "Some Error Occured");
      }
    } else {
      showErrorSnack("Oops!", "Some Error Occured");
    }
  }

  void actionSend(bool hasComments) async {
    errCom.value = "";
    if (hasComments) {
      if (comments.text.toString().trim() == "") errCom.value = "Please enter comments";
      return;
    }

    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "TaskId": pendingTaskModel!.taskid ?? "",
      "TaskType": pendingTaskModel!.tasktype ?? "",
      "Action": "Send",
      "StatusReason": "Performed by user",
      "StatusText": comments.text,
      "SendTo": ddSendToUsers_SelectedValue
    };
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_DO_TASK_ACTIONS);
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    LoadingScreen.dismiss();
    if (!resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString().toLowerCase() == "true") {
        PendingListController pendingListController = Get.find();
        CompletedListController completedListController = Get.find();
        pendingListController.getNoOfPendingActiveTasks();
        completedListController.getNoOfCompletedActiveTasks();
        Get.back();
        Get.back();
        showSuccessSnack("Done!", "Action Performed Successfully");
      } else {
        Get.back();
        showErrorSnack("Oops!", "Some Error Occured");
      }
    } else {
      showErrorSnack("Oops!", "Some Error Occured");
    }
  }

  void onProcessFlowItemTap(int index) {
    selected_processFlow_taskType.value = processFlowList[index].tasktype.toString();
  }

  showSuccessSnack(title, Message) {
    Get.snackbar(title, Message,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  showErrorSnack(title, Message) {
    Get.snackbar(title, Message,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  dropdownMenuItem() {
    List<DropdownMenuItem<String>> myList = [];

    myList.add(DropdownMenuItem(
      value: "Initiator",
      child: Text("Initiator"),
    ));

    myList.add(DropdownMenuItem(
      value: "Previous Level",
      child: Text("Previous Level"),
    ));

    return myList;
  }

  dropDownItemChanged(String? value) {
    if (value != null) ddSelectedValue.value = value;
  }

  dropdownMenuItem_sendToUsers() {
    List<DropdownMenuItem<String>> myList = [];
    for (var item in sendToUsersList) {
      DropdownMenuItem<String> dditem = DropdownMenuItem(
        value: item.toString(),
        child: Text(item),
      );
      myList.add(dditem);
    }
    return myList;
  }

  dropDownItemChanged_SendToUsers(Object? value) {
    if (value != null) ddSendToUsers_SelectedValue.value = value.toString();
  }

  getSendToUsers_List() async {
    sendToUsersList.clear();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_SENDTOUSERS);
    var body = {
      "ARMSessionId": appStorage.retrieveValue(AppStorage.SESSIONID),
      "TaskId": pendingTaskModel!.taskid ?? "",
      "TaskType": pendingTaskModel!.tasktype ?? "",
      "TaskName": pendingTaskModel!.taskname ?? "",
      "KeyValue": pendingTaskModel!.keyvalue ?? ""
    };
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    LoadingScreen.dismiss();
    if (!resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString().toLowerCase() == "true") {
        var jsonData = jsonDecode(resp)['result']['data'] as List;
        sendToUsersList.clear();
        for (var item in jsonData) {
          String val = item["pusername"].toString();
          sendToUsersList.add(val);
        }
        // sendToUsersList..sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
        if (ddSendToUsers_SelectedValue.value == "") {
          ddSendToUsers_SelectedValue.value = sendToUsersList[0];
          dropDownItemChanged_SendToUsers(ddSendToUsers_SelectedValue);
        }
      } else {
        Get.back();
        showErrorSnack("Oops!", jsonResp['result']['message'].toString());
      }
    } else {
      showErrorSnack("Oops!", "Some Error Occured");
    }
  }

  void historyBtnClicked() {
    var url = "aspx/AxMain.aspx?authKey=AXPERT-" +
        appStorage.retrieveValue(AppStorage.SESSIONID) +
        "&pname=ipegtaskh&params=~pkeyvalue=" +
        pendingTaskModel!.keyvalue +
        "~pprocess=" +
        pendingTaskModel!.processname;

    var urlNew = "aspx/AxMain.aspx?authKey=AXPERT-" +
        appStorage.retrieveValue(AppStorage.SESSIONID) +
        "&pname=iad___pth&params=pkeyvalue~" +
        pendingTaskModel!.keyvalue +
        "^pprocess~" +
        pendingTaskModel!.processname;
    Get.toNamed(Routes.InApplicationWebViewer, arguments: [Const.getFullWebUrl(urlNew)]);
  }

  void viewBtnClicked() {
    var url = "aspx/AxMain.aspx?authKey=AXPERT-" +
        appStorage.retrieveValue(AppStorage.SESSIONID) +
        "&pname=t" +
        pendingTaskModel!.transid +
        "&params=~act=load~recordid=" +
        pendingTaskModel!.recordid;
    var urlNew = "aspx/AxMain.aspx?authKey=AXPERT-" +
        appStorage.retrieveValue(AppStorage.SESSIONID) +
        "&pname=t" +
        pendingTaskModel!.transid +
        "&params=act~load^recordid~" +
        pendingTaskModel!.recordid;
    Get.toNamed(Routes.InApplicationWebViewer, arguments: [Const.getFullWebUrl(urlNew)]);
  }
}

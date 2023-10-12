import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Models/MenuItemModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class MenuMorePageController extends GetxController {
  var needRefresh = true.obs;
  TextEditingController searchController = TextEditingController();
  AppStorage appStorage = AppStorage();
  ServerConnections serverConnections = ServerConnections();
  List<MenuItemModel> menuListMain = [];
  Set menuHeadersMain = {}; //master
  var headingWiseData = {}; //map  //Master

  var fetchData = {}.obs;
  var fetchList = [].obs;
  var colorList = [
    HexColor("#63168F"),
    HexColor("#081F4D"),
    HexColor("#038387"),
    HexColor("#FF781E"),
    HexColor("#6264A7"),
    HexColor("#98B5CD"),
    HexColor("#6264A7"),
    HexColor("#8C193F"),
  ];
  var IconList = [
    Icons.calendar_month_outlined,
    Icons.today_outlined,
    Icons.date_range_outlined,
    Icons.event_repeat_outlined,
    Icons.perm_contact_calendar_outlined,
    Icons.event_note_outlined,
    Icons.event_available_outlined,
    Icons.event_busy_outlined,
  ];

  MenuMorePageController() {
    getMenuList();
  }

  getMenuList() async {
    var mUrl = Const.getFullARMUrl(ServerConnections.getARMMenuEntryPoint);
    var conectBody = {'ARMSessionId': appStorage.retrieveValue(AppStorage.sessionId)};
    var cHeader = {
      'Content-Type': "application/json",
      'Authorization': 'Bearer ' + appStorage.retrieveValue(AppStorage.token)
    };
    var menuResp = await serverConnections.postToServer(url: mUrl, body: jsonEncode(conectBody), header: cHeader);

    if (menuResp != "" && !menuResp.toString().contains("error")) {
      var menuJson = jsonDecode(menuResp);
      if (menuJson['result']['success'].toString() == "true") {
        for (var menuItem in menuJson['result']["pages"]) {
          MenuItemModel mi = MenuItemModel.fromJson(menuItem);
          menuListMain.add(mi);
        }
      }
    }
    reOrganise(menuListMain);
  }

  reOrganise(menuList) {
    menuHeadersMain.clear();
    headingWiseData.clear();
    for (var item in menuList) {
      var rootNode = item.rootnode == "" ? "Home" : item.rootnode;
      menuHeadersMain.add(rootNode);
      List<MenuItemModel> list = [];
      list = headingWiseData[rootNode] ?? [];
      list.add(item);
      headingWiseData[rootNode] = list;
    }
    //create for display
    fetchList.value = menuHeadersMain.toList();
    fetchData.value = headingWiseData;
  }

  getSubmenuItemList(int mainIndex) {
    return headingWiseData[menuHeadersMain.toList()[mainIndex]];
  }

  filterList(value) {
    value = value.toString().trim();
    needRefresh.value = true;
    if (value == "")
      reOrganise(menuListMain);
    else {
      needRefresh.value = true;
      var newList = menuListMain.where((oldValue) {
        return oldValue.caption.toString().toLowerCase().contains(value.toString().toLowerCase());
      });
      print("new list: " + newList.length.toString());
      reOrganise(newList);
    }
  }

  futureBuilder() async {
    // await Future.delayed(Duration(microseconds: 2));
    // reOrganise(menuListMain)
    return fetchList.value;
  }

  clearCalled() {
    searchController.text = "";
    filterList("");
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

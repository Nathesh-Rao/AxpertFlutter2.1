import 'dart:convert';
import 'dart:math';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/CardModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/CardOptionModel.dart';
import 'package:axpertflutter/Utils/ServerConnections/InternetConnectivity.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuHomePageController extends GetxController {
  InternetConnectivity internetConnectivity = Get.find();
  var colorList = ["#EEF2FF", "#FFF9E7", "#F5EBFF", "#FFECF6", "#E5F5FA", "#E6FAF4", "#F7F7F7", "#E8F5F8"];
  var listOfCards = [].obs;
  var actionData = {};
  Set setOfDatasource = {};
  var switchPage = false.obs;
  var webUrl = "";

  var isLoading = true.obs;
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();
  var body, header;

  MenuHomePageController() {
    body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.SESSIONID)};
    getCardDetails();
  }

  showMenuDialog(CardModel cardModel) {
    Get.dialog(Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 300,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.only(left: 30, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
              child: Center(
                child: Text(
                  cardModel.caption,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  getCardDetails() async {
    isLoading.value = true;
    LoadingScreen.show();
    var url = Const.getFullARMUrl(ServerConnections.API_GET_HOMEPAGE_CARDS);
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), isBearer: true);
    // print(resp);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString() == "true") {
        listOfCards.clear();
        var dataList = jsonResp['result']['data'];
        for (var item in dataList) {
          CardModel cardModel = CardModel.fromJson(item);
          listOfCards.add(cardModel);
          setOfDatasource.add(item['datasource'].toString());
        }
      } else {
        //error
      }
    }

    if (listOfCards.length == 0) {
      print("Length:   0");
      // Get.defaultDialog(
      //     title: "Alert!",
      //     middleText: "Session Timed Out",
      //     confirm: ElevatedButton(
      //         onPressed: () {
      //           Get.back();
      //         },
      //         child: Text("Ok")));
    }
    await getCardDataSources();
    listOfCards..sort((a, b) => a.caption.toString().toLowerCase().compareTo(b.caption.toString().toLowerCase()));
    isLoading.value = false;
    LoadingScreen.dismiss();
    return listOfCards;
  }

  getCardDataSources() async {
    if (actionData.length > 1) {
      return actionData;
    } else {
      // var dataSourceUrl = baseUrl + GlobalConfiguration().get("HomeCardDataResponse").toString();
      var dataSourceUrl = Const.getFullARMUrl(ServerConnections.API_GET_HOMEPAGE_CARDSDATASOURCE);
      var dataSourceBody = body;
      dataSourceBody["sqlParams"] = {"param": "value"};

      actionData.clear();
      for (var items in setOfDatasource) {
        if (items.toString() != "") {
          dataSourceBody["datasource"] = items;
          // setOfDatasource.remove(items);
          var dsResp = await serverConnections.postToServer(url: dataSourceUrl, isBearer: true, body: jsonEncode(dataSourceBody));
          if (dsResp != "") {
            var jsonDSResp = jsonDecode(dsResp);
            // print(jsonDSResp);
            if (jsonDSResp['result']['success'].toString() == "true") {
              var dsDataList = jsonDSResp['result']['data'];
              for (var item in dsDataList) {
                var list = [];
                list = actionData[item['cardname']] != null ? actionData[item['cardname']] : [];
                CardOptionModel cardOptionModel = CardOptionModel.fromJson(item);

                if (list.indexOf(cardOptionModel) < 0) list.add(cardOptionModel);
                actionData[item['cardname']] = list;
              }
            }
          }
        }
      }
    }
  }

  void openBtnAction(String btnType, String btnOpen) async {
    if (await internetConnectivity.connectionStatus) {
      print("hit $btnType");
      print("pname: $btnOpen");
      if (btnType.toLowerCase() == "button" && btnOpen != "") {
        webUrl = Const.getFullProjectUrl("aspx/AxMain.aspx?authKey=AXPERT-") +
            appStorage.retrieveValue(AppStorage.SESSIONID) +
            "&pname=" +
            btnOpen;
        switchPage.toggle();
      } else {}
    }
  }

  String getCardBackgroundColor(String colorCode) {
    final _random = new Random();
    return !["", null, "null"].contains(colorCode) ? colorCode : colorList[_random.nextInt(colorList.length)];
  }
}

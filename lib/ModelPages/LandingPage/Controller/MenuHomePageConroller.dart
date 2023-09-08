import 'dart:convert';

import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Models/CardModel.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetNotification.dart';
import 'package:axpertflutter/Utils/ServerConnections/ServerConnections.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class MenuHomePageController extends GetxController {
  var carouselIndex = 0.obs;
  var listOfCards = [].obs;
  var isLoading = true.obs;
  final CarouselController carouselController = CarouselController();
  ServerConnections serverConnections = ServerConnections();
  AppStorage appStorage = AppStorage();

  MenuHomePageController() {
    getCardDetails();
  }

  var list = [
    WidgetNotification("1"),
    WidgetNotification("2"),
    WidgetNotification("3"),
    WidgetNotification("4"),
    WidgetNotification("5"),
    WidgetNotification("6"),
  ];

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
    EasyLoading.show(status: "Please Wait...", maskType: EasyLoadingMaskType.black);
    var url = Const.getFullARMUrl(ServerConnections.getHomePageCardsEntryPoint);
    var body = {'ARMSessionId': appStorage.retrieveValue(AppStorage.sessionId)};
    var header = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ' + appStorage.retrieveValue(AppStorage.token),
    };
    var resp = await serverConnections.postToServer(url: url, body: jsonEncode(body), header: header);
    print(resp);
    if (resp != "" && !resp.toString().contains("error")) {
      var jsonResp = jsonDecode(resp);
      if (jsonResp['result']['success'].toString() == "true") {
        listOfCards.clear();
        var dataList = jsonResp['result']['data'];
        for (var item in dataList) {
          CardModel cardModel = CardModel.fromJson(item);
          listOfCards.add(cardModel);
        }
      } else {
        //error
      }
    }
    EasyLoading.dismiss();
    isLoading.value = false;
    refresh();
    return listOfCards;
  }
}

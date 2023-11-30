import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:axpertflutter/Constants/const.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/CardModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Widgets/WidgetOptionListTile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class WidgetCard extends StatelessWidget {
  WidgetCard(this.cardModel, {super.key});

  CardModel cardModel;
  AppStorage appStorage = AppStorage();
  MenuHomePageController menuHomePageController = Get.find();

  // MenuHomePageController menuHomePageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(10),
      height: 50,
      decoration: BoxDecoration(
          color: HexColor(menuHomePageController.getCardBackgroundColor(cardModel.colorcode.trim())), // ?? "ffffff"),
          borderRadius: BorderRadius.circular(10),
          // boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 20)] ,
          border:
              Border.all(width: 2, color: HexColor(menuHomePageController.getCardBackgroundColor(cardModel.colorcode.trim())))),
      child: Padding(
        padding: EdgeInsets.only(left: 20, top: 10, right: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: CachedNetworkImage(
                    imageUrl: Const.getFullProjectUrl("CustomPages/icons/homepageicon/") + cardModel.caption + '.png',
                    errorWidget: (context, url, error) =>
                        Image.network(Const.getFullProjectUrl('CustomPages/icons/homepageicon/default.png')),
                    width: 40,
                  ),
                ),
                Visibility(
                  visible: menuHomePageController.actionData[cardModel.caption] == null ? false : true,
                  child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => showMenuDialog(cardModel),
                        icon: Icon(Icons.more_vert),
                      )),
                ),
              ],
            ),
            menuHomePageController.actionData[cardModel.caption] == null ? SizedBox(height: 10) : SizedBox(height: 4),
            GestureDetector(
              onTap: () => captionOnTapFunction(cardModel),
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 2, right: 5),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    cardModel.caption,
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor("#444444"))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showMenuDialog(CardModel cardModel) {
    List optionLists =
        menuHomePageController.actionData[cardModel.caption] == null ? [] : menuHomePageController.actionData[cardModel.caption];
    if (!optionLists.isEmpty) {
      Get.dialog(Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            // margin: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
                  child: Center(
                    child: Text(
                      cardModel.caption,
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
                Column(
                  children: [
                    for (var item in optionLists) WidgetOptionListTile(item),
                  ],
                ),
                // ListView.separated(
                //     physics: NeverScrollableScrollPhysics(),
                //     itemBuilder: (context, index) {
                //       return WidgetOptionListTile(optionLists[index], sessionId, webUrl);
                //     },
                //     separatorBuilder: (context, index) => Container(),
                //     itemCount: optionLists.length),
                Container(
                  height: 50,
                  decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: Colors.grey))),
                  child: cardModel.moreoption.toString() == ""
                      ? null
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: decodeMoreOptopns(cardModel.moreoption),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ));
    } else {
      Get.snackbar("Oops!", "Nothing to Show",
          backgroundColor: Colors.grey,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1));
    }
  }

  decodeMoreOptopns(String moreOptionText) {
    List<Widget> widgeList = [];
    var widget;
    List<String> mainList;
    moreOptionText = moreOptionText.replaceAll("{", "");
    print("moreOptionText: $moreOptionText");
    mainList = moreOptionText.split("}");
    mainList.remove("");
    for (String item in mainList) {
      item = item.trim();
      var stIndex = item.indexOf("\"");
      var endIndex;
      while (stIndex >= 0) {
        endIndex = item.indexOf("\"", stIndex + 1);
        var subStr = item.substring(stIndex + 1, endIndex);
        var newSubStr = subStr.replaceAll(' ', '^');
        item = item.replaceAll(subStr, newSubStr);
        stIndex = item.indexOf("\"", endIndex + 1);
      }
      var singleList = item.split(' ');
      var btnID = "", btnType = "", btnName = "", btnOpen = "", btnexeJs = "";
      btnID = singleList[0];
      btnType = singleList[1];
      //if (singleList.indexOf("button") >= 0) btnType = singleList[singleList.indexOf("button") - 1];
      if (singleList.indexOf("open") >= 0) btnOpen = singleList[singleList.indexOf("open") + 1];
      if (singleList.indexOf("title") >= 0) btnName = singleList[singleList.indexOf("title") + 1];
      if (singleList.indexOf("exejs") >= 0) btnexeJs = singleList[singleList.indexOf("exejs") + 1];

      btnName = btnName.replaceAll('^', ' ');
      btnName = btnName.replaceAll('\"', '');
      btnexeJs = btnexeJs.replaceAll('^', ' ');

      if (btnName != "") {
        widget = ElevatedButton(
            style: btnOpen == ""
                ? ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5)),
                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.grey))
                : ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5))),
            onPressed: () {
              if (btnOpen != "") Get.back();
              menuHomePageController.openBtnAction(btnType, btnOpen);
            },
            child: FittedBox(fit: BoxFit.fitWidth, child: Text(btnName)));
        widgeList.add(widget);
        widgeList.add(SizedBox(width: 10));
      }
    }
    return widgeList;
  }

  captionOnTapFunction(CardModel cardModel) {
    var link_id = cardModel.stransid;
    var validity = false;
    if (link_id.toLowerCase().startsWith('h')) {
      if (link_id.toLowerCase().contains("hp")) {
        link_id = link_id.toLowerCase().replaceAll("hp", "h");
      }
      validity = true;
    } else {
      if (link_id.toLowerCase().startsWith('i')) {
        validity = true;
      } else {
        if (link_id.toLowerCase().startsWith('t')) {
          validity = true;
        } else
          validity = false;
      }
    }
    if (validity) {
      // print(
      //     "https://app.buzzily.com/run/aspx/AxMain.aspx?authKey=AXPERT-ARMSESSION-1ed2b2a1-e6f9-4081-b7cc-5ddcf50d8690&pname=" +
      //         cardModel.stransid);
      menuHomePageController.openBtnAction("button", link_id);
    }
  }
}

import 'package:axpertflutter/ModelPages/LandingPage/Controller/MenuHomePageConroller.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Models/CardModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class WidgetCard extends StatelessWidget {
  WidgetCard(this.cardModel, {super.key});
  CardModel cardModel;
  MenuHomePageController menuHomePageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 3,
      child: Container(
        // margin: EdgeInsets.all(10),
        height: 50,
        decoration: BoxDecoration(
            color: HexColor(cardModel.colorcode.trim()),
            borderRadius: BorderRadius.circular(10),
            // boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 20)] ,
            border: Border.all(width: 2, color: HexColor(cardModel.colorcode.trim()))),
        child: Padding(
          padding: EdgeInsets.only(left: 20, top: 25, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => menuHomePageController.showMenuDialog(cardModel),
                        icon: Icon(Icons.more_vert),
                      )),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/images/announce.png',
                      width: 50,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                cardModel.caption,
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

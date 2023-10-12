import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/StatusModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class WidgetStatusScrollBar extends StatelessWidget {
  WidgetStatusScrollBar(this.status, {super.key});
  StatusModel status;
  PendingListController pendingListController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                color: (pendingListController.statusListActiveIndex >= int.parse(status.SlNo))
                    ? HexColor("50CD89")
                    : HexColor("DAE3ED").withOpacity(0.4),
                borderRadius: BorderRadius.circular(50)),
            child: Center(
                child: Text(
              status.SlNo.toString(),
              style: TextStyle(
                  color: (pendingListController.statusListActiveIndex >= int.parse(status.SlNo))
                      ? Colors.white
                      : Colors.black.withOpacity(0.2)),
            )),
          ),
          SizedBox(width: 5),
          Text(
            status.SlHeading,
            style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    color: (pendingListController.statusListActiveIndex >= int.parse(status.SlNo))
                        ? HexColor("333333")
                        : HexColor("495057").withOpacity(0.6),
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

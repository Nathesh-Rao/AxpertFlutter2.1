import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/ActiveListModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class WidgetListItem extends StatelessWidget {
  WidgetListItem(this.pendingActiveListModel, {super.key});
  PendingListController pendingListController = Get.find();

  ActiveListModel pendingActiveListModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 30,
            child: Stack(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(1, 1),
                    )
                  ]),
                  child: CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/images/add_circle.png',
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.green),
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      pendingActiveListModel.displaytitle.toString(),
                      style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('#495057'))),
                    ),
                    Expanded(child: Text("")),
                    Icon(Icons.person),
                    SizedBox(
                      width: 10,
                    ),
                    Text(pendingActiveListModel.fromuser.toString().capitalize!,
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: HexColor('#495057'),
                          ),
                        )),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 10),
                Text(pendingActiveListModel.displaycontent.toString(),
                    maxLines: 1,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 11,
                        color: HexColor('#495057'),
                      ),
                    )),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 20),
                    SizedBox(width: 10),
                    Text(pendingListController.getDateValue(pendingActiveListModel.eventdatetime),
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HexColor('#495057'),
                          ),
                        )),
                    Expanded(child: Text("")),
                    Icon(Icons.access_time, size: 20),
                    SizedBox(width: 10),
                    Text(pendingListController.getTimeValue(pendingActiveListModel.eventdatetime),
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: HexColor('#495057'),
                          ),
                        )),
                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
          Container(
            height: 70,
            child: Center(
                child: Icon(
              Icons.chevron_right,
              size: 30,
              color: HexColor("B5B5B5"),
            )),
          ),
        ],
      ),
    );
  }
}

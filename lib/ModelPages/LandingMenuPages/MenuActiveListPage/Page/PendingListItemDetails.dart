import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetStatusScrollbar.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetLandingAppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class PendingListItemDetails extends StatelessWidget {
  PendingListItemDetails({super.key});
  PendingListController pendingListController = Get.put(PendingListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetLandingAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: double.maxFinite,
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                // color: Colors.red,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    controller: pendingListController.scrollController,
                    itemBuilder: (context, index) {
                      return WidgetStatusScrollBar(pendingListController.StatusList[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Center(
                          child: Text(
                        " > ",
                        style: TextStyle(color: HexColor("848D9C").withOpacity(0.4)),
                      ));
                    },
                    itemCount: pendingListController.StatusList.length),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back_ios, size: 30)),
                      // SizedBox(width: 10),
                      Icon(
                        Icons.calendar_month_sharp,
                        size: 35,
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Ticket",
                              style: GoogleFonts.nunitoSans(textStyle: TextStyle(color: HexColor('495057'), fontSize: 16))),
                          Text("#TKT00217",
                              style: GoogleFonts.nunitoSans(
                                  textStyle: TextStyle(color: HexColor('495057'), fontSize: 22, fontWeight: FontWeight.w800))),
                        ],
                      ),
                      Expanded(child: Text("")),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular((20)), color: HexColor('FD9700')),
                        child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                          child: Text(
                            "Pending",
                            style: GoogleFonts.nunitoSans(textStyle: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: HexColor('FF7F79')),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Pending Approval",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 13, color: HexColor('495057').withOpacity(0.8)))),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text("Sabarish",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))))),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: HexColor('616161'),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Raised By",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 13, color: HexColor('495057').withOpacity(0.8)))),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(
                          "Vaidheesh",
                          style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: HexColor('616161'),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Assigned By",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 13, color: HexColor('495057').withOpacity(0.8)))),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Text(
                          "Vaidheesh",
                          style: GoogleFonts.roboto(textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.today,
                        color: HexColor('616161'),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Assigned On",
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 13, color: HexColor('495057').withOpacity(0.8)))),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          children: [
                            Text(
                              "27/06/023",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.access_time),
                            SizedBox(width: 4),
                            Text(
                              "13:02:07",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(top: 5, bottom: 10),
                decoration:
                    BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: HexColor('616161'),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Description",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057')))),
                          SizedBox(height: 15),
                          Text(
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontSize: 13, color: HexColor('495057').withOpacity(0.8)))),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      )),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.2,
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: HexColor('4ABF7F'),
                            ),
                            Text(
                              "Approve",
                              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 13)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.2,
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              color: HexColor('FF0000'),
                            ),
                            Text(
                              "Reject",
                              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 13)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.2,
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              color: HexColor('951895'),
                            ),
                            Text(
                              "View",
                              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 13)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Material(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.2,
                        constraints: BoxConstraints(maxWidth: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restore,
                              color: HexColor('0000FF'),
                            ),
                            Text(
                              "History",
                              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 13)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

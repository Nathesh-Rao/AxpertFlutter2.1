import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/ListItemDetailsController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetPendingStatusScrollbar.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetLandingAppBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

class PendingListItemDetails extends StatelessWidget {
  PendingListItemDetails({super.key});
  // PendingListController pendingListController=Get.find();
  ListItemDetailsController listItemDetailsController = Get.find();

  @override
  Widget build(BuildContext context) {
    listItemDetailsController.fetchDetails();
    var size = MediaQuery.of(context).size;
    return Obx(() {
      if (listItemDetailsController.widgetProcessFlowNeedRefresh.value == true) {
        listItemDetailsController.widgetProcessFlowNeedRefresh.toggle();
        return reBuild(size);
      } else
        return reBuild(size);
    });
  }

  reBuild(size) => Scaffold(
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
                      controller: listItemDetailsController.scrollController,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // print(pendingListController.processFlowList[index].taskid.toString());
                            if (listItemDetailsController.processFlowList[index].taskid.toString().toLowerCase() != 'null' &&
                                listItemDetailsController.processFlowList[index].taskid.toString() !=
                                    listItemDetailsController.selectedTaskID)
                              listItemDetailsController.fetchDetails(
                                  hasArgument: true, pendingProcessFlowModel: listItemDetailsController.processFlowList[index]);
                            // print(pendingListController.processFlowList[index].toJson());
                          },
                          child: WidgetPendingStatusScrollBar(listItemDetailsController.processFlowList[index]),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Center(
                            child: Text(
                          " > ",
                          style: TextStyle(color: HexColor("848D9C").withOpacity(0.4)),
                        ));
                      },
                      itemCount: listItemDetailsController.processFlowList.length),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                  child: Container(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    decoration:
                        BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: HexColor('707070').withOpacity(0.2)))),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Icon(Icons.arrow_back_ios, size: 30)),

                          // SizedBox(width: 10),
                          Icon(
                            Icons.calendar_month_sharp,
                            size: 35,
                          ),
                          // SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Ticket",
                                  style: GoogleFonts.nunitoSans(textStyle: TextStyle(color: HexColor('495057'), fontSize: 16))),
                              Text(
                                  listItemDetailsController.pendingTaskModel != null
                                      ? '#' + listItemDetailsController.pendingTaskModel!.taskid ?? ' '
                                      : '',
                                  style: GoogleFonts.nunitoSans(
                                      textStyle:
                                          TextStyle(color: HexColor('495057'), fontSize: 22, fontWeight: FontWeight.w800))),
                            ],
                          ),
                          Expanded(child: Text("")),
                          SizedBox(width: 10),
                          Visibility(
                            visible: listItemDetailsController.pendingTaskModel != null
                                ? listItemDetailsController.pendingTaskModel!.tasktype.toLowerCase() == ''
                                    ? false
                                    : true
                                : false,
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular((20)), color: Colors.orange),
                              child: Padding(
                                padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                                child: Text(
                                  listItemDetailsController.pendingTaskModel != null
                                      ? CommonMethods.capitalize(listItemDetailsController.pendingTaskModel!.tasktype ?? ' ')
                                      : '',
                                  style: GoogleFonts.nunitoSans(textStyle: TextStyle(color: Colors.white, fontSize: 14)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                  child: Container(
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
                              width: size.width * 0.4,
                              child: Text(
                                  listItemDetailsController.pendingTaskModel != null
                                      ? CommonMethods.capitalize(listItemDetailsController.pendingTaskModel!.touser ?? ' ')
                                      : '',
                                  style: GoogleFonts.roboto(
                                      textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))))),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                  child: Container(
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
                            width: size.width * 0.4,
                            child: Text(
                              listItemDetailsController.pendingTaskModel != null
                                  ? CommonMethods.capitalize(listItemDetailsController.pendingTaskModel!.fromuser ?? ' ')
                                  : '',
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                  child: Container(
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
                            width: size.width * 0.4,
                            child: Text(
                              listItemDetailsController.pendingTaskModel != null
                                  ? CommonMethods.capitalize(listItemDetailsController.pendingTaskModel!.initiator ?? ' ')
                                  : '',
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                  child: Container(
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
                            width: size.width * 0.4,
                            child: Row(
                              children: [
                                Text(
                                  listItemDetailsController.pendingTaskModel != null
                                      ? listItemDetailsController
                                          .getDateValue(listItemDetailsController.pendingTaskModel!.eventdatetime)
                                      : "",
                                  style: GoogleFonts.roboto(
                                      textStyle: TextStyle(fontWeight: FontWeight.bold, color: HexColor('495057'))),
                                ),
                                SizedBox(width: 4),
                                Visibility(
                                    visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                                    child: Icon(Icons.access_time)),
                                SizedBox(width: 4),
                                Text(
                                  listItemDetailsController.pendingTaskModel != null
                                      ? listItemDetailsController
                                          .getTimeValue(listItemDetailsController.pendingTaskModel!.eventdatetime)
                                      : "",
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
                ),
                SizedBox(height: 10),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null ? true : false,
                  child: Container(
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
                                  listItemDetailsController.pendingTaskModel != null
                                      ? listItemDetailsController.pendingTaskModel!.displaymcontent.toLowerCase() != 'null'
                                          ? listItemDetailsController.pendingTaskModel!.displaymcontent
                                          : ' '
                                      : "",
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
                ),
                SizedBox(height: 30),
                Visibility(
                  visible: listItemDetailsController.pendingTaskModel != null
                      ? listItemDetailsController.pendingTaskModel!.showbuttons.toLowerCase() == "t"
                          ? true
                          : false
                      : false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (listItemDetailsController.pendingTaskModel!.cmsg_appcheck.toString() != '') {
                            Get.defaultDialog(
                                title: 'Approve?',
                                middleText: listItemDetailsController.pendingTaskModel!.cmsg_appcheck.toString(),
                                barrierDismissible: false,
                                confirm: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("Yes")),
                                cancel: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("No")));
                          }
                        },
                        child: Material(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          child: Container(
                            height: 60,
                            width: size.width * 0.2,
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
                        onTap: () {
                          if (listItemDetailsController.pendingTaskModel!.cmsg_reject.toString() != '') {
                            Get.defaultDialog(
                                title: 'Reject?',
                                middleText: listItemDetailsController.pendingTaskModel!.cmsg_reject.toString(),
                                barrierDismissible: false,
                                confirm: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("Yes")),
                                cancel: ElevatedButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text("No")));
                          }
                        },
                        child: Material(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          child: Container(
                            height: 60,
                            width: size.width * 0.2,
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
                            width: size.width * 0.2,
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
                            width: size.width * 0.2,
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
                ),
                SizedBox(height: 30),
                Visibility(
                    visible: listItemDetailsController.pendingTaskModel == null ? true : false,
                    child: Container(
                      height: 200,
                      child: Center(
                        child: Text("No data found!!!"),
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
}

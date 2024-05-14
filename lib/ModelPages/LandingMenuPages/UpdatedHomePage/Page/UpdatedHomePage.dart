import 'package:axpertflutter/Constants/CommonMethods.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Models/CardModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/UpdatedHomePage/Widgets/WidgetQuickAccessGridItem.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/UpdatedHomePage/Widgets/WidgetUpdatedCard.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetSlidingNotification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class UpdatedHomePage extends StatelessWidget {
  UpdatedHomePage({super.key});

  // UpdatedHomePageController updatedHomePageController = Get.put(UpdatedHomePageController());
  final MenuHomePageController menuHomePageController = Get.find();
  final LandingPageController landingPageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70)),
                    child: Container(
                      // margin: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          gradient: MyColors.updatedUIBackgroundGradient,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Container(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Hello, ${CommonMethods.capitalize(landingPageController.userName.value)}",
                                    // + CommonMethods.capitalize(landingPageController.userName.value),
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Container(
                              // padding: EdgeInsets.only(top: 1),
                              child: Text(
                                "Agile Labs Pvt. Ltd.",
                                style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 14, color: Colors.white)),
                              ),
                            ),
                          ),
                          Container(
                            width: double.maxFinite,
                            margin: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 20),
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 10, left: 20, right: 5),
                                  child: Text(
                                    landingPageController.toDay,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.blue2),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 20, right: 5, bottom: 10),
                                  child: Text(
                                    "Hooray! Today is pay day!",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(() => AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.linear,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: menuHomePageController.listOfGridCardItems.length,
                                  padding: EdgeInsets.only(top: 0, bottom: 5),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // number of items in each row
                                    mainAxisSpacing: 0, // spacing between rows
                                    crossAxisSpacing: 0, // spacing between columns
                                  ),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          captionOnTapFunction(
                                              CardModel(stransid: menuHomePageController.listOfGridCardItems[index].url));
                                        },
                                        child: WidgetQuickAccessGridItems(menuHomePageController.listOfGridCardItems[index]));
                                  },
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
              ],
          body: SingleChildScrollView(
            child: Column(
              children: [
                //Notifications
                WidgetSlidingNotificationPanel(),
                //Attendance
                Obx(() => AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                      child: Visibility(
                        visible: menuHomePageController.attendanceVisibility.value,
                        child: Container(
                          margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Attendance",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(width: 1, color: MyColors.blue2),
                                              borderRadius: BorderRadius.circular(20)),
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              "Am off today",
                                              style: TextStyle(color: MyColors.blue2),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Visibility(
                                        visible: menuHomePageController.isShowPunchIn.value,
                                        child: GestureDetector(
                                          onTap: () {
                                            menuHomePageController.onClick_PunchIn();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: MyColors.blue2,
                                                border: Border.all(width: 1, color: MyColors.blue2),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                "Punch In",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: menuHomePageController.isShowPunchOut.value,
                                        child: GestureDetector(
                                          onTap: () {
                                            menuHomePageController.onClick_PunchOut();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: MyColors.blue2,
                                                border: Border.all(width: 1, color: MyColors.blue2),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                "Punch Out",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(width: 1, color: MyColors.grey.withOpacity(0.3)),
                                    color: Colors.white),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20, bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.timer_outlined),
                                          SizedBox(width: 20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Shift Timing",
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                constraints: BoxConstraints(maxWidth: 100),
                                                child: TimelineTile(
                                                  axis: TimelineAxis.vertical,
                                                  alignment: TimelineAlign.start,
                                                  indicatorStyle: IndicatorStyle(
                                                    color: MyColors.green,
                                                    width: 6,
                                                  ),
                                                  afterLineStyle: LineStyle(color: Colors.grey, thickness: 1),
                                                  endChild: Container(
                                                      padding: EdgeInsets.only(left: 20),
                                                      child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(menuHomePageController.shift_start_time.value))),
                                                  isFirst: true,
                                                ),
                                              ),
                                              Container(
                                                  constraints: BoxConstraints(maxWidth: 100),
                                                  child: TimelineTile(
                                                    axis: TimelineAxis.vertical,
                                                    alignment: TimelineAlign.start,
                                                    indicatorStyle: IndicatorStyle(
                                                      color: MyColors.red,
                                                      width: 6,
                                                    ),
                                                    beforeLineStyle: LineStyle(color: Colors.grey, thickness: 1),
                                                    endChild: Container(
                                                        height: 30,
                                                        padding: EdgeInsets.only(left: 20),
                                                        child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(menuHomePageController.shift_end_time.value))),
                                                    isLast: true,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(width: 1, height: 70, color: Colors.grey.withOpacity(0.5)),
                                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Text(
                                          "Last Login",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(height: 5),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(1),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.shade50,
                                                      borderRadius: BorderRadius.circular(50),
                                                      border: Border.all(width: 1, color: Colors.black.withOpacity(0.1))),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: MyColors.blue2.withOpacity(0.5),
                                                    size: 18,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(menuHomePageController.last_login_date.value +
                                                    " - " +
                                                    menuHomePageController.last_login_time.value),
                                              ],
                                            ),
                                            SizedBox(height: 3),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(1),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.shade50,
                                                      borderRadius: BorderRadius.circular(50),
                                                      border: Border.all(width: 1, color: Colors.black.withOpacity(0.1))),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    color: MyColors.blue2.withOpacity(0.5),
                                                    size: 18,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  menuHomePageController.last_login_location.value,
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ]),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                //Quick Links
                Obx(() => Visibility(
                      visible: menuHomePageController.listOfCards.length == 0 ? false : true,
                      child: Container(
                        margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quick links",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 10),
                            Container(
                              // decoration: BoxDecoration(
                              //     borderRadius: BorderRadius.circular(10),
                              //     border: Border.all(width: 1, color: MyColors.grey.withOpacity(0.3)),
                              //     color: Colors.grey.shade100),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, crossAxisSpacing: 5, mainAxisSpacing: 5),
                                  // itemCount: menuHomePageController.listOfCards.length,
                                  itemCount: menuHomePageController.listOfCards.length,
                                  itemBuilder: (context, index) {
                                    // return WidgetCardUpdated(menuHomePageController.listOfCards[index]);
                                    return GestureDetector(
                                      onTap: () {
                                        captionOnTapFunction(menuHomePageController.listOfCards[index]);
                                      },
                                      child: AspectRatio(
                                        aspectRatio: 1 / 1,
                                        child: WidgetUpdatedCards(menuHomePageController.listOfCards[index]),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),

                SizedBox(height: 100),
              ],
            ),
          )),
    );
  }

  captionOnTapFunction(cardModel) {
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

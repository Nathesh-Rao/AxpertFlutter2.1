import 'package:axpertflutter/Constants/extensions.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/UpdatedHomePage/Models/ActivityListModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../Constants/MyColors.dart';
import '../../../Controllers/MenuHomePageController.dart';
import '../../Models/UpdatedHomeCardDataModel.dart';

class WidgetActivityList extends StatefulWidget {
  const WidgetActivityList({super.key});

  @override
  State<WidgetActivityList> createState() => _WidgetUpdatedActiveListsState();
}

class _WidgetUpdatedActiveListsState extends State<WidgetActivityList> {
  ///NOTE => This container will be having 4 rows and therefore 4 heights depends up on the number of quicklinks available
  ///NOTE => A new way to layout the tile's height and width is needed
  ///NOTE => Ditch Gridview and Use Wrap
  final MenuHomePageController menuHomePageController = Get.find();

  var bHeight = Get.height / 3.22;

  var bHeight1 = Get.height / 3.22;
  var bHeight2 = Get.height / 1.89;
  var isSeeMore = false;
  _onClickSeeMore() {
    setState(() {
      isSeeMore = !isSeeMore;
      if (isSeeMore) {
        bHeight = bHeight2;
      } else {
        bHeight = bHeight1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: menuHomePageController.activityListData.isNotEmpty,
        child: Column(
          children: List.generate(menuHomePageController.activityListData.length, (index) {
            List<Color> colors = List.generate(
                menuHomePageController.activityListData[index].carddata.length, (index) => MyColors.getRandomColor());
            return ActivityListPanel(activityListData: menuHomePageController.activityListData[index], colors: colors);
          }),
        ),
      ),
    );
  }
}

class ActivityListPanel extends StatefulWidget {
  const ActivityListPanel({super.key, required this.activityListData, required this.colors});
  final UpdatedHomeCardDataModel activityListData;
  final List<Color> colors;
  @override
  State<ActivityListPanel> createState() => _ActivityListPanelState();
}

class _ActivityListPanelState extends State<ActivityListPanel> {
  final MenuHomePageController menuHomePageController = Get.find();
  ScrollController scrollController = ScrollController();
  var bHeight = Get.height / 3.22;

  var bHeight1 = Get.height / 3.22;
  var bHeight2 = Get.height / 1.89;
  var isSeeMore = false;
  _onClickSeeMore() {
    setState(() {
      isSeeMore = !isSeeMore;
      if (isSeeMore) {
        bHeight = bHeight2;
      } else {
        scrollController.animateTo(scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.decelerate);
        bHeight = bHeight1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        elevation: 2,
        shadowColor: MyColors.color_grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          width: double.infinity,
          height: bHeight,
          child: Container(
              height: Get.height / 2,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25))),
              child: Column(children: [
                InkWell(
                  onTap: () {
                    _onClickSeeMore();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list,
                          // size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(widget.activityListData.cardname ?? '',
                            style: GoogleFonts.urbanist(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
                Expanded(
                    child: ListView.separated(
                  controller: scrollController,
                  itemCount: widget.activityListData.carddata.length,
                  physics: isSeeMore
                      ? BouncingScrollPhysics(
                          decelerationRate: ScrollDecelerationRate.fast,
                        )
                      : NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _tileWidget(widget.activityListData.carddata[index], widget.colors[index]),
                  separatorBuilder: (context, index) => Divider(),
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          _onClickSeeMore();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isSeeMore ? "See less" : "See more",
                                style: GoogleFonts.urbanist(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: MyColors.blue1,
                                )),
                            Icon(
                              isSeeMore ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: MyColors.blue1,
                              size: 17,
                            )
                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(10),
                    //   child: InkWell(
                    //     onTap: () {
                    //       // _onClickSeeAll();
                    //     },
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Text("See all ",
                    //             style: GoogleFonts.urbanist(
                    //               fontSize: 12,
                    //               fontWeight: FontWeight.w700,
                    //               color: MyColors.blue1,
                    //             )),
                    //         Icon(
                    //           Icons.open_in_browser,
                    //           color: MyColors.blue1,
                    //           size: 15,
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ])),
        ));
  }

  Widget _tileWidget(activityListData, Color color) {
    var activityData = ActivityListModel.fromJson(activityListData);

    Color darkenColor(Color color, [double amount = 0.2]) {
      assert(amount >= 0 && amount <= 1);
      return Color.fromARGB(
        color.alpha,
        (color.red * (1 - amount)).round(),
        (color.green * (1 - amount)).round(),
        (color.blue * (1 - amount)).round(),
      );
    }

    return ListTile(
      onTap: () {
        menuHomePageController.captionOnTapFunctionNew(activityData.link);
      },
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(100),
        radius: 18,
        child: Text(
          activityData.title != null ? activityData.title!.getInitials(subStringIndex: 2) : "0",
          style: GoogleFonts.urbanist(fontWeight: FontWeight.w700, color: darkenColor(color)),
        ),
      ),
      title: Text(
        activityData.title ?? '',
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        activityData.calledon ?? "",
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        activityData.username ?? "",
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: MyColors.text2,
        ),
      ),
    );
  }
}

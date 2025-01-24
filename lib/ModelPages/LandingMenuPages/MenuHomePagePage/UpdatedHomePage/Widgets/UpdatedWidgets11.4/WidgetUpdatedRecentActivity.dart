import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../Constants/MyColors.dart';

class WidgetUpdatedRecentActivity extends StatefulWidget {
  const WidgetUpdatedRecentActivity({super.key});

  @override
  State<WidgetUpdatedRecentActivity> createState() => _WidgetUpdatedRecentActivityState();
}

class _WidgetUpdatedRecentActivityState extends State<WidgetUpdatedRecentActivity> {
  ///NOTE => This container will be having 4 rows and therefore 4 heights depends up on the number of quicklinks available
  ///NOTE => A new way to layout the tile's height and width is needed
  ///NOTE => Ditch Gridview and Use Wrap
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
                          Icons.local_activity_outlined,
                          // size: 17,
                        ),
                        SizedBox(width: 5),
                        Text("Recent Activity",
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
                  itemCount: isSeeMore ? 10 : 3,
                  physics: isSeeMore
                      ? BouncingScrollPhysics(
                          decelerationRate: ScrollDecelerationRate.fast,
                        )
                      : NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _tileWidget(index),
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

  Widget _tileWidget(int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: MyColors.yellow1,
        radius: 18,
        child: Icon(
          Icons.message,
          color: MyColors.blue2,
          size: 16,
        ),
      ),
      title: Text(
        "New Sales Order has been created- 09HQ/...",
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        "New Sales Order has been created- 09HQ/...",
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        "This Week",
        style: GoogleFonts.urbanist(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: MyColors.text2,
        ),
      ),
    );
  }
}

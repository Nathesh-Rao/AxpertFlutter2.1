import 'dart:developer';
import 'dart:math';

import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetUpdatedQuickLinks extends StatefulWidget {
  const WidgetUpdatedQuickLinks({super.key});

  @override
  State<WidgetUpdatedQuickLinks> createState() => _WidgetUpdatedQuickLinksState();
}

class _WidgetUpdatedQuickLinksState extends State<WidgetUpdatedQuickLinks> {
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

  void _onClickSeeAll() async {
    await Get.bottomSheet(QuickLinksBottomSheet()).then((_) {
      setState(() {
        if (isSeeMore) {
          isSeeMore = !isSeeMore;
          bHeight = bHeight1;
        }
        ;
      });
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
        child: Column(
          children: [
            InkWell(
              onTap: () {
                _onClickSeeMore();
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      // size: 17,
                    ),
                    SizedBox(width: 5),
                    Text("Quick Links",
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
              child: GridView.builder(
                physics: isSeeMore
                    ? BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.fast,
                      )
                    : NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 items in a row
                  crossAxisSpacing: 5, // Spacing between columns
                  mainAxisSpacing: 5, // Spacing between rows
                  childAspectRatio: 4 / 3, // Width to height ratio
                ),
                itemCount: 24, // Number of items
                itemBuilder: (context, index) {
                  return _gridTile(index);
                },
              ),
            ),
            SizedBox(height: 5),
            // Expanded(
            //     child: Wrap(
            //   spacing: 10,
            //   runSpacing: 10,
            //   runAlignment: WrapAlignment.spaceAround,
            //   alignment: WrapAlignment.start,
            //   children: List.generate(isSeeMore ? 12 : 6, (index) => _gridTile(index)),
            // )),
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      _onClickSeeAll();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("See all ",
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MyColors.blue1,
                            )),
                        Icon(
                          Icons.open_in_browser,
                          color: MyColors.blue1,
                          size: 15,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(int index) {
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Spacer(),
            Icon(Icons.more_vert),
          ],
        )),
        Expanded(
            flex: 5,
            child: CircleAvatar(
              radius: 30,
            )),
        // Expanded(flex: 2, child: ),
        SizedBox(
            height: 30,
            child: Center(
                child: Text(
              "Item ${index + 1}",
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )))
      ],
    );
  }

  Widget _gridTile1(int index) {
    return Container(
      width: Get.width / 3.8,
      height: Get.height / 10,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Light shadow color
            blurRadius: 6, // Subtle blur
            spreadRadius: 1, // Light spread
            offset: Offset(0, 2), // Slight vertical offset
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            child: Container(
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(2)),
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.abc,
                color: Colors.blue,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Item ${index + 1}",
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey.shade700,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class QuickLinksBottomSheet extends StatelessWidget {
  const QuickLinksBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height / 2,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Quick Links",
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(CupertinoIcons.clear_circled_solid))
              ],
            ),
          ),
          Divider(
            height: 0,
            thickness: 1,
          ),
          Expanded(
            child: GridView.builder(
              physics: BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.fast,
              ),
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items in a row
                crossAxisSpacing: 8.0, // Spacing between columns
                mainAxisSpacing: 8.0, // Spacing between rows
                childAspectRatio: 4 / 3, // Width to height ratio
              ),
              itemCount: 12, // Number of items
              itemBuilder: (context, index) {
                return _gridTile(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridTile(int index) {
    return Column(
      children: [
        Expanded(
            child: Row(
          children: [
            Spacer(),
            Icon(Icons.more_vert),
          ],
        )),
        Expanded(
            flex: 5,
            child: CircleAvatar(
              radius: 30,
            )),
        // Expanded(flex: 2, child: ),
        SizedBox(
            height: 30,
            child: Center(
                child: Text(
              "Item ${index + 1}",
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            )))
      ],
    );
  }

  Widget _gridTile1(int index) {
    return Container(
      width: Get.width / 3.8,
      height: Get.height / 10,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Light shadow color
            blurRadius: 6, // Subtle blur
            spreadRadius: 1, // Light spread
            offset: Offset(0, 2), // Slight vertical offset
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            child: Container(
              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(2)),
              margin: EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.abc,
                color: Colors.blue,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Item ${index + 1}",
                style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey.shade700,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}

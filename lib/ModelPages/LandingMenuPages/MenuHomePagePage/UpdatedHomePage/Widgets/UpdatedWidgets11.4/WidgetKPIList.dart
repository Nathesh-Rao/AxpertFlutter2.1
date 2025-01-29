import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/UpdatedHomePage/Models/KPIListCardModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../Constants/MyColors.dart';
import '../../../../../../Constants/const.dart';
import '../../../../../LandingPage/Widgets/WidgetKPIPanel.dart';
import '../../../Controllers/MenuHomePageController.dart';
import '../../Models/MenuIconsModel.dart';
import '../../Models/UpdatedHomeCardDataModel.dart';

class WidgetKPIList extends StatefulWidget {
  const WidgetKPIList({super.key});

  @override
  State<WidgetKPIList> createState() => _WidgetKPIListState();
}

class _WidgetKPIListState extends State<WidgetKPIList> {
  ///NOTE => This container will be having 4 rows and therefore 4 heights depends up on the number of quicklinks available
  ///NOTE => A new way to layout the tile's height and width is needed
  ///NOTE => Ditch Gridview and Use Wrap

  final MenuHomePageController menuHomePageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
          visible: menuHomePageController.kpiListCardData.isNotEmpty,
          child: Column(
            children: List.generate(menuHomePageController.kpiListCardData.length,
                (index) => KPICardsPanel(card: menuHomePageController.kpiListCardData[index])),
          ),
        ));
  }
}

class KPICardsPanel extends StatefulWidget {
  const KPICardsPanel({super.key, required this.card});
  final UpdatedHomeCardDataModel card;
  @override
  State<KPICardsPanel> createState() => _KPICardsPanelState();
}

class _KPICardsPanelState extends State<KPICardsPanel> {
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

  void _onClickSeeAll(cardData, {required String cardName}) async {
    await Get.bottomSheet(ignoreSafeArea: true, QuickLinksBottomSheet(cardData, cardName: cardName)).then((_) {
      setState(() {
        if (isSeeMore) {
          scrollController.animateTo(scrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 300), curve: Curves.decelerate);
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
                    Text(widget.card.cardname ?? "",
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
                controller: scrollController,
                physics: isSeeMore
                    ? BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.fast,
                      )
                    : NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 3 items in a row
                  crossAxisSpacing: 5, // Spacing between columns
                  mainAxisSpacing: 5, // Spacing between rows
                  childAspectRatio: 7 / 3, // Width to height ratio
                ),
                itemCount: widget.card.carddata.length, // Number of items
                itemBuilder: (context, index) {
                  return _gridTile(widget.card.carddata[index]);
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
              children: widget.card.carddata.length > 4
                  ? [
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
                            _onClickSeeAll(widget.card.carddata, cardName: widget.card.cardname ?? "");
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
                    ]
                  : [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile(cardData) {
    KpiListModel kpiListData = KpiListModel.fromJson(cardData);
    Color color = MyColors.getRandomColor();

    Color darkenColor(Color color, [double amount = 0.2]) {
      assert(amount >= 0 && amount <= 1);
      return Color.fromARGB(
        color.alpha,
        (color.red * (1 - amount)).round(),
        (color.green * (1 - amount)).round(),
        (color.blue * (1 - amount)).round(),
      );
    }

    return InkWell(
      onTap: () {
        menuHomePageController.captionOnTapFunctionNew(kpiListData.link);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color.withAlpha(25),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(
                Icons.bar_chart,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      kpiListData.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flexible(
                      child: Text(kpiListData.value ?? '',
                          style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: darkenColor(color)))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class QuickLinksBottomSheet extends StatelessWidget {
  QuickLinksBottomSheet(this.menuIconsData, {super.key, required this.cardName});
  final dynamic menuIconsData;
  final String cardName;
  final MenuHomePageController menuHomePageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: menuIconsData.length > 9 ? Get.height * 0.75 : Get.height / 2.5,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cardName,
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
                crossAxisCount: 2, // 3 items in a row
                crossAxisSpacing: 8.0, // Spacing between columns
                mainAxisSpacing: 8.0, // Spacing between rows
                childAspectRatio: 7 / 3, // Width to height ratio
              ),
              itemCount: menuIconsData.length, // Number of items
              itemBuilder: (context, index) {
                return _gridTile(menuIconsData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridTile(cardData) {
    KpiListModel kpiListData = KpiListModel.fromJson(cardData);
    Color color = MyColors.getRandomColor();

    Color darkenColor(Color color, [double amount = 0.2]) {
      assert(amount >= 0 && amount <= 1);
      return Color.fromARGB(
        color.alpha,
        (color.red * (1 - amount)).round(),
        (color.green * (1 - amount)).round(),
        (color.blue * (1 - amount)).round(),
      );
    }

    return InkWell(
      onTap: () {
        menuHomePageController.captionOnTapFunctionNew(kpiListData.link);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color.withAlpha(25),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(
                Icons.bar_chart,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      kpiListData.name ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flexible(
                      child: Text(kpiListData.value ?? '',
                          style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: darkenColor(color)))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

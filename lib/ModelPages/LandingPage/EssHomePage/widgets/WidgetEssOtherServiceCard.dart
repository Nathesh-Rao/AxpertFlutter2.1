import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/UpdatedHomePage/Widgets/WidgetQuickAccessPanelItem.dart';
import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssOtherServiceCard extends StatelessWidget {
  WidgetEssOtherServiceCard({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));

    return Obx(() => Visibility(
          visible: controller.listOfOptionCards.length == 0 ? false : true,
          child: Card(
            margin: EdgeInsets.only(top: 25, left: 15, right: 15),
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.hardEdge,

            shadowColor: MyColors.color_grey,

            // color: Color(0xffeeeff9),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Text(
                    "Quick Links",
                    style: style,
                  ),
                ),
                Divider(
                  thickness: 1.5,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  height: _getHeight(context),

                  width: double.infinity,

                  // child: Wrap(
                  //   spacing: 10,
                  //   runSpacing: 10,
                  //   alignment: WrapAlignment.spaceBetween,
                  //   runAlignment: WrapAlignment.spaceBetween,
                  //   children: generateItems(),
                  // ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 15,
                    ),
                    // itemCount: menuHomePageController.listOfCards.length,
                    itemCount: generateItems().length,
                    itemBuilder: (context, index) {
                      // return WidgetCardUpdated(menuHomePageController.listOfCards[index]);
                      return AspectRatio(
                          aspectRatio: 1 / 1, child: generateItems()[index]);
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _getHeight(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.25;
    if (controller.listOfOptionCards.length <= 4) {
      return height / 2;
    }
    return height;
  }

  List<Widget> generateItems() {
    List<Widget> items = List.generate(
      controller.listOfOptionCards.length,
      (index) => QuickAccessTileWidget(controller.listOfOptionCards[index]),
    );

    if (items.length >= 8) {
      items = items.sublist(0, 7);
      items.add(QuickAccessTileMoreWidget(
        controller.listOfOptionCards,
      ));
    } else {
      int itemsToAdd = 8 - items.length;

      items.addAll(List.filled(itemsToAdd, QuickAccessTileEmptyeWidget()));
    }

    return items;
  }
}

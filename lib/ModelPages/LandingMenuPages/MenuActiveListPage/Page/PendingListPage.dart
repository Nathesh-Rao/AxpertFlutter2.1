import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetListItem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class PendingListPage extends StatelessWidget {
  PendingListPage({super.key});
  PendingListController pendingListController = Get.put(PendingListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (pendingListController.needRefresh.value == true) {
        pendingListController.needRefresh.toggle();
        return reBuild(pendingListController);
      }
      return reBuild(pendingListController);
    });
  }
}

reBuild(PendingListController pendingListController) {
  return Padding(
    padding: EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: pendingListController.searchController,
                onChanged: pendingListController.filterList,
                decoration: InputDecoration(
                    prefixIcon: pendingListController.searchController.text.toString() == ""
                        ? GestureDetector(
                            child: Icon(
                              Icons.search,
                              // color: HexColor("#8E8E8EA3"),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              pendingListController.clearCalled();
                            },
                            child: Icon(
                              Icons.clear,
                              color: HexColor("#8E8E8EA3"),
                            ),
                          ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: "Search",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(width: 1))),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 35,
                width: 30,
                decoration: BoxDecoration(color: HexColor('0E72FD'), borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: ImageIcon(
                    AssetImage("assets/images/add_circle.png"),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 35,
                width: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Icon(
                    Icons.refresh,
                    color: HexColor('848D9C').withOpacity(0.7),
                    size: 28,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 35,
                width: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Icon(
                    Icons.access_time_outlined,
                    color: HexColor('848D9C').withOpacity(0.7),
                    size: 28,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 35,
                width: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Icon(
                    Icons.filter_alt,
                    color: HexColor('848D9C').withOpacity(0.7),
                    size: 28,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 35,
                width: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Icon(
                    Icons.checklist,
                    color: HexColor('848D9C').withOpacity(0.7),
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.ProjectListingPageDetails);
                      },
                      child: WidgetListItem(pendingListController.pending_activeList[index]));
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 30,
                    child: MySeparator(),
                  );
                },
                itemCount: pendingListController.pending_activeList.length))
      ],
    ),
  );
}

class MySeparator extends StatelessWidget {
  const MySeparator({Key? key, this.height = 1}) : super(key: key);
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: HexColor("707070").withOpacity(0.4)),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

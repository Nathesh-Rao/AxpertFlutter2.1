import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/ListItemDetailsController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/PendingProcessFlowModel.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetDottedSeparator.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetPendingListItem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class PendingListPage extends StatelessWidget {
  PendingListPage({super.key});
  final PendingListController pendingListController = Get.put(PendingListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (pendingListController.needRefresh.value == true) {
        pendingListController.needRefresh.toggle();
        return reBuild(pendingListController, context);
      }
      return reBuild(pendingListController, context);
    });
  }
}

reBuild(PendingListController pendingListController, BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: pendingListController.searchController,
                onChanged: pendingListController.filterList,
                decoration: InputDecoration(
                    prefixIcon: pendingListController.searchController.text.toString() == ""
                        ? GestureDetector(child: Icon(Icons.search))
                        : GestureDetector(
                            onTap: () {
                              pendingListController.clearCalled();
                            },
                            child: Icon(Icons.clear, color: HexColor("#8E8E8EA3")),
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
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 35,
                  width: 30,
                  decoration: BoxDecoration(
                      color: pendingListController.selectedIconNumber.value == 1 ? HexColor('0E72FD') : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: ImageIcon(
                      AssetImage("assets/images/add_circle.png"),
                      color: pendingListController.selectedIconNumber.value == 1
                          ? Colors.white
                          : HexColor('848D9C').withOpacity(0.7),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 35,
                  width: 30,
                  decoration: BoxDecoration(
                      color: pendingListController.selectedIconNumber.value == 2 ? HexColor('0E72FD') : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Icon(
                      Icons.refresh,
                      color: pendingListController.selectedIconNumber.value == 2
                          ? Colors.white
                          : HexColor('848D9C').withOpacity(0.7),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  pendingListController.selectedIconNumber.value = 3;
                },
                child: Container(
                  height: 35,
                  width: 30,
                  decoration: BoxDecoration(
                      color: pendingListController.selectedIconNumber.value == 3 ? HexColor('0E72FD') : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Icon(
                      Icons.access_time_outlined,
                      color: pendingListController.selectedIconNumber.value == 3
                          ? Colors.white
                          : HexColor('848D9C').withOpacity(0.7),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 35,
                  width: 30,
                  decoration: BoxDecoration(
                      color: pendingListController.selectedIconNumber.value == 4 ? HexColor('0E72FD') : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Icon(
                      Icons.filter_alt,
                      color: pendingListController.selectedIconNumber.value == 4
                          ? Colors.white
                          : HexColor('848D9C').withOpacity(0.7),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  pendingListController.selectedIconNumber.value = 5;
                },
                child: Container(
                  height: 35,
                  width: 30,
                  decoration: BoxDecoration(
                      color: pendingListController.selectedIconNumber.value == 5 ? HexColor('0E72FD') : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Icon(
                      Icons.checklist,
                      color: pendingListController.selectedIconNumber.value == 5
                          ? Colors.white
                          : HexColor('848D9C').withOpacity(0.7),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // SizedBox(height: 10),
      Expanded(
          child: ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    // print(pendingListController.pending_activeList[index].taskid);
                    ListItemDetailsController listItemDetailsController = Get.put(ListItemDetailsController());
                    listItemDetailsController.openModel = pendingListController.pending_activeList[index];

                    Get.toNamed(Routes.ProjectListingPageDetailsPending);
                  },
                  title: WidgetPendingListItem(pendingListController.pending_activeList[index]),
                );
                // return GestureDetector(
                //     onTap: () {
                //       Get.toNamed(Routes.ProjectListingPageDetails);
                //     },
                //     child: WidgetListItem(pendingListController.pending_activeList[index]));
              },
              separatorBuilder: (context, index) {
                return Container(
                  height: 20,
                  child: WidgetDottedSeparator(),
                );
              },
              itemCount: pendingListController.pending_activeList.length))
    ],
  );
}

import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/CompletedListController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/ListItemDetailsController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Page/PendingListPage.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetCompletedListItem.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Widgets/WidgetDottedSeparator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

class CompletedListPage extends StatelessWidget {
  CompletedListPage({super.key});

  CompletedListController completedListController = Get.put(CompletedListController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (completedListController.needRefresh.value == true) {
        completedListController.needRefresh.toggle();
        return reBuild(completedListController, context);
      }
      return reBuild(completedListController, context);
    });
  }

  reBuild(CompletedListController completedListController, BuildContext context) {
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
                  controller: completedListController.searchController,
                  onChanged: completedListController.filterList,
                  decoration: InputDecoration(
                      prefixIcon: completedListController.searchController.text.toString() == ""
                          ? GestureDetector(child: Icon(Icons.search))
                          : GestureDetector(
                              onTap: () {
                                completedListController.clearCalled();
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
                        color: completedListController.selectedIconNumber.value == 1 ? HexColor('0E72FD') : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: ImageIcon(
                        AssetImage("assets/images/add_circle.png"),
                        color: completedListController.selectedIconNumber.value == 1
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
                        color: completedListController.selectedIconNumber.value == 2 ? HexColor('0E72FD') : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Icon(
                        Icons.refresh,
                        color: completedListController.selectedIconNumber.value == 2
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
                    completedListController.selectedIconNumber.value = 3;
                  },
                  child: Container(
                    height: 35,
                    width: 30,
                    decoration: BoxDecoration(
                        color: completedListController.selectedIconNumber.value == 3 ? HexColor('0E72FD') : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Icon(
                        Icons.access_time_outlined,
                        color: completedListController.selectedIconNumber.value == 3
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
                        color: completedListController.selectedIconNumber.value == 4 ? HexColor('0E72FD') : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Icon(
                        Icons.filter_alt,
                        color: completedListController.selectedIconNumber.value == 4
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
                    completedListController.selectedIconNumber.value = 5;
                  },
                  child: Container(
                    height: 35,
                    width: 30,
                    decoration: BoxDecoration(
                        color: completedListController.selectedIconNumber.value == 5 ? HexColor('0E72FD') : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Icon(
                        Icons.checklist,
                        color: completedListController.selectedIconNumber.value == 5
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
                      ListItemDetailsController listItemDetailsController = Get.put(ListItemDetailsController());
                      listItemDetailsController.openModel = completedListController.pending_activeList[index];

                      Get.toNamed(Routes.ProjectListingPageDetailsPending);
                    },
                    title: WidgetCompletedListItem(completedListController.pending_activeList[index]),
                  );
                  // return GestureDetector(
                  //     onTap: () {
                  //       Get.toNamed(Routes.ProjectListingPageDetails);
                  //     },
                  //     child: WidgetListItem(completedListController.pending_activeList[index]));
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 20,
                    child: WidgetDottedSeparator(),
                  );
                },
                itemCount: completedListController.pending_activeList.length))
      ],
    );
  }
}

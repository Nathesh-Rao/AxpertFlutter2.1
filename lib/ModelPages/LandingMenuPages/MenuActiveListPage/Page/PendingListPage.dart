import 'package:axpertflutter/Constants/Routes.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/ListItemDetailsController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/PendingListController.dart';
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
            // SizedBox(width: 6),
            // Material(
            //   elevation: 2,
            //   borderRadius: BorderRadius.circular(10),
            //   child: GestureDetector(
            //     onTap: () {
            //       if (pendingListController.selectedIconNumber.value != 1) pendingListController.getNoOfPendingActiveTasks();
            //       pendingListController.selectedIconNumber.value = 1;
            //     },
            //     child: Container(
            //       height: 35,
            //       width: 30,
            //       decoration: BoxDecoration(
            //           color: pendingListController.selectedIconNumber.value == 1 ? HexColor('0E72FD') : Colors.white,
            //           borderRadius: BorderRadius.circular(10)),
            //       child: Center(
            //         child: ImageIcon(
            //           AssetImage("assets/images/add_circle.png"),
            //           color: pendingListController.selectedIconNumber.value == 1
            //               ? Colors.white
            //               : HexColor('848D9C').withOpacity(0.7),
            //           size: 28,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 6),
            // Material(
            //   elevation: 2,
            //   borderRadius: BorderRadius.circular(10),
            //   child: GestureDetector(
            //     onTap: () {
            //
            //     },
            //     child: Container(
            //       height: 35,
            //       width: 30,
            //       decoration: BoxDecoration(
            //           color: pendingListController.selectedIconNumber.value == 2 ? HexColor('0E72FD') : Colors.white,
            //           borderRadius: BorderRadius.circular(10)),
            //       child: Center(
            //         child: Icon(
            //           Icons.refresh,
            //           color: pendingListController.selectedIconNumber.value == 2
            //               ? Colors.white
            //               : HexColor('848D9C').withOpacity(0.7),
            //           size: 28,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 6),
            // Material(
            //   elevation: 2,
            //   borderRadius: BorderRadius.circular(10),
            //   child: GestureDetector(
            //     onTap: () {
            //       pendingListController.selectedIconNumber.value = 3;
            //     },
            //     child: Container(
            //       height: 35,
            //       width: 30,
            //       decoration: BoxDecoration(
            //           color: pendingListController.selectedIconNumber.value == 3 ? HexColor('0E72FD') : Colors.white,
            //           borderRadius: BorderRadius.circular(10)),
            //       child: Center(
            //         child: Icon(
            //           Icons.access_time_outlined,
            //           color: pendingListController.selectedIconNumber.value == 3
            //               ? Colors.white
            //               : HexColor('848D9C').withOpacity(0.7),
            //           size: 28,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(width: 6),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Get.dialog(showFilterDialog(context, pendingListController));
                },
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
                    print(pendingListController.pending_activeList[index].toJson());
                    if (pendingListController.pending_activeList[index].tasktype.toString().toLowerCase() != "approve") {
                    } else {
                      ListItemDetailsController listItemDetailsController = Get.put(ListItemDetailsController());
                      listItemDetailsController.openModel = pendingListController.pending_activeList[index];

                      Get.toNamed(Routes.ProjectListingPageDetailsPending);
                    }
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

Widget showFilterDialog(BuildContext context, var pendingListController) {
  pendingListController.errDateFrom.value = pendingListController.errDateTo.value = '';
  return Obx(() => GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Dialog(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      "Filter results",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(margin: EdgeInsets.only(top: 10), height: 1, color: Colors.grey.withOpacity(0.6)),
                  SizedBox(height: 20),
                  // TextField(
                  //   controller: pendingListController.searchTextController,
                  //   textInputAction: TextInputAction.next,
                  //   decoration: InputDecoration(
                  //       filled: true,
                  //       fillColor: Colors.grey.withOpacity(0.05),
                  //       suffix: GestureDetector(
                  //           onTap: () {
                  //             pendingListController.searchTextController.text = "";
                  //             FocusManager.instance.primaryFocus?.unfocus();
                  //           },
                  //           child: Container(
                  //             child: Text("X"),
                  //           )),
                  //       border: OutlineInputBorder(borderSide: BorderSide(width: 1), borderRadius: BorderRadius.circular(10)),
                  //       hintText: "Search Text "),
                  // ),
                  // Center(
                  //     child: Padding(
                  //         padding: EdgeInsets.only(top: 10, bottom: 10),
                  //         child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold)))),
                  TextField(
                    controller: pendingListController.processNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        suffix: GestureDetector(
                            onTap: () {
                              pendingListController.processNameController.text = "";
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Container(
                              child: Text("X"),
                            )),
                        border: OutlineInputBorder(borderSide: BorderSide(width: 1), borderRadius: BorderRadius.circular(10)),
                        hintText: "Process Name "),
                  ),
                  Center(
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold)))),
                  TextField(
                    controller: pendingListController.fromUserController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        suffix: GestureDetector(
                            onTap: () {
                              pendingListController.fromUserController.text = "";
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Container(
                              child: Text("X"),
                            )),
                        border: OutlineInputBorder(borderSide: BorderSide(width: 1), borderRadius: BorderRadius.circular(10)),
                        hintText: "From User "),
                  ),
                  Center(
                      child: Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold)))),
                  TextField(
                    controller: pendingListController.dateFromController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        suffix: GestureDetector(
                            onTap: () {
                              pendingListController.dateFromController.text = "";
                            },
                            child: Container(
                              child: Text("X"),
                            )),
                        border: OutlineInputBorder(borderSide: BorderSide(width: 1), borderRadius: BorderRadius.circular(10)),
                        errorText: pendingListController.errText(pendingListController.errDateFrom.value),
                        hintText: "From Date: DD-MMM-YYYY "),
                    canRequestFocus: false,
                    onTap: () {
                      selectDate(context, pendingListController.dateFromController);
                    },
                    enableInteractiveSelection: false,
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: pendingListController.dateToController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.05),
                        suffix: GestureDetector(
                            onTap: () {
                              pendingListController.dateToController.text = "";
                            },
                            child: Container(
                              child: Text("X"),
                            )),
                        border: OutlineInputBorder(borderSide: BorderSide(width: 1), borderRadius: BorderRadius.circular(10)),
                        errorText: pendingListController.errText(pendingListController.errDateTo.value),
                        hintText: "To Date: DD-MMM-YYYY"),
                    canRequestFocus: false,
                    enableInteractiveSelection: false,
                    onTap: () {
                      selectDate(context, pendingListController.dateToController);
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            pendingListController.removeFilter();
                            Get.back();
                          },
                          child: Text("Reset")),
                      ElevatedButton(
                          onPressed: () {
                            pendingListController.applyFilter();
                          },
                          child: Text("Filter"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ));
}

void selectDate(BuildContext context, TextEditingController text) async {
  FocusManager.instance.primaryFocus?.unfocus();
  const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final DateTime? picked =
      await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now());
  if (picked != null)
    text.text =
        picked.day.toString().padLeft(2, '0') + "-" + months[picked.month - 1] + "-" + picked.year.toString().padLeft(2, '0');
}

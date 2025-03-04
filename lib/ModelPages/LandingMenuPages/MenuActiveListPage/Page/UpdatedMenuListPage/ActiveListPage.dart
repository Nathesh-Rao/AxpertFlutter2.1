import 'package:axpertflutter/Constants/Extensions.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/UpdatedActiveTaskListController/ActiveTaskListController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../Controllers/CompletedListController.dart';
import '../../Controllers/PendingListController.dart';
import '../../Models/UpdatedActiveTaskListModel/ActiveTaskListModel.dart';

class ActiveListPage extends StatelessWidget {
  ActiveListPage({super.key});
  ActiveTaskListController activeTaskListController = Get.find();
  final PendingListController pendingListController = Get.put(PendingListController());
  final CompletedListController completedListController = Get.put(CompletedListController());
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      activeTaskListController.init();
    });
    return Scaffold(
      backgroundColor: MyColors.grey2,
      floatingActionButton: _floatingActionButton(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10, left: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _searchFieldWidget(),
                Obx(() => _iconButtons(Icons.filter_alt, activeTaskListController.openFilterPrompt,
                    isActive: activeTaskListController.isFilterOn.value)),
                // _iconButtons(Icons.select_all_rounded, () {}),
                _iconButtons(Icons.done_all, () {
                  pendingListController.bulkCommentController.clear();
                  Get.dialog(showBulkApprovalProcessDialog(context, pendingListController));
                }),
              ],
            ),
          ),
          Obx(
            () => activeTaskListController.isListLoading.value
                ? LinearProgressIndicator(
                    minHeight: 1,
                    borderRadius: BorderRadius.circular(100),
                  )
                : SizedBox.shrink(),
          ),
          Expanded(
              child: Obx(
            () => Visibility(
              visible: activeTaskListController.activeTaskMap.keys.isNotEmpty,
              child: ListView(
                controller: activeTaskListController.taskListScrollController,
                // padding: EdgeInsets.only(top: 20),
                physics: BouncingScrollPhysics(),
                children: List.generate(
                  activeTaskListController.activeTaskMap.keys.length,
                  (index) {
                    var _key = activeTaskListController.activeTaskMap.keys.toList()[index];
                    var _currentList = activeTaskListController.activeTaskMap[_key];

                    return ExpandedTile(
                      contentseparator: 0,
                      theme: ExpandedTileThemeData(
                        titlePadding: EdgeInsets.all(0),
                        contentPadding: EdgeInsets.all(0),
                        headerColor: MyColors.grey2,
                        headerSplashColor: MyColors.grey1,
                        contentBackgroundColor: Colors.white,
                        contentSeparatorColor: Colors.white,
                      ),
                      controller: ExpandedTileController(isExpanded: true),
                      title: Text(
                        _key.toString(),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      content: Column(
                        children: List.generate(_currentList!.length, (i) => _listTile(model: _currentList[i])),
                      ),
                      onTap: () {
                        // debugPrint("tapped!!");
                      },
                      onLongTap: () {
                        // debugPrint("long tapped!!");
                      },
                    );
                  },
                ),
              ),
            ),
          )),
          _bottomTextInfoWidget(),
        ],
      ),
    );
  }

  _listTile({required ActiveTaskListModel model}) {
    var style = GoogleFonts.poppins();
    var color = model.cstatus?.toLowerCase() == "active" ? Color(0xff9898FF) : Color(0xff319F43);
    return InkWell(
      onTap: () {
        activeTaskListController.onTaskClick(model);
      },
      child: Container(
        margin: EdgeInsets.only(top: 2, bottom: 2),
        padding: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: MyColors.grey2))),
        height: 115,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(right: 25),
                color: model.cstatus?.toLowerCase() == "active" ? Color(0xff9898FF) : null,
                width: 5,
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: color.withAlpha(70),
                child: Icon(
                  model.cstatus?.toLowerCase() == "active" ? Icons.file_open_rounded : Icons.done,
                  color: color,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: activeTaskListController.highlightedText(
                                  model.displaytitle.toString(), style.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                                  isTitle: true),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                style: style.copyWith(
                                  fontSize: 9,
                                  color: MyColors.grey9,
                                  // color: Color(0xff666D80),
                                  fontWeight: FontWeight.w600,
                                ),
                                children: activeTaskListController.formatDateTimeSpan(
                                  activeTaskListController.formatToDayTime(model.eventdatetime.toString()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: activeTaskListController.highlightedText(
                                  model.displaycontent.toString(),
                                  style.copyWith(
                                    fontSize: 12,
                                  )),
                            ),
                            SizedBox(width: 40),
                          ],
                        ),
                      ],
                    ),
                    SizedBox.shrink(),
                    Row(
                      children: [
                        _tileInfoWidget(model.fromuser.toString(), Color(0xff737674)),
                        SizedBox(width: 10),
                        model.cstatus?.toLowerCase() != "active"
                            ? _tileInfoWidget(model.cstatus.toString(), Color(0xff319F43))
                            : SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  _tileInfoWidget(String label, Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withAlpha(50), borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: color.darken(0.5), fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _iconButtons(IconData icon, Function() onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 10),
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          border: isActive ? Border.all(color: MyColors.blue9) : null,
          color: isActive ? null : Color(0xffF1F1F1).darken(0.05),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isActive ? MyColors.blue9 : MyColors.grey9,
          ),
        ),
      ),
    );
  }

  Widget _floatingActionButton() {
    return Obx(
      () => activeTaskListController.activeTaskList.isEmpty
          ? SizedBox.shrink()
          : FloatingActionButton(
              backgroundColor: MyColors.blue9,
              foregroundColor: MyColors.white1,
              child: activeTaskListController.isListLoading.value
                  ? Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: MyColors.white1,
                            strokeWidth: 2,
                            strokeCap: StrokeCap.round,
                          )),
                    )
                  : Icon(activeTaskListController.isRefreshable.value ? Icons.refresh_rounded : Icons.arrow_upward_rounded),
              onPressed: activeTaskListController.refreshList,
            ),
    );
  }

  Widget _bottomTextInfoWidget() {
    return Obx(() => activeTaskListController.showFetchInfo.value
        ? Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              "No more records to display",
              style: GoogleFonts.poppins(
                color: MyColors.baseRed,
              ),
            ),
          )
        : SizedBox.shrink());
  }

  _searchFieldWidget() {
    return Expanded(
      child: Obx(
        () => TextField(
          controller: activeTaskListController.searchTextController,
          onChanged: activeTaskListController.searchTask,
          decoration: InputDecoration(
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: MyColors.grey9,
                size: 24,
              ),
              suffixIcon: activeTaskListController.taskSearchText.value.isNotEmpty
                  ? InkWell(
                      onTap: activeTaskListController.clearSearch,
                      child: Icon(
                        CupertinoIcons.clear_circled_solid,
                        color: MyColors.baseRed.withAlpha(150),
                        size: 24,
                      ),
                    )
                  : null,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "Search...",
              hintStyle: GoogleFonts.poppins(
                color: MyColors.grey6,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50), borderSide: BorderSide(width: 1, color: Color(0xffD0D0D0)))),
        ),
      ),
    );
  }

  Widget showBulkApprovalProcessDialog(BuildContext context, PendingListController pendingListController) {
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
                        "Bulk Approve",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(margin: EdgeInsets.only(top: 10), height: 1, color: Colors.grey.withOpacity(0.6)),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        maxHeight: 300.0,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: pendingListController.bulkApprovalCount_list.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            onTap: () {
                              Get.back();
                              pendingListController
                                  .getBulkActiveTasks(pendingListController.bulkApprovalCount_list[index].processname.toString());
                              Get.dialog(showBulkApproval_DetailDialog(context, pendingListController));
                            },
                            title: WidgetBulkAppr_CountItem(pendingListController.bulkApprovalCount_list[index]),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text("Cancel")),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget WidgetBulkAppr_CountItem(var bulkApprovalCountModel) {
    return Container(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 40,
          width: 40,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Image.asset(
              'assets/images/createoffer.png',
            ),
            //AssetImage( 'assets/images/createoffer.png'),
          ),
        ),
        SizedBox(width: 10),
        Container(
          height: 40,
          child: Center(
            child: Text(bulkApprovalCountModel.processname.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    fontSize: 16,
                    color: HexColor('#495057'),
                  ),
                )),
          ),
        ),
        Expanded(child: SizedBox(width: 10)),
        Container(
          height: 40,
          width: 40,
          child: Center(
            child: Container(
              height: 30,
              width: 30,
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.red, boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(1, 1),
                )
              ]),
              child: Center(
                  child: Text(
                bulkApprovalCountModel.pendingapprovals.toString(),
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
        ),
      ]),
    );
  }

  Widget showBulkApproval_DetailDialog(BuildContext context, PendingListController pendingListController) {
    return Obx(() => Dialog(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CheckboxListTile(
                      title: Text(
                        "Bulk Approval ",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      value: pendingListController.isBulkAppr_SelectAll.value,
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (bool? value) {
                        pendingListController.selectAll_BulkApproveList_item(value);
                      },
                    ),
                  ),
                  Container(margin: EdgeInsets.only(top: 10), height: 1, color: Colors.grey.withOpacity(0.6)),
                  SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      maxHeight: 300.0,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: pendingListController.bulkApproval_activeList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                          value: pendingListController.bulkApproval_activeList[index].bulkApprove_isSelected.value,
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          onChanged: (value) {
                            pendingListController.onChange_BulkApprItem(index, value);
                          },
                          title: widgetBulkApproval_ListItem(
                              pendingListController, pendingListController.bulkApproval_activeList[index]),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.4),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: TextField(
                      controller: pendingListController.bulkCommentController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          hintText: "Enter Comments",
                          labelText: "Enter Comments",
                          filled: true,
                          fillColor: Colors.grey.shade100),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text("Cancel")),
                      ElevatedButton(
                          onPressed: () {
                            pendingListController.doBulkApprove().then((_) {
                              activeTaskListController.refreshList();
                            });
                          },
                          child: Text("Bulk Approve"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget widgetBulkApproval_ListItem(PendingListController pendingListController, itemModel) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  itemModel.displaytitle.toString(),
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('#495057'))),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  // selectable: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(itemModel.displaycontent.toString(),
              maxLines: 1,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                  fontSize: 11,
                  color: HexColor('#495057'),
                ),
              )),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.person,
              ),
              SizedBox(
                width: 5,
              ),
              Text(itemModel.fromuser.toString().capitalize!,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: HexColor('#495057'),
                    ),
                  ))
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16),
              SizedBox(width: 10),
              Text(pendingListController.getDateValue(itemModel.eventdatetime),
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: HexColor('#495057'),
                    ),
                  )),
              Expanded(child: Text("")),
              Icon(Icons.access_time, size: 16),
              SizedBox(width: 5),
              Text(pendingListController.getTimeValue(itemModel.eventdatetime),
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: HexColor('#495057'),
                    ),
                  )),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}

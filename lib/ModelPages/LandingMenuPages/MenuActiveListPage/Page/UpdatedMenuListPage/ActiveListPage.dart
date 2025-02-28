import 'package:axpertflutter/Constants/Extensions.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Controllers/UpdatedActiveTaskListController/ActiveTaskListController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

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
                _iconButtons(Icons.select_all_rounded, () {}),
                _iconButtons(Icons.done_all, () {}),
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
          color: isActive ? MyColors.blue9 : Color(0xffF1F1F1).darken(0.05),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isActive ? MyColors.white1 : MyColors.grey9,
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
}

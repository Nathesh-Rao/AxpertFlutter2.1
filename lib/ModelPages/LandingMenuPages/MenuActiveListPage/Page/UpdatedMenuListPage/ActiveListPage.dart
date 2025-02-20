import 'package:axpertflutter/Constants/Extensions.dart';
import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActiveListPage extends StatelessWidget {
  const ActiveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    // controller: pendingListController.searchController,
                    // onChanged: pendingListController.filterList,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          CupertinoIcons.search,
                          color: MyColors.grey9,
                          size: 24,
                        ),
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
                _iconButtons(Icons.filter_alt, () {}),
                _iconButtons(Icons.select_all_rounded, () {}),
                _iconButtons(Icons.done_all, () {}),
              ],
            ),
          ),
          Expanded(
              child: ListView.separated(
                  padding: EdgeInsets.only(top: 20),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => _listTile(index: index),
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: 15))
        ],
      ),
    );
  }

  _listTile({required int index}) {
    var style = GoogleFonts.poppins();
    var color = index % 2 == 0 ? Color(0xff9898FF) : Color(0xff319F43);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 10),
            color: index % 2 == 0 ? Color(0xff9898FF) : null,
            width: 6,
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withAlpha(70),
            child: Icon(
              Icons.task_rounded,
              color: color,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "09HQ/2024/PO/000083",
                      style: style.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Text("09:59 PM", style: style.copyWith(fontSize: 11, color: Color(0xff666D80), fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                        child: Text(
                      "The design process has started, and once it's finalized, we will provide a date for the next steps",
                      style: style.copyWith(
                        fontSize: 12,
                      ),
                    )),
                    SizedBox(width: 40),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _tileInfoWidget("admin", Color(0xff737674)),
                    SizedBox(width: 20),
                    index % 2 != 0 ? _tileInfoWidget("approved", Color(0xff319F43)) : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }

  _tileInfoWidget(String label, Color color) {
    return Container(
      decoration: BoxDecoration(color: color.withAlpha(100), borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: color.darken(), fontWeight: FontWeight.w500)),
      ),
    );
  }

  _iconButtons(IconData icon, Function() onTap) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Icon(
          icon,
          color: MyColors.grey9,
        ),
      ),
    );
  }
}

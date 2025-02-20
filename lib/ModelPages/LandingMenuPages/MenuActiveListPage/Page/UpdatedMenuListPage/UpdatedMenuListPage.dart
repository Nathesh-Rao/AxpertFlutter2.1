import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdatedMenuListPage extends StatelessWidget {
  const UpdatedMenuListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                _iconButtons(Icons.filter, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _iconButtons(IconData icon, Function() onTap) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: MyColors.grey1,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Icon(icon),
      ),
    );
  }
}

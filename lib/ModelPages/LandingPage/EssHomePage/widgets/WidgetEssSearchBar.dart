import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuHomePagePage/Controllers/MenuHomePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Controllers/MenuMorePageController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuMorePage/Models/MenuItemModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:substring_highlight/substring_highlight.dart';

class WidgetEssSearchBar extends StatelessWidget {
  WidgetEssSearchBar({super.key});
  final MenuMorePageController menuController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 15,
      child: SizedBox(
        height: 53,
        child: Card(
          borderOnForeground: false,
          clipBehavior: Clip.hardEdge,
          elevation: 3,
          color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Color(0xff4E58EE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/search.png",
                      color: Colors.white,
                      width: 25,
                    ),
                  ),
                  // width: size.width * 0.15,
                ),
              ),
              Expanded(
                flex: 6,
                child: Center(
                  child: TypeAheadField<MenuItemNewmModel>(
                    controller: menuController.searchController,
                    itemBuilder: (context, item) {
                      return ListTile(
                        leading: Icon(menuController.generateIcon(item, 1)),
                        minLeadingWidth: 10,
                        contentPadding: EdgeInsets.only(left: 10),
                        title: SubstringHighlight(
                          text: item.caption,
                          term: menuController.searchController.text,
                          textStyleHighlight:
                              TextStyle(fontWeight: FontWeight.w700),
                        ), //Text(item.caption),
                      );
                    },
                    onSelected: (item) {
                      menuController.openItemClick(item);
                      menuController.clearField_searchBar();
                    },
                    suggestionsCallback: (value) {
                      return menuController.filter_search(value);
                    },
                    builder: (context, cnt, fn) {
                      return TextField(
                        controller: cnt,
                        focusNode: fn,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            // fontFamily: 'Poppins',
                            //color: HexColor("#8E8E8E"),
                          ),
                          // filled: true,
                          //fillColor: HexColor("#FFFFFF"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            // fontFamily: 'Poppins',
                            //  color: HexColor("#8B193F"),
                          ),
                          contentPadding: EdgeInsets.only(left: 10),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),

                          suffixIcon: menuController.getSuffixIcon_searchBar(),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:substring_highlight/substring_highlight.dart';

class WidgetEssSearchBar extends StatelessWidget {
  const WidgetEssSearchBar({super.key});

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
                  child: TypeAheadField(
                    builder: (context, controller, focusNode) {
                      return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              labelText: 'Search for anything',
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Color(0xff9A9A9A),
                              )));
                    },
                    itemBuilder: (context, value) => ListTile(),
                    onSelected: (_) {},
                    suggestionsCallback: (value) {
                      return;
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

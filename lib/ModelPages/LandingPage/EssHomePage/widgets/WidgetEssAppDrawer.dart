import 'package:axpertflutter/Constants/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssAppDrawer extends StatelessWidget {
  const WidgetEssAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.7,
      height: size.height,
      color: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff3764FC),
                    Color(0xff9764DA),
                  ]),
            ),
            child: _userInfoWidget(
                username: "Amrithanath", companyName: "Agile labs"),
          ),
          ..._getAllDrawerWidgets(),
          Spacer(),
          Divider(),
          _bottomWidget(),
        ],
      ),
    );
  }

  List<Widget> _getAllDrawerWidgets() {
    List<IconData> iconList = [
      Icons.calendar_month,
      Icons.star_rounded,
      Icons.place,
      Icons.wallet,
      Icons.flag_circle_rounded,
      Icons.group,
      Icons.phone,
    ];
    List<String> titleList = [
      "Calendar",
      "Rewards",
      "Address",
      "Payments Methods",
      "Offers",
      "Refer a Friend",
      "Support",
    ];
    var widgetList = List.generate(
        iconList.length,
        (index) => ListTile(
              leading: Icon(iconList[index]),
              title: Text(titleList[index]),
              trailing: index % 3 == 0 && index != 0
                  ? Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : null,
            ));
    return widgetList;
  }

  Widget _bottomWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            'App Version: ${Const.APP_VERSION}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            "© agile-labs.com ${DateTime.now().year}",
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userInfoWidget({
    required String username,
    required String companyName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 32,
              child: CircleAvatar(
                // backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/images/profilesample.jpg"),
                radius: 30,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warehouse,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      companyName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

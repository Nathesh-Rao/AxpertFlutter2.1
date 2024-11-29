import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssAnnouncement extends StatelessWidget {
  const WidgetEssAnnouncement({super.key});

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Row(
              children: [
                Text(
                  "Announcement",
                  style: style,
                ),
                Spacer(),
                InkWell(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "See all",
                        style: style.copyWith(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Colors.blue.shade900,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1.5,
          ),
          SizedBox(
            height: 10,
          ),
          ...List.generate(3, (index) => _announcementItem(index)),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _announcementItem(int index) {
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.indigo,
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _userInfoWidget(
                    username: "Kimberly Vixion", companyName: "Head of HR"),
                SizedBox(
                  height: 10,
                ),
                Text(
                  index % 2 == 0
                      ? "Notice of position for “Marsha Leanetha” from Jr. Backend developer becomes Sr. Backend developer following is the attachment to the letter.."
                      : "Notice of position for “Marsha Leanetha” from Jr. Backend developer becomes nothing",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                      color: colors[index].withAlpha(60),
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {},
                    child: Center(
                      child: Row(
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: colors[index],
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            "Promotion Letter Sr backend developer",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colors[index],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userInfoWidget({
    required String username,
    required String companyName,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            // backgroundColor: Colors.white,
            backgroundImage: AssetImage("assets/images/profilesample.jpg"),
            radius: 25,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: Color(0xffA7A7A7),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    companyName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffA7A7A7),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetRecentActivity extends StatelessWidget {
  const WidgetRecentActivity({super.key});

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
                  "Recent Activity",
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
          ...List.generate(5, (index) => _activityItem(index)),
        ],
      ),
    );
  }

  _activityItem(int index) {
    List<Color> colors = [
      Colors.purple,
      Colors.green,
      Colors.amber,
      Colors.red,
      Colors.indigo,
    ];
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        backgroundColor: colors[index].withAlpha(50),
        foregroundColor: colors[index],
        child: Icon(Icons.mail_rounded),
      ),
      title: Text(
        "Mail Recieved",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "24 February 2023",
        style: GoogleFonts.poppins(
          fontSize: 13,
        ),
      ),
      trailing: Text(
        "09:50 am",
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

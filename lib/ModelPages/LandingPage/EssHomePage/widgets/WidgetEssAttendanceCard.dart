import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssAttendanceCard extends StatefulWidget {
  const WidgetEssAttendanceCard({super.key});

  @override
  State<WidgetEssAttendanceCard> createState() =>
      _WidgetEssAttendanceCardState();
}

class _WidgetEssAttendanceCardState extends State<WidgetEssAttendanceCard> {
  var style = GoogleFonts.poppins(
      textStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
  ));

  bool clockedIn = false;
  bool swipeStarted = false;

  _swiped() {
    setState(() {
      clockedIn = !clockedIn;
      swipeStarted = false;
    });
  }

  _swipeStarted() {
    setState(() {
      swipeStarted = true;
    });
  }

  _swipeEnded() {
    setState(() {
      swipeStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.24,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Column(
              children: [
                Text("Attendance", style: style),
                SizedBox(
                  height: 10,
                ),
                Text("Work Shift 09:00 - 18:00",
                    style: style.copyWith(color: Color(0xff999999))),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(clockedIn ? "09:08" : "--:--",
                            style: style.copyWith(
                              fontSize: 18,
                            )),
                        Text("Clock In",
                            style: style.copyWith(
                              color: Color(0xff999999),
                              fontSize: 12,
                            )),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("--:--",
                            style: style.copyWith(
                              fontSize: 18,
                            )),
                        Text("Clock Out",
                            style: style.copyWith(
                              color: Color(0xff999999),
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                SwipeButton(
                  // trackPadding: EdgeInsets.all(6),
                  elevationThumb: 2,
                  borderRadius: BorderRadius.circular(10),
                  activeTrackColor:
                      clockedIn ? Color(0xff0D1545) : Color(0xff283FCE),
                  activeThumbColor: Colors.white,
                  thumbPadding: EdgeInsets.all(5),
                  thumb: Icon(
                    Icons.chevron_right,
                    color: clockedIn ? Color(0xff0D1545) : Color(0xff283FCE),
                  ),
                  child: Text(
                    clockedIn ? "Swipe to Clock out" : "Swipe to Clock In ",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: swipeStarted ? Colors.white24 : Colors.white,
                    )),
                  ),
                  onSwipe: _swiped,
                  onSwipeStart: _swipeStarted,
                  onSwipeEnd: _swipeEnded,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

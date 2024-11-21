import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetPlayGround extends StatefulWidget {
  const WidgetPlayGround({super.key});

  @override
  State<WidgetPlayGround> createState() => _WidgetPlayGroundState();
}

class _WidgetPlayGroundState extends State<WidgetPlayGround> {
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
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.zero,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.24,
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                        color:
                            clockedIn ? Color(0xff0D1545) : Color(0xff283FCE),
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
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          width: double.infinity,
          height: MediaQuery.of(context).size.height * .18,
          decoration: BoxDecoration(
              color: Color(0xff4E58EE),
              borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              Positioned(
                left: -100,
                top: -200,
                child: CircleAvatar(
                  radius: 200,
                  backgroundColor: Colors.white10,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Jan month salary credited",
                          style: style.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "20,000.00",
                          style:
                              style.copyWith(fontSize: 40, color: Colors.white),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(
                          Icons.visibility_off,
                          color: Colors.white38,
                        )
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: Icon(
                            Icons.ac_unit,
                            color: Color(0xff3764FC),
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: Icon(
                            Icons.ac_unit,
                            color: Color(0xff3764FC),
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: Icon(
                            Icons.ac_unit,
                            color: Color(0xff3764FC),
                            size: 20,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text("more details",
                        style: style.copyWith(color: Colors.white38)),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

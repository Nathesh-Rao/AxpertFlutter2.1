import 'package:flutter/material.dart';

class WidgetNotification extends StatelessWidget {
  WidgetNotification(String this.text, {super.key});
  String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: Row(
          children: [
            Image.asset(
              'assets/images/announce.png',
              width: 50,
              height: 50,
            ),
            SizedBox(width: 25),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Declare your IT Saving" + text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "IT Declaration goes here.IT Declaration goes here.IT Declaration goes here.IT Declaration goes here.IT Declaration goes here.",
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

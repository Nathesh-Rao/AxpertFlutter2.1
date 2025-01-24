import 'package:flutter/material.dart';

class WidgetESSKPIPanelItem extends StatelessWidget {
  const WidgetESSKPIPanelItem({super.key, required this.index});
//for populating the pseudodata, index is accessing.
  final int index;
  @override
  Widget build(BuildContext context) {
    final double baseSize = MediaQuery.of(context).size.height * .23;
// pseudo data--------->
    List<String> cardNames = [
      "KPI Users",
      "KPI 16/10",
      "KPI CARD_Release13",
      "KPI_Release14",
      "actors",
    ];
    List<String> cardData = [
      "50",
      "8",
      "erertetertre",
      "amit",
      "1",
    ];
    List<int> colors = [
      0xff3764FC,
      0xffed5888,
      0xff9469e5,
      0xffef9a97,
      0xffeeac44,
    ];
//---------------------->

    return GestureDetector(
      onTap: () {
        //---
      },
      child: Container(
        height: baseSize,
        width: baseSize * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(colors[index]),
        ),
        child: Stack(
          children: [
            _widgetKPIItemBGElement(context, right: -60, top: 0, size: 60),
            _widgetKPIItemBGElement(context, right: -7, bottom: -20, size: 35),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: Color(colors[index]),
                    ),
                    radius: 15,
                  ),
                  Spacer(),
                  Text(
                    cardNames[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    cardData[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Faded circle widget------------------------------------>
  _widgetKPIItemBGElement(BuildContext context,
      {double? right, double? top, double? size, double? bottom}) {
    return Positioned(
      right: right,
      top: top,
      bottom: bottom,
      child: CircleAvatar(
        radius: size,
        backgroundColor: Colors.white12,
      ),
    );
  }
}

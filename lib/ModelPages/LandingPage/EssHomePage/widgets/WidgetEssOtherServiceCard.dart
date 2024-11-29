import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetEssOtherServiceCard extends StatelessWidget {
  const WidgetEssOtherServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    var style = GoogleFonts.poppins(
        textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ));
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Other services",
                  style: style,
                ),
                SizedBox(
                  height: 10,
                ),
                Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runAlignment: WrapAlignment.spaceBetween,
                    runSpacing: size.width * 0.03,
                    children: List.generate(
                        8, (index) => _cardItem(size.width / 5.5, index))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardItem(double height, int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.teal,
      Colors.purple,
      Colors.green,
      Colors.amber,
      Colors.red,
      Colors.indigo,
    ];

    if (index == 7) {
      return SizedBox(
        height: height + 10,
        width: height + 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              height: 55,
              width: 55,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: height / 2.7,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "More",
              overflow: TextOverflow.fade,
              style: GoogleFonts.poppins(
                height: 1,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: height + 10,
      width: height + 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
                color: colors[index].withAlpha(50),
                borderRadius: BorderRadius.circular(8)),
            height: 55,
            width: 55,
            child: Icon(
              Icons.receipt_long,
              size: height / 2.7,
              color: colors[index],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Reimbursement",
            overflow: TextOverflow.fade,
            style: GoogleFonts.poppins(
              height: 1,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}

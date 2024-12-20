import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetTabLeavesHub extends StatelessWidget {
  const WidgetTabLeavesHub({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).padding,
      child: Center(
        child: Text(
          "Leaves Hub",
          style: GoogleFonts.poppins(fontSize: 24),
        ),
      ),
    );
  }
}

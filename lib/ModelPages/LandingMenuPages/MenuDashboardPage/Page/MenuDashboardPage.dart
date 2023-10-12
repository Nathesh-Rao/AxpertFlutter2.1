import 'package:axpertflutter/ModelPages/LandingPage/Widgets/WidgetSlidingNotification.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MenuDashboardPage extends StatelessWidget {
  MenuDashboardPage({super.key});
  var data = [
    _ChartData('CHN', 12),
    _ChartData('GER', 15),
    _ChartData('RUS', 30),
    _ChartData('BRZ', 6.4),
    _ChartData('IND', 14)
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidgetSlidingNotificationPanel(),
        SizedBox(height: 5),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: HexColor('EDF0F8')), borderRadius: BorderRadius.circular(10)),
                  child: Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text("Chart Title",
                          style: GoogleFonts.nunito(
                              textStyle:
                                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('495057')))),
                      children: [
                        SizedBox(height: 3),
                        Container(height: 1, color: Colors.grey.withOpacity(0.4)),
                        Container(
                          height: 300,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),

                            // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
                            legend: Legend(
                                isVisible: true,
                                isResponsive: true,
                                toggleSeriesVisibility: true,
                                position: LegendPosition.top),
                            series: <ChartSeries<_ChartData, String>>[
                              ColumnSeries(
                                  dataSource: data,
                                  xValueMapper: (datum, index) => datum.x,
                                  yValueMapper: (datum, index) => datum.y,
                                  dataLabelSettings: DataLabelSettings(isVisible: true))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: HexColor('EDF0F8')), borderRadius: BorderRadius.circular(10)),
                  child: Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text("Chart Title",
                          style: GoogleFonts.nunito(
                              textStyle:
                                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('495057')))),
                      children: [
                        SizedBox(height: 3),
                        Container(height: 1, color: Colors.grey.withOpacity(0.4)),
                        Container(
                          height: 300,
                          child: SfCircularChart(
                            // title: ChartTitle(text: "Circular DataSheet"),
                            legend: Legend(
                                isVisible: true,
                                overflowMode: LegendItemOverflowMode.wrap,
                                isResponsive: true,
                                position: LegendPosition.bottom,
                                orientation: LegendItemOrientation.horizontal,
                                toggleSeriesVisibility: true),
                            series: <CircularSeries>[
                              RadialBarSeries(
                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                dataSource: data,
                                xValueMapper: (datum, index) => datum.x,
                                yValueMapper: (datum, index) => datum.y,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}

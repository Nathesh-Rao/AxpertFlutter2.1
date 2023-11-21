import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuDashboardPage/Models/ChartCardModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WidgetCharts extends StatelessWidget {
  WidgetCharts(this.cardModel, {super.key});
  ChartCardModel cardModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(border: Border.all(width: 2, color: HexColor('EDF0F8')), borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(cardModel.cardname,
              style:
                  GoogleFonts.nunito(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: HexColor('495057')))),
          children: [
            SizedBox(height: 3),
            Container(height: 2, color: HexColor('EDF0F8')),
            Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: chooseChart(cardModel),
            )
          ],
        ),
      ),
    );
  }
}

Widget chooseChart(ChartCardModel cardModel) {
  switch (cardModel.cardtype.toString().toLowerCase()) {
    case 'chart':
      {
        switch (cardModel.charttype.toString().toLowerCase()) {
          case 'bar':
          case 'stacked-bar':
            return getBarChart(cardModel);
          case 'donut':
            return getDonutChart(cardModel);
          case 'pie':
            return getPieChart(cardModel);
          case 'line':
            return getLineChart(cardModel);
          case 'column':
          case 'stacked-column':
            return getColumnChart(cardModel);
          default:
            return Text("");
        }
      }
      break;
    case 'kpi':
      return getKpi(cardModel);
      break;
    default:
      return Text("");
  }
}

Widget getKpi(ChartCardModel cardModel) {
  ChartData cd = cardModel.dataList[0];
  return Padding(
    padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
    child: Row(
      children: [
        Text(
          cd.value.toString() == "null" ? cd.count : cd.value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget getColumnChart(ChartCardModel cardModel) {
  return SfCartesianChart(
    primaryXAxis: CategoryAxis(),

    // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
    legend: Legend(isVisible: true, isResponsive: true, toggleSeriesVisibility: true, position: LegendPosition.top),
    series: <ChartSeries<dynamic, String>>[
      ColumnSeries(
          dataSource: cardModel.dataList,
          xValueMapper: (datum, index) => datum.x_axis,
          yValueMapper: (datum, index) => double.parse(datum.value),
          dataLabelSettings: DataLabelSettings(isVisible: true))
    ],
  );
}

Widget getLineChart(ChartCardModel cardModel) {
  return SfCartesianChart(
    primaryXAxis: CategoryAxis(),

    // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
    legend: Legend(isVisible: true, isResponsive: true, toggleSeriesVisibility: true, position: LegendPosition.top),
    series: <ChartSeries<dynamic, String>>[
      LineSeries(
          name: cardModel.dataList[0].data_label == "" ? "Data" : cardModel.dataList[0].data_label,
          dataSource: cardModel.dataList,
          xValueMapper: (datum, index) => datum.x_axis,
          yValueMapper: (datum, index) => double.parse(datum.value),
          dataLabelSettings: DataLabelSettings(isVisible: true))
    ],
  );
}

Widget getPieChart(ChartCardModel cardModel) {
  return SfCircularChart(
    // title: ChartTitle(text: "Circular DataSheet"),
    legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        isResponsive: true,
        position: LegendPosition.bottom,
        orientation: LegendItemOrientation.horizontal,
        toggleSeriesVisibility: true),
    series: <CircularSeries>[
      PieSeries(
        dataLabelSettings: DataLabelSettings(isVisible: true),
        dataSource: cardModel.dataList,
        explode: true,
        explodeIndex: 0,
        xValueMapper: (datum, index) => datum.data_label,
        yValueMapper: (datum, index) => double.parse(datum.value),
      )
    ],
  );
}

Widget getBarChart(ChartCardModel cardModel) {
  return SfCartesianChart(
    primaryXAxis: CategoryAxis(),

    // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
    legend: Legend(isVisible: true, isResponsive: true, toggleSeriesVisibility: true, position: LegendPosition.top),
    series: <ChartSeries<dynamic, String>>[
      BarSeries(
          name: cardModel.dataList[0].data_label == '' ? " Data" : cardModel.dataList[0].data_label,
          dataSource: cardModel.dataList,
          xValueMapper: (datum, index) => datum.x_axis,
          yValueMapper: (datum, index) => double.parse(datum.value),
          dataLabelSettings: DataLabelSettings(isVisible: true))
    ],
  );
}

Widget getDonutChart(ChartCardModel cardModel) {
  return SfCircularChart(
    // title: ChartTitle(text: "Circular DataSheet"),
    legend: Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        isResponsive: true,
        position: LegendPosition.bottom,
        orientation: LegendItemOrientation.horizontal,
        toggleSeriesVisibility: true),
    series: <CircularSeries>[
      DoughnutSeries(
        dataLabelSettings: DataLabelSettings(isVisible: true),
        dataSource: cardModel.dataList,
        xValueMapper: (datum, index) => datum.data_label,
        yValueMapper: (datum, index) => double.parse(datum.value),
      )
    ],
  );
}

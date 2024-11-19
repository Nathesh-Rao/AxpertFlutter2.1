import 'package:flutter/material.dart';

import '../../Models/sampleHomeConfigModel.dart';
import 'WidgetHomeConfigPanelInnerItem.dart';

class WidgetHomeConfigPanelItem extends StatelessWidget {
  const WidgetHomeConfigPanelItem(
      {super.key, required this.panelItems, required this.keyname});
  final List<SampleConfigModelItemModel> panelItems;
  final String keyname;
  @override
  Widget build(BuildContext context) {
    //
    final double baseSize = MediaQuery.of(context).size.height * .25;
    //------generating
    generateItems() {
      List<Widget> items = List.generate(panelItems.length,
          (index) => WidgetConfigPanelInnerItem(item: panelItems[index]));

      if (items.length >= 8) {
        items = items.sublist(0, 7);
        items.add(WidgetConfigPanelMoreWidgetItem(
          items: panelItems,
        ));
      } else {
        items = items;
      }
      return items;
    }

    // List<Widget> panelItems = generateItems(baseItems);
    // List<Widget> panelItems = baseItems;

    //---------------------->
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            keyname,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Card(
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.zero,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // color: Color(0xffeeeff9),
            color: Colors.white,
            child: Container(
              padding: EdgeInsets.all(15),
              height: baseSize,
              width: double.infinity,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.spaceBetween,
                children: generateItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

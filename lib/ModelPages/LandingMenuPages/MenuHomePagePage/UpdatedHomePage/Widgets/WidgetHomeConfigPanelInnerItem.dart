import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/sampleHomeConfigModel.dart';
import 'WidgetHomeConfigPanelBottomSheet.dart';

class WidgetConfigPanelInnerItem extends StatelessWidget {
  const WidgetConfigPanelInnerItem({super.key, required this.item});
  final SampleConfigModelItemModel item;
  @override
  Widget build(BuildContext context) {
    final double baseSize = MediaQuery.of(context).size.height * .25;
    final double basewidth = MediaQuery.of(context).size.width - 30;
    // Generate a random color
    Color _generateRandomColor() {
      Random random = Random();
      return Color.fromARGB(
        255,
        random.nextInt(122),
        random.nextInt(122),
        random.nextInt(122),
      );
    }

    var color = _generateRandomColor();

    return SizedBox(
      width: (basewidth / 4) - 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(100),
            child: CircleAvatar(
              backgroundColor: color.withAlpha(30),
              foregroundColor: Colors.black,
              radius: baseSize / 9,
              child: Icon(
                item.icon,
                color: color,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            height: baseSize / 7,
            child: Text(
              item.data,
              textAlign: TextAlign.center,
              style: TextStyle(
                overflow: TextOverflow.fade,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//-------------------------------------------->
class WidgetConfigPanelMoreWidgetItem extends StatelessWidget {
  const WidgetConfigPanelMoreWidgetItem({super.key, required this.items});
  final List<SampleConfigModelItemModel> items;
  @override
  Widget build(BuildContext context) {
    final double baseSize = MediaQuery.of(context).size.height * .25;

    final double basewidth = MediaQuery.of(context).size.width - 30;
    List<Widget> baseItems = List.generate(
        items.length,
        (index) => WidgetConfigPanelInnerItem(
              item: items[index],
            ));
    return SizedBox(
      width: (basewidth / 4) - 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Get.bottomSheet(WidgetHomeConfigPanelBottomSheet(
                baseItems: baseItems,
              ));
            },
            borderRadius: BorderRadius.circular(100),
            splashColor: Colors.white60,
            child: CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black87,
              radius: baseSize / 9,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 30,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "More",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

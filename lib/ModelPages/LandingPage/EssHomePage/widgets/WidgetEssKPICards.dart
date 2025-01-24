import 'package:flutter/material.dart';

import 'WidgetEssKPIPanelItem.dart';

class WidgetEssKPICards extends StatelessWidget {
  const WidgetEssKPICards({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.20,
        child: ListView.separated(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 15),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => SizedBox(
                  width: 20,
                ),
            itemBuilder: (context, index) => WidgetESSKPIPanelItem(
                  index: index,
                )),
      ),
    );
  }
}

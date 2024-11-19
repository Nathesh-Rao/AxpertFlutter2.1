import 'package:flutter/material.dart';

import '../../Models/sampleHomeConfigModel.dart';
import 'WidgetHomeConfigPanelItem.dart';

class WidgetHomeConfigPanels extends StatelessWidget {
  const WidgetHomeConfigPanels({super.key});

  @override
  Widget build(BuildContext context) {
    //

//------------ generating widgets with sample model----->

    final SampleHomeConfigModelGenerator model =
        SampleHomeConfigModelGenerator();
    var panelModel = model.sampleHomeConfigModel;
    List<String> keys = model.sampleHomeConfigModel.keys.toList();
    List<Widget> panelWidgets = List.generate(
        keys.length,
        (index) => WidgetHomeConfigPanelItem(
              keyname: keys[index],
              panelItems: panelModel[keys[index]]!,
            ));

    //----------------- panle widget----->
    return Visibility(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: panelWidgets,
        ),
      ),
    );
  }
}

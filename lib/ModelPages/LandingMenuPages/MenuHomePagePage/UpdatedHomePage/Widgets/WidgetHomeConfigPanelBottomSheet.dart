import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetHomeConfigPanelBottomSheet extends StatelessWidget {
  const WidgetHomeConfigPanelBottomSheet({super.key, required this.baseItems});
  final List<Widget> baseItems;

  @override
  Widget build(BuildContext context) {
    final double basewidth = MediaQuery.of(context).size.width - 30;

    return Container(
      height: basewidth,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(20))),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Spacer(),
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.cancel)),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.builder(
                itemCount: baseItems.length,
                // physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 15),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (context, index) => baseItems[index]),
          )
        ],
      ),
    );
  }
}

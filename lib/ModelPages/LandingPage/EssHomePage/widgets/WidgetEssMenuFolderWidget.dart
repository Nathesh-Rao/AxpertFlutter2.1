import 'package:axpertflutter/ModelPages/LandingPage/EssHomePage/controller/EssController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetEssMenuFolders extends StatelessWidget {
  WidgetEssMenuFolders({super.key});
  final EssController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.list_menuFolderData.length > 0 ? true : false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.getMenuFolderPanelWidgetList(),
          ),
        ),
      ),
    );
  }
}

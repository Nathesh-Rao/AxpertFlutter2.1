import 'package:axpertflutter/Constants/MyColors.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_form_controller.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/widgets/offline_attachments_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/offline_form_field_widgets.dart';

class OfflineFormPage extends GetView<OfflineFormController> {
  const OfflineFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(controller.page.caption),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                controller.validateForm();
              },
              icon: Icon(Icons.check_circle))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Column(
            spacing: 15,
            // children: controller.fieldMap.values
            //     .map((f) => OfflineFormField(field: f))
            //     .toList(),
            children: [
              if (controller.page.attachments)
                const OfflineAttachmentsSection(),
              ...controller.fieldMap.values
                  .map((f) => OfflineFormField(field: f))
                  .toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: controller.page.attachments
          ? FloatingActionButton(
              backgroundColor: MyColors.blue9,
              child: Icon(CupertinoIcons.paperclip),
              onPressed: controller.pickAttachment)
          : null,
    );
  }
}

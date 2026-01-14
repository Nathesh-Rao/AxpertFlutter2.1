import 'package:axpertflutter/Constants/GlobalVariableController.dart';
import 'package:axpertflutter/ModelPages/LandingMenuPages/offline_form_pages/controller/offline_form_controller.dart';
import 'package:get/get.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(GlobalVariableController(), permanent: true);
    Get.put(OfflineFormController(), permanent: true);
  }
}

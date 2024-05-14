import 'package:axpertflutter/Constants/AppStorage.dart';
import 'package:get/get.dart';

class SettingsPageController extends GetxController {
  var notificationOnOffValue = false.obs;
  AppStorage appStorage = AppStorage();

  SettingsPageController() {
    getNotifyDetails();
  }
  getNotifyDetails() async {
    notificationOnOffValue.value = await appStorage.retrieveValue(AppStorage.isShowNotifyEnabled);
  }

  setNotifyValue(value) async {
    notificationOnOffValue.value = value;
    await appStorage.storeValue(AppStorage.isShowNotifyEnabled, value);
  }

  onChangeNotifyStatus() async {
    notificationOnOffValue.toggle();
    await setNotifyValue(notificationOnOffValue.value);
  }
}

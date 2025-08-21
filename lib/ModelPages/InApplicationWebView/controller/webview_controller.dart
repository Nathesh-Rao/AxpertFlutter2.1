import 'package:axpertflutter/ModelPages/LandingPage/Controller/LandingPageController.dart';
import 'package:axpertflutter/ModelPages/LoginPage/Controller/LoginController.dart';
import 'package:axpertflutter/Utils/LogServices/LogService.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebViewController extends GetxController {
  var currentIndex = 0.obs;
  var currentUrl = ''.obs;
  var previousUrl = '';
  var isWebViewLoading = false.obs;
  var inAppWebViewController = Rxn<InAppWebViewController>();

  // LandingPageController landingPageController = Get.find();
  LoginController loginController = Get.find();

  openWebView({required String url}) async {
    LandingPageController landingPageController = Get.find();
    if (!landingPageController.isAxpertConnectEstablished) {
      await landingPageController.callApiForConnectToAxpert();
    }

    if (landingPageController.isAxpertConnectEstablished) {
      currentUrl.value = url;

      await inAppWebViewController.value!
          .loadUrl(
            urlRequest: URLRequest(
              url: WebUri(url),
            ),
          )
          .then((_) {});
      currentIndex.value = 1;
    }
  }

  closeWebView() {
    currentIndex.value = 0;
  }

  signOut({required String url}) async {
    // currentUrl.value = url;

    await inAppWebViewController.value!
        .loadUrl(
          urlRequest: URLRequest(
            url: WebUri(url),
          ),
        )
        .then((_) {});
  }
}

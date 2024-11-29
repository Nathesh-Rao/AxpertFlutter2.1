import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EssController extends GetxController {
  @override
  void onInit() {
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

//-----Appbar control---------
  final ScrollController scrollController = ScrollController();

  var appBarColor = Colors.transparent.obs;

  var appbarGradient = LinearGradient(colors: [
    Colors.transparent,
    Colors.transparent,
  ]);
  void _scrollListener() {
    double offset = scrollController.offset;
    appBarColor.value = offset > 0
        ? Color(0xff9764DA).withOpacity((offset / 200).clamp(0, 1))
        : Colors.transparent;

    appbarGradient = LinearGradient(colors: [
      Color(0xff3764FC).withOpacity((offset / 200).clamp(0, 1)),
      Color(0xff9764DA).withOpacity((offset / 200).clamp(0, 1)),
    ]);
  }
//----------------------------
}

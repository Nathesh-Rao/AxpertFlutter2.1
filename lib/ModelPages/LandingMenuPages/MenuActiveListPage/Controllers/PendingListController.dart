import 'package:axpertflutter/ModelPages/LandingMenuPages/MenuActiveListPage/Models/StatusModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class PendingListController extends GetxController {
  var subPage = true.obs;
  List<StatusModel> StatusList = [
    StatusModel("1", "Ticket Initiation"),
    StatusModel("2", "Support Check"),
    StatusModel("3", "RM Approval"),
    StatusModel("4", "Approval By Developer"),
  ];
  var statusListActiveIndex = 2;

  ScrollController scrollController = ScrollController(initialScrollOffset: 100 * 1.0);
}

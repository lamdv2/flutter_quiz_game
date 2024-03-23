import 'package:flutter_getx_base/modules/home/home_tab_controller.dart';
import 'package:flutter_getx_base/modules/main/home_controller.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final HomeTabController homeTabController = Get.find();
  final HomeController homeController = Get.find();

  void callTrueFalseQuestion() {
    homeController.bottomNavIndex.value = 0;
    homeTabController.fetchDataTrueFalseQuestion();
  }

  void callChooseQuestion() {
    homeController.bottomNavIndex.value = 0;
    homeTabController.fetchDataChooseQuestion();
  }
}

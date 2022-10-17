import 'package:get/get.dart';

class ProgressBarController extends GetxController {
  static ProgressBarController get i => Get.find();
  var currentPage = 1.obs;

  void increment() {
    currentPage.value++;
  }

  void decrement() {
    currentPage.value--;
  }
}

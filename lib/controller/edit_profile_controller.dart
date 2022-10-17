import 'package:get/get.dart';

class EditProfileController extends GetxController {
  var tempUrls = [].obs;

  void setTempUrls(String urls) {
    tempUrls.add(urls);
  }

  void delTempUrls() {
    tempUrls.clear();
  }
}

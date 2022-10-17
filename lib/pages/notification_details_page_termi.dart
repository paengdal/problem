import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_first/controller/notification_details_page_controller.dart';

// Push Notification 을 터치했을 때 이동할 페이지
class NotificationDetailsPageTermi
    extends GetView<NotificationDetailsPageController> {
  const NotificationDetailsPageTermi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationDetailsPageController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Termi'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'payload Termi: ',
              style: TextStyle(fontSize: 20),
            ),
            Obx(() => Text(controller.argument.value)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          titleSpacing: 0,
          leadingWidth: 50,
          leading: IconButton(
            icon: Icon(CupertinoIcons.arrow_left),
            // constraints: BoxConstraints(),
            iconSize: 22,
            padding: const EdgeInsets.all(0),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text('알림'),
        ),
        body: Container(
          color: Colors.amber,
        ));
  }
}

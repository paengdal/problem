import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizDetailScreen extends StatelessWidget {
  QuizDetailScreen({Key? key}) : super(key: key);

  final itemKey = Get.parameters['itemKey'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text(
          '${itemKey}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

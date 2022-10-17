import 'package:flutter/material.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/view/screens/input/my_item_list.dart';

class AddItem extends StatelessWidget {
  const AddItem({Key? key, this.addItem}) : super(key: key);
  final addItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('문제 추가'),
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            // Text('문제집에 추가할 문제를 선택해 주세요.'),
            MyItemList(
              addItem: addItem,
            ),
          ],
        ));
  }
}

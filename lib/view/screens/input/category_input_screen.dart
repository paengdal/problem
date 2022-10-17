import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';

class CategoryInputScreen extends StatelessWidget {
  const CategoryInputScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          '문제 카테고리',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (constraints, index) {
          return Padding(
            padding: const EdgeInsets.only(left: common_l_gap),
            child: (index != 0)
                ? ListTile(
                    shape: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    onTap: () {
                      context.read<CategoryNotifier>().setNewCategoryWithKor(
                          categoriesMapEngToKor.values.elementAt(index));
                      Get.back();
                    },
                    title: Text(
                      categoriesMapEngToKor.values.elementAt(index),
                      style: TextStyle(
                        fontFamily: (context
                                    .read<CategoryNotifier>()
                                    .SelectedCategoryInKor ==
                                categoriesMapEngToKor.values.elementAt(index))
                            ? 'SDneoB'
                            : 'SDneoL',
                      ),
                    ),
                  )
                : Container(),
          );
        },
        itemCount: categoriesMapEngToKor.length,
      ),
    );
  }
}

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/view/screens/input_screen_in_book.dart';

import '../input_screen.dart';

class MyItemListInProfile extends StatelessWidget {
  final setNumOfMyItems;
  const MyItemListInProfile({Key? key, this.setNumOfMyItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userKey = FirebaseAuth.instance.currentUser!.uid;
    return FutureBuilder<List<ItemModel>>(
        future: ItemService().getMyItems(userKey),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<ItemModel> _myItems = snapshot.data!;
            setNumOfMyItems(_myItems.length);
            return ListView.separated(
              reverse: true,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _myItems.length,
              itemBuilder: (BuildContext context, int index) {
                var myItem = _myItems[index];
                return InkWell(
                  onTap: () {},
                  onLongPress: () {
                    Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
                        content: Text('퀴즈를 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ItemService().deleteItem(_myItems, myItem, index, userKey);
                              // setState(() {});
                              // Get.offAllNamed('/');
                              Get.back();
                            },
                            child: Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('취소'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(common_xxxs_gap, 0, common_xxxs_gap, 0),
                    child: Container(
                      // height: 120,
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(10),
                      //   shape: BoxShape.rectangle,
                      // ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: common_xxs_gap),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${myItem.question}',
                                          style: TextStyle(fontSize: 15, fontFamily: 'SDneoR'),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${categoriesMapEngToKor[myItem.category]}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                (myItem.imageDownloadUrls.isNotEmpty)
                                    ? ExtendedImage.network(
                                        myItem.imageDownloadUrls[0],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : Stack(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            color: Colors.grey[200],
                                          ),
                                          Positioned(
                                            left: 10,
                                            top: 10,
                                            child: Icon(
                                              CupertinoIcons.photo,
                                              size: 20,
                                              color: Colors.grey[350],
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            // Divider(
                            //   thickness: 1,
                            //   height: 27,
                            //   indent: 0,
                            //   endIndent: 90,
                            //   color: Colors.grey[200],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  thickness: 1,
                  height: 23,
                  indent: common_m_gap,
                  endIndent: 60,
                  color: Colors.grey[200],
                );
              },
            );
          } else {
            return Container();
          }
        });
  }
}

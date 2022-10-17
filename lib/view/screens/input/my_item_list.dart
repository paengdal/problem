import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/view/screens/input_screen_in_book.dart';

import '../input_screen.dart';

class MyItemList extends StatelessWidget {
  final addItem;
  const MyItemList({Key? key, this.addItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemModel>>(
        future:
            ItemService().getMyItems(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<ItemModel> _myItems = snapshot.data!;
            return ListView.builder(
              reverse: true,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _myItems.length,
              itemBuilder: (BuildContext context, int index) {
                var myItem = _myItems[index];
                return InkWell(
                  onTap: () {
                    addItem(myItem);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        common_m_gap, 0, common_m_gap, 0),
                    child: Container(
                      // height: 120,
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(10),
                      //   shape: BoxShape.rectangle,
                      // ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: common_xxs_gap),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${myItem.question}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: 'SDneoR'),
                                        ),
                                        Text(
                                          '${categoriesMapEngToKor[myItem.category]}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 14,
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
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Stack(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[200],
                                          ),
                                          Positioned(
                                            left: 13,
                                            top: 30,
                                            child: Text(
                                              'no image',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            Divider(
                              thickness: 1,
                              height: 27,
                              indent: 0,
                              endIndent: 90,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            // return Column(
            //   children: [
            //     SizedBox(
            //       height: 100,
            //     ),
            //     Container(
            //       child: Text(
            //         '만들어진 문제가 없습니다.',
            //         style: TextStyle(color: Colors.grey[400], fontSize: 20),
            //       ),
            //     ),
            //     Container(
            //       child: Text(
            //         '문제를 먼저 만들어 주세요.',
            //         style: TextStyle(color: Colors.grey[400], fontSize: 20),
            //       ),
            //     ),
            //     SizedBox(
            //       height: 40,
            //     ),
            //     ElevatedButton(
            //       onPressed: () {
            //         Get.back();
            //         Get.toNamed('/inputInBook');
            //         // Get.to(InputScreenInBook());
            //       },
            //       child: Text('문제 만들기'),
            //       style: ElevatedButton.styleFrom(
            //           primary: Colors.teal, elevation: 0),
            //     ),
            //   ],
            // );
            return Container();
          }
        });
  }
}

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/view/screens/input_book_screen.dart';

class MyBookList extends StatelessWidget {
  final setNumOfMyBooks;
  const MyBookList({Key? key, this.setNumOfMyBooks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userKey = FirebaseAuth.instance.currentUser!.uid;
    return FutureBuilder<List<BookModel>>(
        future: BookService().getMyBooks(userKey),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<BookModel> _myBooks = snapshot.data!;
            setNumOfMyBooks(_myBooks.length);
            return ListView.separated(
              reverse: true,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _myBooks.length,
              itemBuilder: (BuildContext context, int index) {
                var myBook = _myBooks[index];
                return InkWell(
                  // splashColor: Colors.transparent,
                  onTap: () {
                    // 이미 푼 문제인지 체크
                    var userKeys = [];
                    for (int i = 0; i < myBook.solvedUsersAndScore.length; i++) {
                      userKeys.add(myBook.solvedUsersAndScore[i].userKey);
                    }
                    if (!(userKeys.contains(userKey))) {
                      Get.toNamed('/bookDetail/${myBook.bookKey}', arguments: myBook);
                    } else {
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('이미 푼 문제집입니다. 다시 풀더라도 최초에 기록된 점수는 갱신되지 않습니다. 그래도 다시 풀어보시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                Get.toNamed('/bookDetail/${myBook.bookKey}', arguments: myBook);
                              },
                              child: Text('다시 풀기'),
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
                    }
                  },
                  onLongPress: () {
                    Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
                        content: Text('문제집을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              BookService().deleteBook(_myBooks, myBook, index, userKey);
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
                                          '${myBook.bookTitle}',
                                          style: TextStyle(fontSize: 15, fontFamily: 'SDneoM'),
                                        ),
                                        Text(
                                          '${myBook.bookDesc}',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey,
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
                                (myBook.imageDownloadUrls.isNotEmpty)
                                    ? ExtendedImage.network(
                                        myBook.imageDownloadUrls[0],
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

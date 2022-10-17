import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/controller/progress_bar_controller.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/view/screens/feed/book_detail_screen.dart';
import 'package:quiz_first/view/screens/feed/book_detail_screen_list.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

import '../../../repo/user_network_repository.dart';

class BookResultScreen extends StatelessWidget {
  final itemKeys;
  final indexOfCorrect;
  final indexOfUnCorrect;
  final bookItems;
  final BookModel bookModel;
  const BookResultScreen({Key? key, this.itemKeys, this.indexOfCorrect, this.indexOfUnCorrect, this.bookItems, required this.bookModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('결과 확인'),
      //   automaticallyImplyLeading: false,
      // ),
      body: SafeArea(
        child: CustomScrollView(
          // shrinkWrap: true,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '당신의 점수는?',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'SDneoB',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(indexOfCorrect.length / itemKeys.length * 100).round()}',
                            style: TextStyle(
                              fontSize: 70,
                              fontFamily: 'SDneoB',
                              color: (indexOfCorrect.length / itemKeys.length * 100).round() >= 80
                                  ? Colors.blue
                                  : (indexOfCorrect.length / itemKeys.length * 100).round() >= 50
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                          Text(
                            '점',
                            style: TextStyle(
                              fontSize: 45,
                              fontFamily: 'SDneoM',
                              color: (indexOfCorrect.length / itemKeys.length * 100).round() >= 80
                                  ? Colors.blue
                                  : (indexOfCorrect.length / itemKeys.length * 100).round() >= 50
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${itemKeys.length}개의 문제 중 ${indexOfCorrect.length}개의 정답을 맞혔습니다.',
                        style: TextStyle(fontSize: 15, fontFamily: 'SDneoM', color: Colors.black45),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      FutureBuilder<BookModel>(
                          future: BookService().getBookByBookKey(bookModel.bookKey),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              BookModel _bookModel = snapshot.data!;

                              return ListView.builder(
                                reverse: true,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _bookModel.solvedUsersAndScore.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _bookModel.solvedUsersAndScore[index].userKey != FirebaseAuth.instance.currentUser!.uid
                                      ? StreamProvider<UserModel?>.value(
                                          value: userNetworkRepository.getUserModelStream(_bookModel.solvedUsersAndScore[index].userKey),
                                          initialData: null,
                                          child: Consumer<UserModel?>(
                                            builder: (BuildContext context, UserModel? userModel, Widget? child) {
                                              if (userModel != null) {
                                                return Padding(
                                                  padding: const EdgeInsets.fromLTRB(100, 5, 100, 0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      RoundedAvatar(
                                                        avatarSize: 24,
                                                        userModel: userModel,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Consumer<UserModel>(
                                                        builder: (BuildContext context, UserModel userModel, Widget? child) {
                                                          return Text(
                                                            // '${(_bookModel.solvedUsersAndScore[index].username)}',
                                                            '${userModel.username}',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily: 'SDneoSB',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      Expanded(child: SizedBox()),
                                                      Text(
                                                        '${(_bookModel.solvedUsersAndScore[index].scoreOfBook)}점',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: 'SDneoM',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return Container();
                                              }
                                            },
                                          ),
                                        )
                                      : Container();
                                },
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
            // ------------------ 틀린 문제 정답 확인
            // SizedBox(
            //   height: 160,
            // ),
            // ListView.builder(
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemCount: indexOfUnCorrect.length,
            //     itemBuilder: (context, index) {
            //       // return ListTile(
            //       //   tileColor: Colors.amber,
            //       //   dense: true,
            //       //   leading: Text(
            //       //     '${indexOfUnCorrect[index] + 1}번: ${bookItems[indexOfUnCorrect[index]].answer}. ${(bookItems[indexOfUnCorrect[index]].options)[int.parse(bookItems[indexOfUnCorrect[index]].answer) - 1]}',
            //       //     style: TextStyle(fontSize: 20),
            //       //   ),
            //       // );
            //       return Padding(
            //         padding: const EdgeInsets.fromLTRB(
            //             common_m_gap, 0, common_m_gap, 0),
            //         child: Container(
            //           // height: 120,
            //           // decoration: BoxDecoration(
            //           //   color: Colors.white,
            //           //   borderRadius: BorderRadius.circular(10),
            //           //   shape: BoxShape.rectangle,
            //           // ),
            //           child: Padding(
            //             padding:
            //                 EdgeInsets.symmetric(horizontal: common_xxs_gap),
            //             child: Column(
            //               children: [
            //                 Row(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Expanded(
            //                       child: Container(
            //                         child: Column(
            //                           mainAxisAlignment:
            //                               MainAxisAlignment.start,
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start,
            //                           children: [
            //                             Text(
            //                               '${myItem.question}',
            //                               style: TextStyle(
            //                                   fontSize: 18,
            //                                   fontFamily: 'SDneoR'),
            //                             ),
            //                             Text(
            //                               '${categoriesMapEngToKor[myItem.category]}',
            //                               style: TextStyle(
            //                                 color: Colors.blue,
            //                                 fontSize: 14,
            //                               ),
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ),
            //                     SizedBox(
            //                       width: 10,
            //                     ),
            //                     (myItem.imageDownloadUrls.isNotEmpty)
            //                         ? ExtendedImage.network(
            //                             myItem.imageDownloadUrls[0],
            //                             width: 80,
            //                             height: 80,
            //                             fit: BoxFit.cover,
            //                           )
            //                         : Stack(
            //                             children: [
            //                               Container(
            //                                 width: 80,
            //                                 height: 80,
            //                                 color: Colors.grey[200],
            //                               ),
            //                               Positioned(
            //                                 left: 13,
            //                                 top: 30,
            //                                 child: Text(
            //                                   'no image',
            //                                   style:
            //                                       TextStyle(color: Colors.grey),
            //                                 ),
            //                               ),
            //                             ],
            //                           ),
            //                   ],
            //                 ),
            //                 Divider(
            //                   thickness: 1,
            //                   height: 27,
            //                   indent: 0,
            //                   endIndent: 90,
            //                   color: Colors.grey[200],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     }),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 160,
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xff1a68ff),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            Get.offAllNamed('/');
                          },
                          child: Text('메인으로'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            elevation: 0,
                            side: BorderSide(
                              width: 1.0,
                              color: Color(0xff1a68ff),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            Get.dialog(
                              barrierDismissible: false,
                              AlertDialog(
                                content: Text('이미 푼 문제집입니다. 다시 풀더라도 최초에 기록된 점수는 갱신되지 않습니다. 그래도 다시 풀어보시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      ProgressBarController.i.currentPage.value = 1;
                                      Get.toNamed('/bookDetail/${bookModel.bookKey}', arguments: bookModel);
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
                          },
                          child: Text(
                            '다시 풀기',
                            style: TextStyle(color: Color(0xff1a68ff)),
                          ),
                        ),
                      ),
                      indexOfUnCorrect.length != 0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: common_s_gap),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.transparent,
                                  elevation: 0,
                                  side: BorderSide(
                                    width: 1.0,
                                    color: Color(0xff1a68ff),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  Get.toNamed('/bookDetailList/${bookModel.bookKey}', arguments: bookModel);
                                },
                                child: Text(
                                  '틀린 문제 정답 확인',
                                  style: TextStyle(color: Color(0xff1a68ff)),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

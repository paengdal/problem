import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/comment_network_repository.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/comments_screen.dart';
import 'package:quiz_first/view/screens/input_book_screen_modifiy.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class NoticePost extends StatelessWidget {
  final List<BookModel> bookModels;
  const NoticePost({Key? key, required this.bookModels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizedBoxH = SizedBox(
      height: 10,
    );
    final userKey = FirebaseAuth.instance.currentUser!.uid;

    return (bookModels.isNotEmpty)
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: bookModels.length,
            itemBuilder: (BuildContext context, int index) {
              var bookModel = bookModels[index];
              return MultiProvider(
                providers: [
                  StreamProvider<List<CommentModel>>.value(
                    initialData: [],
                    value: commentNetworkRepository
                        .fetchAllCommentsOfBook(bookModel.bookKey),
                  ),
                  StreamProvider<UserModel?>.value(
                      value: userNetworkRepository
                          .getUserModelStream(bookModel.userKey),
                      initialData: null),
                ],
                child: Consumer<List<CommentModel>>(
                  builder: (context, comments, child) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                          common_l_gap, 0, common_l_gap, common_l_gap),
                      child: GestureDetector(
                        onTap: () {
                          // 이미 푼 문제인지 체크
                          var userKeys = [];
                          for (int i = 0;
                              i < bookModel.solvedUsersAndScore.length;
                              i++) {
                            userKeys
                                .add(bookModel.solvedUsersAndScore[i].userKey);
                          }
                          if (!(userKeys.contains(userKey))) {
                            Get.toNamed('/bookDetail/${bookModel.bookKey}',
                                arguments: bookModel);
                          } else {
                            Get.dialog(
                              barrierDismissible: false,
                              AlertDialog(
                                content: Text(
                                    '이미 푼 문제집입니다. 다시 풀더라도 최초에 기록된 점수는 갱신되지 않습니다. 그래도 다시 풀어보시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.toNamed(
                                          '/bookDetail/${bookModel.bookKey}',
                                          arguments: bookModel);
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
                                    BookService().deleteBook(
                                        bookModels, bookModel, index, userKey);
                                    // setState(() {});
                                    Get.offAllNamed('/');
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
                        child: Consumer<UserModel>(
                          builder: (BuildContext context, UserModel userModel,
                              Widget? child) {
                            return Card(
                              elevation: 18,
                              shadowColor: Colors.black54,
                              // color: Color(0xFF56637a),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  shape: BoxShape.rectangle,
                                  color: Color(0xff3d83f8),
                                ),
                                // height: 400,
                                // color: Color(0xFF56637a),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    bookModel.imageDownloadUrls.isNotEmpty
                                        ? Container(
                                            height: 180,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                              color: Colors.grey[200],
                                            ),
                                            child: ExtendedImage.network(
                                              '${bookModel.imageDownloadUrls[0]}',
                                              fit: BoxFit.cover,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 4,
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          common_l_gap,
                                          common_l_gap,
                                          common_l_gap,
                                          4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${bookModel.bookTitle}',
                                              style: TextStyle(
                                                fontFamily: 'SDneoB',
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white30,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2),
                                              child: Text(
                                                '${bookModel.bookItems.length}문제',
                                                style: TextStyle(
                                                  fontFamily: 'SDneoM',
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: common_l_gap),
                                      child: Container(
                                        height: 94,
                                        child: Text(
                                          "${bookModel.bookDesc}",
                                          style: TextStyle(
                                            fontFamily: 'SDneoR',
                                            color: Colors.white60,
                                            fontSize: 15,
                                            height: 1.5,
                                            letterSpacing: -0.5,
                                            wordSpacing: 3,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: common_l_gap),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${bookModel.createDate}',
                                            style: TextStyle(
                                              fontFamily: 'SDneoR',
                                              color: Colors.white70,
                                              fontSize: 13,
                                              height: 1.5,
                                              letterSpacing: -0.5,
                                              wordSpacing: 3,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(CommentsScreen(
                                                bookKey: bookModel.bookKey,
                                              ));
                                            },
                                            child: Text(
                                              (comments.length != 0)
                                                  ? '${comments.length}개의 댓글'
                                                  : '댓글쓰기',
                                              style: TextStyle(
                                                fontFamily: 'SDneoR',
                                                color: Colors.white70,
                                                fontSize: 13,
                                                height: 1.5,
                                                letterSpacing: -0.5,
                                                wordSpacing: 3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    sizedBoxH,
                                    Divider(
                                      height: 1,
                                      color: Colors.grey[400],
                                      // indent: common_padding,
                                      // endIndent: common_padding,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)),
                                        shape: BoxShape.rectangle,
                                      ),
                                      height: 54,
                                      child: Consumer<UserModelState>(
                                        builder: (BuildContext context,
                                            UserModelState userModelState,
                                            Widget? child) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: common_l_gap),
                                            child: Row(
                                              // 문제집 작성자 표시 부분
                                              children: [
                                                // RoundedAvatar(
                                                //   avatarSize: 28,
                                                // ),
                                                SizedBox(
                                                  width: 6,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(
                                                        fontFamily: 'SDneoSB',
                                                        fontSize: 15),
                                                  ),
                                                ),
                                                IconButton(
                                                  padding: EdgeInsets.all(
                                                      common_xxs_gap),
                                                  iconSize: 20,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () {
                                                    userNetworkRepository
                                                        .toggleLikeToUserDataOfBook(
                                                            userModelState
                                                                .userModel!
                                                                .userKey,
                                                            bookModel.bookKey);
                                                    BookService()
                                                        .toggleLikeToBookData(
                                                            userModelState
                                                                .userModel!
                                                                .userKey,
                                                            bookModel.bookKey);
                                                  },
                                                  icon: !(userModelState
                                                          .userModel!.likedBooks
                                                          .contains(bookModel
                                                              .bookKey))
                                                      //          ||
                                                      // !_heartToggle!
                                                      ? Icon(
                                                          CupertinoIcons
                                                              .suit_heart,
                                                          color: Colors.white70,
                                                        )
                                                      : Icon(
                                                          CupertinoIcons
                                                              .suit_heart_fill,
                                                          color: Colors.red,
                                                        ),
                                                ),
                                                Consumer<List<dynamic>>(
                                                  builder:
                                                      (BuildContext context,
                                                          List<dynamic>
                                                              likedBookKeys,
                                                          Widget? child) {
                                                    var _likedCount = [];
                                                    for (int i = 0;
                                                        i <
                                                            likedBookKeys
                                                                .length;
                                                        i++) {
                                                      if (likedBookKeys[i] ==
                                                          bookModel.bookKey) {
                                                        _likedCount.add(
                                                            likedBookKeys[i]);
                                                      }
                                                    }
                                                    return Container(
                                                      child: Text(
                                                        '${_likedCount.length}',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'SDneoB',
                                                            color:
                                                                Colors.white70),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          )
        : Container();
  }
}

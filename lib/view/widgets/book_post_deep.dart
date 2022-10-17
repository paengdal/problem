import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/constants/mode_of_book.dart';
import 'package:quiz_first/constants/solving_status.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/comment_network_repository.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/time_calculation.dart';
import 'package:quiz_first/view/screens/comments_screen.dart';
import 'package:quiz_first/view/screens/input_book_screen_modifiy.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class BookPostDeep extends StatefulWidget {
  final BookModel bookModel;
  final List<BookModel> bookModels;
  final int postIndex;
  const BookPostDeep({Key? key, required this.bookModel, required this.bookModels, required this.postIndex}) : super(key: key);

  @override
  State<BookPostDeep> createState() => _BookPostDeepState();
}

class _BookPostDeepState extends State<BookPostDeep> {
  SolvingStatus _solvingStatus = SolvingStatus.notYet;
  final sizedBoxH = SizedBox(
    height: 10,
  );

  final userKey = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<CommentModel>>.value(
          initialData: [],
          value: commentNetworkRepository.fetchAllCommentsOfBook(widget.bookModel.bookKey),
        ),
        StreamProvider<UserModel?>.value(
          value: userNetworkRepository.getUserModelStream(widget.bookModel.userKey),
          initialData: null,
        ),
      ],
      child: Consumer<List<CommentModel>>(
        builder: (context, comments, child) {
          // 답글 총 개수 구하기
          var numOfCommentReplies = 0;
          for (int i = 0; i < comments.length; i++) {
            numOfCommentReplies = numOfCommentReplies + comments[i].numOfcommentReplies;
          }
          // 문제를 푼 사용자의 userKey 리스트 구하기
          // var userKeys = [];
          // for (int i = 0; i < widget.bookModel.solvedUsersAndScore.length; i++) {
          //   userKeys.add(widget.bookModel.solvedUsersAndScore[i].userKey);
          // }

          bool _isSolved = false;
          int _score = 0;
          int _pageNum = 0;
          for (int i = 0; i < widget.bookModel.solvedUsersAndScore.length; i++) {
            if (widget.bookModel.solvedUsersAndScore[i].userKey == userKey) {
              if (widget.bookModel.solvedUsersAndScore[i].solvingStatus == SolvingStatus.done.code) {
                _score = widget.bookModel.solvedUsersAndScore[i].scoreOfBook;
                _pageNum = widget.bookModel.solvedUsersAndScore[i].solvingPage;
                _solvingStatus = SolvingStatus.done;
              } else if (widget.bookModel.solvedUsersAndScore[i].solvingStatus == SolvingStatus.solving.code) {
                _pageNum = widget.bookModel.solvedUsersAndScore[i].solvingPage;
                _score = widget.bookModel.solvedUsersAndScore[i].scoreOfBook;
                _solvingStatus = SolvingStatus.solving;
              }
            }
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(common_l_gap, 0, common_l_gap, common_l_gap),
            child: GestureDetector(
              onTap: () {
                if (widget.bookModel.modeOfBook != MODE_NORMAL) {
                  switch (_solvingStatus) {
                    case SolvingStatus.done:
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          content: Text('이미 점수가 기록되어 다시 풀더라도 최초에 기록된 점수는 갱신되지 않습니다. 그래도 다시 풀어보시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                Get.toNamed('/bookDetail/${widget.bookModel.bookKey}', arguments: [widget.bookModel, _pageNum, _score, _solvingStatus.code]);
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

                      break;
                    case SolvingStatus.solving:
                      Get.toNamed('/bookDetail/${widget.bookModel.bookKey}', arguments: [widget.bookModel, _pageNum, _score, _solvingStatus.code]);
                      break;
                    default:
                      Get.toNamed('/bookDetail/${widget.bookModel.bookKey}', arguments: [widget.bookModel, _pageNum, _score, _solvingStatus.code]);
                  }
                } else {
                  Get.toNamed('/bookDetail/${widget.bookModel.bookKey}', arguments: [widget.bookModel, _pageNum, _score, _solvingStatus.code]);
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
                          BookService().deleteBook(widget.bookModels, widget.bookModel, widget.postIndex, userKey);
                          setState(() {});
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
              child: Consumer<UserModel?>(
                builder: (BuildContext context, UserModel? userModel, Widget? child) {
                  if (userModel != null) {
                    // 문제 상태 체크
                    if (_solvingStatus == SolvingStatus.notYet)
                    // 처음 푸는 문제면
                    {
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
                          ),
                          // height: 400,
                          // color: Color(0xFF56637a),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.bookModel.imageDownloadUrls.isNotEmpty
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
                                        '${widget.bookModel.imageDownloadUrls[0]}',
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
                              // 문제 제목 및 개수
                              Padding(
                                padding: const EdgeInsets.fromLTRB(common_l_gap, common_l_gap, common_l_gap, 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${widget.bookModel.bookTitle}',
                                        style: TextStyle(
                                          fontFamily: 'SDneoB',
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 7, vertical: 2),
                                    //     child: Text(
                                    //       '${widget.bookModel.bookItems.length}문제',
                                    //       style: TextStyle(
                                    //         fontFamily: 'SDneoM',
                                    //         color: Colors.black45,
                                    //         fontSize: 14,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Text(
                                      '|    ',
                                      style: TextStyle(
                                        fontFamily: 'SDneoH',
                                        color: Colors.black12,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${widget.bookModel.bookItems.length}문제',
                                      style: TextStyle(
                                        fontFamily: 'SDneoM',
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 문제 설명
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                child: Container(
                                  height: 94,
                                  child: Text(
                                    '${widget.bookModel.bookDesc}',
                                    style: TextStyle(
                                      fontFamily: 'SDneoR',
                                      color: Colors.black54,
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
                                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${TimeCalculation.getTimeDiff(widget.bookModel.createDate)}',
                                      // '${TimeCalculation.getToday(widget.bookModel.createDate)}',
                                      // '${widget.bookModel.createDate}',
                                      style: TextStyle(
                                        fontFamily: 'SDneoR',
                                        color: Colors.black38,
                                        fontSize: 13,
                                        height: 1.5,
                                        letterSpacing: -0.5,
                                        wordSpacing: 3,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CommentsScreen(
                                          // bookModel: widget.bookModel,
                                          bookKey: widget.bookModel.bookKey,
                                        ));
                                      },
                                      child: Text(
                                        (comments.length != 0) ? '${comments.length + numOfCommentReplies}개의 댓글' : '댓글쓰기',
                                        style: TextStyle(
                                          fontFamily: 'SDneoR',
                                          color: Colors.black38,
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
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                  shape: BoxShape.rectangle,
                                ),
                                height: 54,
                                child: Consumer<UserModelState>(builder: (BuildContext context, UserModelState userModelState, Widget? child) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                    child: Row(
                                      // 문제집 작성자 표시 부분
                                      children: [
                                        RoundedAvatar(
                                          avatarSize: 28,
                                          userModel: userModel,
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${userModel.username}',
                                            style: TextStyle(fontFamily: 'SDneoSB', fontSize: 15),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.all(common_xxs_gap),
                                          iconSize: 20,
                                          constraints: BoxConstraints(),
                                          onPressed: () {
                                            userNetworkRepository.toggleLikeToUserDataOfBook(userModelState.userModel!.userKey, widget.bookModel.bookKey);
                                            BookService().toggleLikeToBookData(userModelState.userModel!.userKey, widget.bookModel.bookKey);
                                          },
                                          icon: !(userModelState.userModel!.likedBooks.contains(widget.bookModel.bookKey))
                                              //          ||
                                              // !_heartToggle!
                                              ? Icon(
                                                  CupertinoIcons.suit_heart,
                                                )
                                              : Icon(
                                                  CupertinoIcons.suit_heart_fill,
                                                  color: Colors.red,
                                                ),
                                        ),
                                        Consumer<List<dynamic>>(
                                          builder: (BuildContext context, List<dynamic> likedBookKeys, Widget? child) {
                                            var _likedCount = [];
                                            for (int i = 0; i < likedBookKeys.length; i++) {
                                              if (likedBookKeys[i] == widget.bookModel.bookKey) {
                                                _likedCount.add(likedBookKeys[i]);
                                              }
                                            }
                                            return Container(
                                              child: Text(
                                                '${_likedCount.length}',
                                                style: TextStyle(fontFamily: 'SDneoB'),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (_solvingStatus == SolvingStatus.done)
                    // 풀이완료한 문제면
                    {
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
                          ),
                          // height: 400,
                          // color: Color(0xFF56637a),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.bookModel.imageDownloadUrls.isNotEmpty
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
                                        '${widget.bookModel.imageDownloadUrls[0]}',
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
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                                child: Container(
                                  width: double.infinity,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      // color: Color(0xFF3C90F3),
                                      borderRadius: BorderRadius.circular(5),
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.grey[200]!,
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Row(
                                      children: [
                                        ExtendedImage.asset(
                                          'assets/imgs/checked-2.png',
                                          width: 16,
                                        ),
                                        Text(
                                          ' ${SolvingStatus.done.displayName}',
                                          style: TextStyle(color: Colors.black87),
                                        ),
                                        widget.bookModel.modeOfBook == 'test' ? Text(' : ${_score}점') : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 문제 제목 및 개수
                              Padding(
                                padding: const EdgeInsets.fromLTRB(common_l_gap, common_l_gap, common_l_gap, 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${widget.bookModel.bookTitle}',
                                        style: TextStyle(
                                          fontFamily: 'SDneoB',
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 7, vertical: 2),
                                    //     child: Text(
                                    //       '${widget.bookModel.bookItems.length}문제',
                                    //       style: TextStyle(
                                    //         fontFamily: 'SDneoM',
                                    //         color: Colors.black45,
                                    //         fontSize: 14,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Text(
                                      '|    ',
                                      style: TextStyle(
                                        fontFamily: 'SDneoH',
                                        color: Colors.black12,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${widget.bookModel.bookItems.length}문제',
                                      style: TextStyle(
                                        fontFamily: 'SDneoM',
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 문제 설명
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                child: Container(
                                  height: 94,
                                  child: Text(
                                    '${widget.bookModel.bookDesc}',
                                    style: TextStyle(
                                      fontFamily: 'SDneoR',
                                      color: Colors.black54,
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
                                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${TimeCalculation.getTimeDiff(widget.bookModel.createDate)}',
                                      // '${TimeCalculation.getToday(widget.bookModel.createDate)}',
                                      // '${widget.bookModel.createDate}',
                                      style: TextStyle(
                                        fontFamily: 'SDneoR',
                                        color: Colors.black38,
                                        fontSize: 13,
                                        height: 1.5,
                                        letterSpacing: -0.5,
                                        wordSpacing: 3,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CommentsScreen(
                                          // bookModel: widget.bookModel,
                                          bookKey: widget.bookModel.bookKey,
                                        ));
                                      },
                                      child: Text(
                                        (comments.length != 0) ? '${comments.length + numOfCommentReplies}개의 댓글' : '댓글쓰기',
                                        style: TextStyle(
                                          fontFamily: 'SDneoR',
                                          color: Colors.black38,
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
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                  shape: BoxShape.rectangle,
                                ),
                                height: 50,
                                child: Consumer<UserModelState>(builder: (BuildContext context, UserModelState userModelState, Widget? child) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                    child: Row(
                                      // 문제집 작성자 표시 부분
                                      children: [
                                        RoundedAvatar(
                                          avatarSize: 28,
                                          userModel: userModel,
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${userModel.username}',
                                            style: TextStyle(fontFamily: 'SDneoSB', fontSize: 15),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.all(common_xxs_gap),
                                          iconSize: 20,
                                          constraints: BoxConstraints(),
                                          onPressed: () {
                                            userNetworkRepository.toggleLikeToUserDataOfBook(userModelState.userModel!.userKey, widget.bookModel.bookKey);
                                            BookService().toggleLikeToBookData(userModelState.userModel!.userKey, widget.bookModel.bookKey);
                                          },
                                          icon: !(userModelState.userModel!.likedBooks.contains(widget.bookModel.bookKey))
                                              //          ||
                                              // !_heartToggle!
                                              ? Icon(
                                                  CupertinoIcons.suit_heart,
                                                )
                                              : Icon(
                                                  CupertinoIcons.suit_heart_fill,
                                                  color: Colors.red,
                                                ),
                                        ),
                                        Consumer<List<dynamic>>(
                                          builder: (BuildContext context, List<dynamic> likedBookKeys, Widget? child) {
                                            var _likedCount = [];
                                            for (int i = 0; i < likedBookKeys.length; i++) {
                                              if (likedBookKeys[i] == widget.bookModel.bookKey) {
                                                _likedCount.add(likedBookKeys[i]);
                                              }
                                            }
                                            return Container(
                                              child: Text(
                                                '${_likedCount.length}',
                                                style: TextStyle(fontFamily: 'SDneoB'),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else
                    // 풀이중인 문제면
                    {
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
                          ),
                          // height: 400,
                          // color: Color(0xFF56637a),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.bookModel.imageDownloadUrls.isNotEmpty
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
                                        '${widget.bookModel.imageDownloadUrls[0]}',
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
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                                child: Container(
                                  width: double.infinity,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    // color: Colors.grey[200],
                                    color: Color(0xFFf4f7fe),
                                    borderRadius: BorderRadius.circular(5),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                      width: 1.0,
                                      color: Color(0xff1a68ff),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Row(
                                      children: [
                                        // ExtendedImage.asset(
                                        //   'assets/imgs/checked-2.png',
                                        //   width: 16,
                                        // ),
                                        Text(
                                          ' ${_pageNum + 1}번 문제 ${SolvingStatus.solving.displayName}',
                                          style: TextStyle(color: Color(0xff1a68ff)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // 문제 제목 및 개수
                              Padding(
                                padding: const EdgeInsets.fromLTRB(common_l_gap, common_l_gap, common_l_gap, 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${widget.bookModel.bookTitle}',
                                        style: TextStyle(
                                          fontFamily: 'SDneoB',
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 7, vertical: 2),
                                    //     child: Text(
                                    //       '${widget.bookModel.bookItems.length}문제',
                                    //       style: TextStyle(
                                    //         fontFamily: 'SDneoM',
                                    //         color: Colors.black45,
                                    //         fontSize: 14,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    Text(
                                      '|    ',
                                      style: TextStyle(
                                        fontFamily: 'SDneoH',
                                        color: Colors.black12,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${widget.bookModel.bookItems.length}문제',
                                      style: TextStyle(
                                        fontFamily: 'SDneoM',
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 문제 설명
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                child: Container(
                                  height: 94,
                                  child: Text(
                                    '${widget.bookModel.bookDesc}',
                                    style: TextStyle(
                                      fontFamily: 'SDneoR',
                                      color: Colors.black54,
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
                                padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${TimeCalculation.getTimeDiff(widget.bookModel.createDate)}',
                                      // '${TimeCalculation.getToday(widget.bookModel.createDate)}',
                                      // '${widget.bookModel.createDate}',
                                      style: TextStyle(
                                        fontFamily: 'SDneoR',
                                        color: Colors.black38,
                                        fontSize: 13,
                                        height: 1.5,
                                        letterSpacing: -0.5,
                                        wordSpacing: 3,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(CommentsScreen(
                                          // bookModel: widget.bookModel,
                                          bookKey: widget.bookModel.bookKey,
                                        ));
                                      },
                                      child: Text(
                                        (comments.length != 0) ? '${comments.length + numOfCommentReplies}개의 댓글' : '댓글쓰기',
                                        style: TextStyle(
                                          fontFamily: 'SDneoR',
                                          color: Colors.black38,
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
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                  shape: BoxShape.rectangle,
                                ),
                                height: 50,
                                child: Consumer<UserModelState>(builder: (BuildContext context, UserModelState userModelState, Widget? child) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: common_l_gap),
                                    child: Row(
                                      // 문제집 작성자 표시 부분
                                      children: [
                                        RoundedAvatar(
                                          avatarSize: 28,
                                          userModel: userModel,
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${userModel.username}',
                                            style: TextStyle(fontFamily: 'SDneoSB', fontSize: 15),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.all(common_xxs_gap),
                                          iconSize: 20,
                                          constraints: BoxConstraints(),
                                          onPressed: () {
                                            userNetworkRepository.toggleLikeToUserDataOfBook(userModelState.userModel!.userKey, widget.bookModel.bookKey);
                                            BookService().toggleLikeToBookData(userModelState.userModel!.userKey, widget.bookModel.bookKey);
                                          },
                                          icon: !(userModelState.userModel!.likedBooks.contains(widget.bookModel.bookKey))
                                              //          ||
                                              // !_heartToggle!
                                              ? Icon(
                                                  CupertinoIcons.suit_heart,
                                                )
                                              : Icon(
                                                  CupertinoIcons.suit_heart_fill,
                                                  color: Colors.red,
                                                ),
                                        ),
                                        Consumer<List<dynamic>>(
                                          builder: (BuildContext context, List<dynamic> likedBookKeys, Widget? child) {
                                            var _likedCount = [];
                                            for (int i = 0; i < likedBookKeys.length; i++) {
                                              if (likedBookKeys[i] == widget.bookModel.bookKey) {
                                                _likedCount.add(likedBookKeys[i]);
                                              }
                                            }
                                            return Container(
                                              child: Text(
                                                '${_likedCount.length}',
                                                style: TextStyle(fontFamily: 'SDneoB'),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

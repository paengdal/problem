import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/comment_network_repository.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:quiz_first/view/home_page.dart';
import 'package:quiz_first/view/screens/comments_screen.dart';
import 'package:quiz_first/view/widgets/options.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';
import 'package:http/http.dart' as http;

class QuizPostDeep extends StatefulWidget {
  final List<ItemModel> itemModels;
  final ItemModel itemModel;
  final int postIndex;
  const QuizPostDeep(
      {Key? key,
      required this.itemModels,
      required this.itemModel,
      required this.postIndex})
      : super(key: key);

  @override
  State<QuizPostDeep> createState() => _QuizPostDeepState();
}

class _QuizPostDeepState extends State<QuizPostDeep> {
  final sizedBoxH = SizedBox(
    height: 10,
  );

  List<int> selectedOptions = [];

  void addSelectedOptions(option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
  }

  void _sendPushWithItemKey(itemKey) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAGWbrGMU:APA91bFCps7ojiWeqIjZG8VBXAlX3xBL5RA7Zemve00GpYHCq98d5N2Yniixuq-QRcLELF1Qb8D5pvOvUf-OolcMeLTAHx9wjjfZULIFNWXdncs5wfEsAQOd5cnAnHIM1YMl87MLV5Cx',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '3',
              'status': 'done',
              'argument': 'feed button push argument',
              'fore': 'foreground',
              'back': 'background2',
              'termi': 'terminated',
              'itemKey': itemKey
            },
            'notification': {
              'title': 'Hello FlutterFire!',
              'body': 'This notification was created via FCM!',
            },

            // 'to': "/topics/Test",
            // test@test.com -> LG 테스트 폰
            // 'to':
            //     'd3t60LmZTzuPBzPpPm5SA4:APA91bHmv-AGeFpzhAwbJ0d1IzO3ZhjlDo2_2cMJgfr-x6MONDTSzS9TMOhUrOVxs_pztAMnAZC1Fm9kPf5JJ12QUSuniWaMbzmk-GW4NXiItpIpt7yD_ly0hrKHXMaChJGcgTP6itDd',
            // paengdal@naver.com -> 아이폰
            // 'to':
            //     'c3M8tmsg7k4hvVWKrveiJG:APA91bE7YQD74RLAfGvY8UGjsmC-gRp6zLF0UiK6m9NW6lj1WDUqppRTbHg8YDvssmKxf2hkgvyNtv8zIunAGuyuatZxOjAqfdTDeODteas1iwRUs4wvU9egtf8Nisp01dqlnranEv1V',

            //모두에게
            'registration_ids': await userNetworkRepository
                .getUsersTokensExceptMe(FirebaseAuth.instance.currentUser!.uid),
          },
        ),
      );
    } catch (e) {
      print('error push');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<CommentModel>>.value(
      initialData: [],
      value: commentNetworkRepository
          .fetchAllCommentsOfBook(widget.itemModel.itemKey),
      child: Consumer<List<CommentModel>>(
        builder: (BuildContext context, comments, Widget? child) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                common_l_gap, 0, common_l_gap, common_l_gap),
            child: Card(
              elevation: 12,
              shadowColor: Colors.black87,
              // color: Color(0xFF56637a),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                ),
                // height: 300,
                // color: Color(0xFF56637a),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          common_l_gap, common_s_gap, 4, 0),
                      child: Row(
                        // 퀴즈 작성자 표시 부분
                        children: [
                          // RoundedAvatar(
                          //   avatarSize: 36,
                          // ),
                          SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: Text(
                              '${widget.itemModel.username}',
                              style: TextStyle(
                                  fontFamily: 'SDneoSB', fontSize: 16),
                            ),
                          ),
                          // 로그인한 사용자가 관리자이거나 해당 게시물 작성자와 일치할때만 메뉴 버튼 보여줌
                          (FirebaseAuth.instance.currentUser!.uid ==
                                      widget.itemModel.userKey ||
                                  FirebaseAuth.instance.currentUser!.uid ==
                                      '2gZkQDDA0rQlxVrnYXEUZ2DDTTj2')
                              ? PopupMenuButton(
                                  onSelected: (value) {
                                    if (value == 'Delete') {
                                      Get.dialog(
                                        barrierDismissible: false,
                                        AlertDialog(
                                          content: Text('문제를 삭제하시겠습니까?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                ItemService().deleteItem(
                                                    widget.itemModels,
                                                    widget.itemModel,
                                                    widget.postIndex,
                                                    context
                                                        .read<UserModelState>()
                                                        .userModel!
                                                        .userKey);

                                                setState(() {});
                                                Get.offAllNamed('/');
                                              },
                                              child: Text(
                                                '삭제',
                                                style: TextStyle(
                                                    color: Colors.red),
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
                                    } else if (value == 'Modify') {
                                      Get.dialog(
                                        barrierDismissible: false,
                                        AlertDialog(
                                          content: Text('준비중입니다. 조금만 기다려주세요!'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text('확인'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  offset: Offset(0, 56),
                                  icon: Icon(CupertinoIcons.ellipsis_vertical),
                                  itemBuilder: (context) {
                                    return <PopupMenuEntry<String>>[
                                      PopupMenuItem(
                                        value: 'Modify',
                                        child: Text('수정하기'),
                                      ),
                                      PopupMenuItem(
                                        value: 'Delete',
                                        child: Text('삭제하기'),
                                      ),
                                    ];
                                  },
                                )
                              : Container(),
                          // Text(
                          //   '${context.watch<UserModelState>().userModel!.createDate}',
                          // ),
                        ],
                      ),
                    ),
                    Padding(
                      // 카테고리, 수정/삭제 버튼
                      padding: const EdgeInsets.fromLTRB(
                          common_l_gap, 4, common_l_gap, 2),
                      child: Container(
                        height: 25,
                        child: Row(
                          children: [
                            Text(
                              '${categoriesMapEngToKor[widget.itemModel.category]}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      // 문제 표시
                      padding:
                          const EdgeInsets.symmetric(horizontal: common_l_gap),
                      child: GestureDetector(
                        onTap: () {
                          _sendPushWithItemKey(widget.itemModel.itemKey);
                        },
                        child: Text(
                          '${widget.itemModel.question}',
                          style: TextStyle(
                            fontFamily: 'SDneoSB',
                            color: Colors.black87,
                            fontSize: 19,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      // 이미지 표시
                      padding: const EdgeInsets.fromLTRB(
                          common_l_gap, common_xs_gap, common_l_gap, 0),
                      child: (widget.itemModel.imageDownloadUrls.isNotEmpty)
                          ? ExtendedImage.network(
                              '${widget.itemModel.imageDownloadUrls[0]}')
                          : Container(),
                    ),
                    Padding(
                      // 객관식 보기 표시
                      padding: const EdgeInsets.fromLTRB(
                          common_l_gap, common_xl_gap, common_l_gap, 8),
                      // child: Options(
                      //   itemModel: widget.itemModel,
                      //   sizedBoxH: sizedBoxH,
                      //   getSelectedOptions: addSelectedOptions,
                      // ),
                    ),
                    // 마지막 댓글 표시
                    (comments != null && comments.isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: common_l_gap),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      // Get.to(() => CommentsScreen(
                                      //     widget.itemModel,
                                      //     widget.itemModel.itemKey));
                                    },
                                    child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${comments.first.username}',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontFamily: 'SDneoB',
                                                fontSize: 15),
                                          ),
                                          TextSpan(
                                            text: ' ${comments.first.comment}',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 3,
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: common_l_gap),
                      child: InkWell(
                        onTap: () {
                          // Get.to(() => CommentsScreen(
                          //     widget.itemModel, widget.itemModel.itemKey));
                        },
                        // child: Text(
                        //   (itemModel.numOfComments != 0)
                        //       ? '${itemModel.numOfComments}개의 댓글'
                        //       : '댓글쓰기',
                        // ),
                        child: Text(
                          (comments.length != 0)
                              ? '${comments.length}개의 댓글'
                              : '댓글쓰기',
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 13,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey[400],
                    ),

                    // 좋아요, 댓글, 정답 확인
                    Container(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Consumer<UserModelState>(
                            builder: (BuildContext context,
                                UserModelState userModelState, Widget? child) {
                              return IconButton(
                                padding: EdgeInsets.all(common_xxs_gap),
                                iconSize: 20,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  userNetworkRepository
                                      .toggleLikeToUserDataOfItem(
                                          userModelState.userModel!.userKey,
                                          widget.itemModel.itemKey);
                                  ItemService().toggleLikeToItemData(
                                      userModelState.userModel!.userKey,
                                      widget.itemModel.itemKey);
                                },
                                icon: !(userModelState.userModel!.likedItems
                                        .contains(widget.itemModel.itemKey))
                                    //          ||
                                    // !_heartToggle!
                                    ? Icon(
                                        CupertinoIcons.suit_heart,
                                      )
                                    : Icon(
                                        CupertinoIcons.suit_heart_fill,
                                        color: Colors.red,
                                      ),
                              );
                            },
                          ),
                          Expanded(
                            child: Consumer<List<dynamic>>(
                              builder: (BuildContext context,
                                  List<dynamic> likedItemKeys, Widget? child) {
                                var _likedCount = [];
                                for (int i = 0; i < likedItemKeys.length; i++) {
                                  if (likedItemKeys[i] ==
                                      widget.itemModel.itemKey) {
                                    _likedCount.add(likedItemKeys[i]);
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
                          ),
                          // IconButton(
                          //   onPressed: () {
                          //     Get.to(() =>
                          //         CommentsScreen(_itemModels[index].itemKey));
                          //   },
                          //   icon: Icon(
                          //     CupertinoIcons.chat_bubble,
                          //     // color: Colors.red,
                          //   ),
                          // ),
                          InkWell(
                            onTap: () {
                              // changeIsPressed();
                              // Get.to(
                              //     () => QuizDetailScreen(
                              //           itemModel:
                              //               widget.itemModels[index],
                              //         ),
                              //     fullscreenDialog: false);
                              // logger.d('selectedOptions:$selectedOptions');
                              if (selectedOptions != null &&
                                  selectedOptions.isNotEmpty) {
                                if ((selectedOptions[0] + 1).toString() ==
                                    widget.itemModel.answer) {
                                  // setState(() {
                                  //   isCorrect = !isCorrect;
                                  // });
                                  Get.dialog(
                                    barrierDismissible: false,
                                    AlertDialog(
                                      content: Text('정답입니다.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            ItemService().answerIsCorrect(
                                                widget.itemModels,
                                                widget.itemModel,
                                                FirebaseAuth
                                                    .instance.currentUser!.uid);
                                            Get.back();
                                            Get.offAllNamed('/');
                                          },
                                          child: Text('확인'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  Get.dialog(
                                    barrierDismissible: false,
                                    AlertDialog(
                                      content: Text('오답입니다.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text('확인'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } else {
                                Get.dialog(
                                  barrierDismissible: false,
                                  AlertDialog(
                                    content: Text('정답을 입력해주세요.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '정답 입력 및 확인',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () {
                                    Get.toNamed(
                                        '/detail/${widget.itemModel.itemKey}');
                                  },
                                  icon: Icon(
                                      CupertinoIcons.arrow_right_circle_fill,
                                      color: Colors.black54),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

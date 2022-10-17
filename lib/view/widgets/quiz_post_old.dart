// import 'package:extended_image/extended_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:quiz_first/constants/common_size.dart';
// import 'package:quiz_first/controller/category_notifier.dart';
// import 'package:quiz_first/controller/user_model_state.dart';
// import 'package:quiz_first/model/comment_model.dart';
// import 'package:quiz_first/model/item_model.dart';
// import 'package:quiz_first/repo/comment_network_repository.dart';
// import 'package:quiz_first/repo/item_service.dart';
// import 'package:quiz_first/repo/user_network_repository.dart';
// import 'package:quiz_first/view/screens/feed/quiz_detail_screen.dart';
// import 'package:quiz_first/view/widgets/rounded_avatar.dart';

// import '../screens/comments_screen.dart';

// class QuizPost extends StatefulWidget {
//   final List<ItemModel> itemModels;
//   QuizPost({Key? key, required this.itemModels}) : super(key: key);

//   @override
//   State<QuizPost> createState() => _QuizPostState();
// }

// class _QuizPostState extends State<QuizPost> {
//   final sizedBoxH = SizedBox(
//     height: 10,
//   );
//   bool isPressed = false;

//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<List<CommentModel>>.value(
//       initialData: [],
//       value:
//           commentNetworkRepository.fetchAllComments(_itemModels[index].itemKey),
//       child: Consumer<List<CommentModel>>(
//         builder: (BuildContext context, comments, Widget? child) {
//           return Padding(
//             padding: const EdgeInsets.fromLTRB(
//                 common_l_gap, 0, common_l_gap, common_l_gap),
//             child: Card(
//               elevation: 12,
//               shadowColor: Colors.black87,
//               // color: Color(0xFF56637a),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   shape: BoxShape.rectangle,
//                 ),
//                 // height: 300,
//                 // color: Color(0xFF56637a),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(
//                           common_l_gap, common_s_gap, 4, 0),
//                       child: Row(
//                         // 퀴즈 작성자 표시 부분
//                         children: [
//                           RoundedAvatar(
//                             avatarSize: 36,
//                           ),
//                           SizedBox(
//                             width: 6,
//                           ),
//                           Expanded(
//                             child: Text(
//                               '${itemModel.username}',
//                               style: TextStyle(
//                                   fontFamily: 'SDneoSB', fontSize: 16),
//                             ),
//                           ),
//                           // 로그인한 사용자가 관리자이거나 해당 게시물 작성자와 일치할때만 메뉴 버튼 보여줌
//                           (FirebaseAuth.instance.currentUser!.uid ==
//                                       itemModel.userKey ||
//                                   FirebaseAuth.instance.currentUser!.uid ==
//                                       '2gZkQDDA0rQlxVrnYXEUZ2DDTTj2')
//                               ? PopupMenuButton(
//                                   onSelected: (value) {
//                                     if (value == 'Delete') {
//                                       Get.defaultDialog(
//                                         title: '퀴즈 삭제 경고',
//                                         middleText: '퀴즈를 삭제하시겠습니까?',
//                                         textConfirm: '확인',
//                                         textCancel: '취소',
//                                         onConfirm: () {
//                                           ItemService().deleteItem(
//                                               _itemModels,
//                                               index,
//                                               context
//                                                   .read<UserModelState>()
//                                                   .userModel!
//                                                   .userKey);
//                                           setState(() {});
//                                           Get.back();
//                                         },
//                                       );
//                                     } else if (value == 'Modify') {
//                                       Get.defaultDialog(
//                                         middleText: '준비중입니다. 조금만 기다려주세요!',
//                                         title: '기능 구현중',
//                                         textConfirm: '확인',
//                                         onConfirm: () {
//                                           Get.back();
//                                         },
//                                       );
//                                     }
//                                   },
//                                   offset: Offset(0, 56),
//                                   icon: Icon(CupertinoIcons.ellipsis_vertical),
//                                   itemBuilder: (context) {
//                                     return <PopupMenuEntry<String>>[
//                                       PopupMenuItem(
//                                         value: 'Modify',
//                                         child: Text('수정하기'),
//                                       ),
//                                       PopupMenuItem(
//                                         value: 'Delete',
//                                         child: Text('삭제하기'),
//                                       ),
//                                     ];
//                                   },
//                                 )
//                               : Container(),
//                           // Text(
//                           //   '${context.watch<UserModelState>().userModel!.createDate}',
//                           // ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       // 카테고리, 수정/삭제 버튼
//                       padding: const EdgeInsets.fromLTRB(
//                           common_l_gap, 4, common_l_gap, 2),
//                       child: Container(
//                         height: 25,
//                         child: Row(
//                           children: [
//                             Text(
//                               '${categoriesMapEngToKor[itemModel.category]}',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Expanded(
//                               child: Container(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       // 문제 표시
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: common_l_gap),
//                       child: Text(
//                         '${itemModel.question}',
//                         style: TextStyle(
//                           fontFamily: 'SDneoSB',
//                           color: Colors.black87,
//                           fontSize: 19,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       // 이미지 표시
//                       padding: const EdgeInsets.fromLTRB(
//                           common_l_gap, common_xs_gap, common_l_gap, 0),
//                       child: (itemModel.imageDownloadUrls.isNotEmpty)
//                           ? ExtendedImage.network(
//                               '${itemModel.imageDownloadUrls[0]}')
//                           : Container(),
//                     ),
//                     Padding(
//                       // 객관식 보기 표시
//                       padding: const EdgeInsets.fromLTRB(
//                           common_l_gap, common_xl_gap, common_l_gap, 8),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemCount: itemModel.examples.length,
//                         itemBuilder: (context, index) {
//                           // bool isCorrect = false;

//                           if (itemModel.examples[index] != '') {
//                             return Column(
//                               children: [
//                                 Stack(
//                                   children: [
//                                     InkWell(
//                                       // onTap: () {
//                                       //   if ((index + 1).toString() ==
//                                       //       itemModel.answer) {
//                                       //     // setState(() {
//                                       //     //   isCorrect = !isCorrect;
//                                       //     // });
//                                       //     Get.defaultDialog(
//                                       //       title: '정답',
//                                       //       middleText: '정답입니다',
//                                       //       textConfirm: '확인',
//                                       //       // textCancel: '취소',
//                                       //       onConfirm: () {
//                                       //         ItemService()
//                                       //             .answerIsCorrect(
//                                       //                 _itemModels,
//                                       //                 itemModel,
//                                       //                 FirebaseAuth
//                                       //                     .instance
//                                       //                     .currentUser!
//                                       //                     .uid);
//                                       //         Get.back();
//                                       //         Get.offAll(HomePage(
//                                       //             userKey: FirebaseAuth
//                                       //                 .instance
//                                       //                 .currentUser!
//                                       //                 .uid));
//                                       //       },
//                                       //     );
//                                       //   } else {
//                                       //     Get.defaultDialog(
//                                       //       title: '오답',
//                                       //       middleText: '오답입니다',
//                                       //       textConfirm: '확인',
//                                       //       // textCancel: '취소',
//                                       //       onConfirm: () {
//                                       //         Get.back();
//                                       //       },
//                                       //     );
//                                       //   }
//                                       // },
//                                       onTap: () {
//                                         setState(() {
//                                           isPressed = !isPressed;
//                                         });
//                                       },
//                                       child: Container(
//                                         alignment: Alignment.centerLeft,
//                                         // padding: EdgeInsets.all(10),
//                                         width: double.infinity,
//                                         height: 50,
//                                         decoration: BoxDecoration(
//                                           color: isPressed
//                                               ? ((index == 0)
//                                                   ? Colors.red
//                                                   : Colors.blue)
//                                               : Colors.grey[100],
//                                           borderRadius:
//                                               BorderRadius.circular(25),
//                                           shape: BoxShape.rectangle,
//                                         ),
//                                         child: Padding(
//                                           padding:
//                                               const EdgeInsets.only(left: 50),
//                                           child: Text(
//                                             '${itemModel.examples[index]}',
//                                             style: TextStyle(
//                                               color: Colors.black87,
//                                               fontFamily: 'SDneoR',
//                                               fontSize: 17,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 13,
//                                       left: 13,
//                                       child: Container(
//                                         width: 24,
//                                         height: 24,
//                                         decoration: BoxDecoration(
//                                           color: Colors.black45,
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           shape: BoxShape.rectangle,
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             '${index + 1}',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontFamily: 'SDneoEB',
//                                               fontSize: 17,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 sizedBoxH,
//                               ],
//                             );
//                           } else {
//                             return Container();
//                           }
//                         },
//                       ),
//                     ),
//                     // 마지막 댓글 표시
//                     (comments != null && comments.isNotEmpty)
//                         ? Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: common_l_gap),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: InkWell(
//                                     onTap: () {
//                                       Get.to(() => CommentsScreen(
//                                           _itemModels[index],
//                                           _itemModels[index].itemKey));
//                                     },
//                                     child: RichText(
//                                       overflow: TextOverflow.ellipsis,
//                                       maxLines: 1,
//                                       text: TextSpan(
//                                         children: [
//                                           TextSpan(
//                                             text: '${comments.first.username}',
//                                             style: TextStyle(
//                                                 color: Colors.black87,
//                                                 fontFamily: 'SDneoB',
//                                                 fontSize: 15),
//                                           ),
//                                           TextSpan(
//                                             text: ' ${comments.first.comment}',
//                                             style: TextStyle(
//                                                 color: Colors.black87,
//                                                 fontSize: 15),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Container(),
//                     SizedBox(
//                       height: 3,
//                     ),

//                     Padding(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: common_l_gap),
//                       child: InkWell(
//                         onTap: () {
//                           Get.to(() => CommentsScreen(
//                               _itemModels[index], _itemModels[index].itemKey));
//                         },
//                         // child: Text(
//                         //   (itemModel.numOfComments != 0)
//                         //       ? '${itemModel.numOfComments}개의 댓글'
//                         //       : '댓글쓰기',
//                         // ),
//                         child: Text(
//                           (comments.length != 0)
//                               ? '${comments.length}개의 댓글'
//                               : '댓글쓰기',
//                         ),
//                       ),
//                     ),

//                     SizedBox(
//                       height: 13,
//                     ),
//                     Divider(
//                       height: 1,
//                       color: Colors.grey[400],
//                     ),

//                     // 좋아요, 댓글, 정답 확인
//                     Container(
//                       height: 56,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: 10,
//                           ),
//                           Consumer<UserModelState>(
//                             builder: (BuildContext context,
//                                 UserModelState userModelState, Widget? child) {
//                               return IconButton(
//                                 padding: EdgeInsets.all(common_xxs_gap),
//                                 iconSize: 20,
//                                 constraints: BoxConstraints(),
//                                 onPressed: () {
//                                   userNetworkRepository.toggleLikeToUserData(
//                                       userModelState.userModel!.userKey,
//                                       _itemModels[index].itemKey);
//                                   ItemService().toggleLikeToItemData(
//                                       userModelState.userModel!.userKey,
//                                       _itemModels[index].itemKey);
//                                 },
//                                 icon: !(userModelState.userModel!.likedItems
//                                         .contains(_itemModels[index].itemKey))
//                                     //          ||
//                                     // !_heartToggle!
//                                     ? Icon(
//                                         CupertinoIcons.suit_heart,
//                                       )
//                                     : Icon(
//                                         CupertinoIcons.suit_heart_fill,
//                                         color: Colors.red,
//                                       ),
//                               );
//                             },
//                           ),
//                           Expanded(
//                             child: Consumer<List<dynamic>>(
//                               builder: (BuildContext context,
//                                   List<dynamic> likedItemKeys, Widget? child) {
//                                 var _likedCount = [];
//                                 for (int i = 0; i < likedItemKeys.length; i++) {
//                                   if (likedItemKeys[i] ==
//                                       _itemModels[index].itemKey) {
//                                     _likedCount.add(likedItemKeys[i]);
//                                   }
//                                 }
//                                 return Container(
//                                   child: Text(
//                                     '${_likedCount.length}',
//                                     style: TextStyle(fontFamily: 'SDneoB'),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           // IconButton(
//                           //   onPressed: () {
//                           //     Get.to(() =>
//                           //         CommentsScreen(_itemModels[index].itemKey));
//                           //   },
//                           //   icon: Icon(
//                           //     CupertinoIcons.chat_bubble,
//                           //     // color: Colors.red,
//                           //   ),
//                           // ),
//                           InkWell(
//                             onTap: () {
//                               Get.to(
//                                   () => QuizDetailScreen(
//                                         itemModel: _itemModels[index],
//                                       ),
//                                   fullscreenDialog: false);
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   '정답 입력 및 확인',
//                                   style: TextStyle(color: Colors.black54),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Icon(CupertinoIcons.arrow_right_circle_fill,
//                                     color: Colors.black54),
//                                 SizedBox(
//                                   width: 16,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:algolia/algolia.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/main.dart';
import 'package:quiz_first/model/book_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/repo/algolia_service.dart';
import 'package:quiz_first/repo/book_service.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/view/screens/input_book_screen.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_first/view/widgets/book_post.dart';
import 'package:quiz_first/view/widgets/notice_post.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';

class FeedBookScreen extends StatefulWidget {
  const FeedBookScreen({Key? key}) : super(key: key);

  @override
  State<FeedBookScreen> createState() => _FeedBookScreenState();
}

class _FeedBookScreenState extends State<FeedBookScreen> {
  List<BookModel> _bookModels = [];
  List<BookModel> _bookModelsOfAdmin = [];

  bool _init = false;
  bool _isLoading = false;

  @override
  void initState() {
    if (!_init) {
      _onRefresh();
      _init = true;
    }
    _getAndAddToken();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Get.to(() => InputScreen(), fullscreenDialog: true);
      //   },
      //   child: Icon(Icons.add),
      // ),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: !_isLoading
              ? StreamProvider<List<dynamic>>.value(
                  initialData: [],
                  value: userNetworkRepository.getAllUsersLikedBookKeysStream(),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 80,
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: common_xl_gap),
                              child: Container(
                                width: 180,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: common_s_gap),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   '퀴즈: ${userModel.userModel!.solvedItems.length}개, ',
                                      // ),
                                      Container(
                                        child: ExtendedImage.asset('assets/imgs/point.png'),
                                        height: 20,
                                        width: 20,
                                      ),
                                      context.watch<UserModelState>().userModel != null
                                          // ? Text(
                                          //     ' 획득 점수 ${context.read<UserModelState>().userModel!.solvedItems.length * 10}',
                                          //     style: TextStyle(color: Colors.grey),
                                          //   )
                                          ? RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: ' 포인트 ',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: context.watch<UserModelState>().userModel != null
                                                        ? context.watch<UserModelState>().userModel!.solvedItems.isNotEmpty
                                                            ? ' ${context.watch<UserModelState>().userModel!.solvedItems.length * 10}'
                                                            : '0'
                                                        : '0',
                                                    style: TextStyle(color: Colors.black87, fontSize: 15, fontFamily: 'SDneoB'),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : CircularProgressIndicator(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            context.watch<UserModelState>().userModel != null
                                ? context.watch<UserModelState>().userModel!.userKey == 'xH5n1PRQUUVHboGxjZP4Z14pycP2'
                                    ? IconButton(
                                        onPressed: () {
                                          Get.dialog(
                                            barrierDismissible: false,
                                            AlertDialog(
                                              content: Text('json파일로 아이템을 생성하시겠습니까?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    ItemService().createNewItemsByJsonFile();

                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    '생성하기',
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
                                        icon: Icon(
                                          CupertinoIcons.plus_app,
                                          color: Colors.black87,
                                        ),
                                      )
                                    : Container()
                                : Container(),
                            IconButton(
                              onPressed: () {
                                // _sendPushMessage();
                              },
                              icon: Icon(
                                CupertinoIcons.ellipsis_circle,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.toNamed('/notification');
                              },
                              icon: Icon(
                                CupertinoIcons.bell,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ),
                      NoticePost(bookModels: _bookModelsOfAdmin),
                      BookPost(bookModels: _bookModels),
                      // QuizPost(),
                      // StreamProvider<List<dynamic>>.value(
                      //   initialData: [],
                      //   value: userNetworkRepository.getAllUsersItemKeysStream(),
                      //   child: QuizPost(
                      //     itemModels: _itemModels,
                      //   ),
                      // ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
        ),
      ),
    );
  }

  Future _onRefresh() async {
    _isLoading = true;
    setState(() {});
    _bookModels.clear();
    _bookModelsOfAdmin.clear();
    // _itemModels.addAll(await ItemService().getItems());
    // _itemModels.addAll(await ItemService().getItemsExceptMine(widget.userKey));
    _bookModels.addAll(await BookService().getAllBooksExceptByAdmin());
    _bookModelsOfAdmin.addAll(await BookService().getAdminBooks());
    _bookModels.sort(
      (a, b) => a.createDate.compareTo(b.createDate),
    );
    _bookModelsOfAdmin.sort(
      (a, b) => a.createDate.compareTo(b.createDate),
    );
    // var _temp = _bookModels
    //   ..sort(  // sort앞에 ..(cascade notation)을 찍으면 변수에 결과값을 담을 수 있다.
    //     (a, b) => a.username.compareTo(b.username),
    //   );
    // _temp.sort(
    //   (a, b) => a.bookItems.length.compareTo(b.bookItems.length),
    // );
    // _bookModels = _temp;
    _isLoading = false;
    setState(() {});
  }

  Future _getAndAddToken() async {
    // var token = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.getToken().then((token) {
      if (token != null && FirebaseAuth.instance.currentUser != null) userNetworkRepository.addToken(userKey: FirebaseAuth.instance.currentUser!.uid, token: token);
    });
  }

  void _sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAGWbrGMU:APA91bFCps7ojiWeqIjZG8VBXAlX3xBL5RA7Zemve00GpYHCq98d5N2Yniixuq-QRcLELF1Qb8D5pvOvUf-OolcMeLTAHx9wjjfZULIFNWXdncs5wfEsAQOd5cnAnHIM1YMl87MLV5Cx',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'argument': 'feed button push argument',
              'fore': 'foreground',
              'back': 'background',
              'termi': 'terminated'
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
            'to': 'c3M8tmsg7k4hvVWKrveiJG:APA91bE7YQD74RLAfGvY8UGjsmC-gRp6zLF0UiK6m9NW6lj1WDUqppRTbHg8YDvssmKxf2hkgvyNtv8zIunAGuyuatZxOjAqfdTDeODteas1iwRUs4wvU9egtf8Nisp01dqlnranEv1V',

            //모두에게
            // 'registration_ids': await userNetworkRepository
            //     .getUsersTokens(FirebaseAuth.instance.currentUser!.uid),
          },
        ),
      );
    } catch (e) {
      print('error push');
    }
  }

  void _sendPushMessage2() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=AAAAGWbrGMU:APA91bFCps7ojiWeqIjZG8VBXAlX3xBL5RA7Zemve00GpYHCq98d5N2Yniixuq-QRcLELF1Qb8D5pvOvUf-OolcMeLTAHx9wjjfZULIFNWXdncs5wfEsAQOd5cnAnHIM1YMl87MLV5Cx',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '2',
              'status': 'done',
              'argument': 'feed button push argument',
              'fore': 'foreground',
              'back': 'background2',
              'termi': 'terminated',
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
            'to': 'c3M8tmsg7k4hvVWKrveiJG:APA91bE7YQD74RLAfGvY8UGjsmC-gRp6zLF0UiK6m9NW6lj1WDUqppRTbHg8YDvssmKxf2hkgvyNtv8zIunAGuyuatZxOjAqfdTDeODteas1iwRUs4wvU9egtf8Nisp01dqlnranEv1V',

            //모두에게
            // 'registration_ids': await userNetworkRepository
            //     .getUsersTokens(FirebaseAuth.instance.currentUser!.uid),
          },
        ),
      );
    } catch (e) {
      print('error push');
    }
  }
}

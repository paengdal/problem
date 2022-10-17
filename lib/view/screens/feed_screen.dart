import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quiz_first/constants/common_size.dart';
import 'package:quiz_first/constants/firestore_keys.dart';
import 'package:quiz_first/controller/category_notifier.dart';
import 'package:quiz_first/controller/user_model_state.dart';
import 'package:quiz_first/model/comment_model.dart';
import 'package:quiz_first/model/item_model.dart';
import 'package:quiz_first/model/user_model.dart';
import 'package:quiz_first/repo/comment_network_repository.dart';
import 'package:quiz_first/repo/image_storage.dart';
import 'package:quiz_first/repo/item_service.dart';
import 'package:quiz_first/repo/user_network_repository.dart';
import 'package:quiz_first/util/logger.dart';
import 'package:quiz_first/view/home_page.dart';
import 'package:quiz_first/view/screens/comments_screen.dart';
import 'package:quiz_first/view/screens/feed/quiz_detail_screen.dart';
import 'package:quiz_first/view/screens/input_book_screen.dart';
import 'package:quiz_first/view/screens/input_screen.dart';
import 'package:quiz_first/view/widgets/quiz_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_first/view/widgets/quiz_post.dart';
import 'package:quiz_first/view/widgets/rounded_avatar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class FeedScreen extends StatefulWidget {
  final String userKey;
  FeedScreen({Key? key, required this.userKey}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final sizedBoxH = SizedBox(
    height: 10,
  );
  List<ItemModel> _itemModels = [];

  bool _init = false;

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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Get.to(() => InputScreen(), fullscreenDialog: true);
      //   },
      //   child: Icon(Icons.add),
      // ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
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
                                child: ExtendedImage.asset(
                                    'assets/imgs/point.png'),
                                height: 20,
                                width: 20,
                              ),
                              context.read<UserModelState>().userModel != null
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
                                            text:
                                                ' ${context.read<UserModelState>().userModel!.solvedItems.length * 10}',
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontFamily: 'SDneoB'),
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
                    IconButton(
                      onPressed: () {
                        Get.to(() => InputBookScreen(), fullscreenDialog: true);
                        // _sendPushMessage2();
                      },
                      icon: Icon(
                        CupertinoIcons.plus_app,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _sendPushMessage();
                      },
                      icon: Icon(
                        CupertinoIcons.ellipsis_circle,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
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
              // QuizPost(),
              StreamProvider<List<dynamic>>.value(
                initialData: [],
                value: userNetworkRepository.getAllUsersLikedItemKeysStream(),
                child: QuizPost(
                  itemModels: _itemModels,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _onRefresh() async {
    _itemModels.clear();
    // _itemModels.addAll(await ItemService().getItems());
    // _itemModels.addAll(await ItemService().getItemsExceptMine(widget.userKey));
    _itemModels.addAll(await ItemService()
        .getItemsUnsolved(FirebaseAuth.instance.currentUser!.uid));
    _itemModels.sort(
      (a, b) => a.createDate.compareTo(b.createDate),
    );
    setState(() {});
  }

  Future _getAndAddToken() async {
    // var token = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.getToken().then((token) {
      if (token != null)
        userNetworkRepository.addToken(
            userKey: FirebaseAuth.instance.currentUser!.uid, token: token);
    });
  }

  void _sendPushMessage() async {
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
            'to':
                'c3M8tmsg7k4hvVWKrveiJG:APA91bE7YQD74RLAfGvY8UGjsmC-gRp6zLF0UiK6m9NW6lj1WDUqppRTbHg8YDvssmKxf2hkgvyNtv8zIunAGuyuatZxOjAqfdTDeODteas1iwRUs4wvU9egtf8Nisp01dqlnranEv1V',

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
          'Authorization':
              'key=AAAAGWbrGMU:APA91bFCps7ojiWeqIjZG8VBXAlX3xBL5RA7Zemve00GpYHCq98d5N2Yniixuq-QRcLELF1Qb8D5pvOvUf-OolcMeLTAHx9wjjfZULIFNWXdncs5wfEsAQOd5cnAnHIM1YMl87MLV5Cx',
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
            'to':
                'c3M8tmsg7k4hvVWKrveiJG:APA91bE7YQD74RLAfGvY8UGjsmC-gRp6zLF0UiK6m9NW6lj1WDUqppRTbHg8YDvssmKxf2hkgvyNtv8zIunAGuyuatZxOjAqfdTDeODteas1iwRUs4wvU9egtf8Nisp01dqlnranEv1V',

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
